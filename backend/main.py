import os
import torch
import shutil
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from backend.model import RespiratoryCNN
from backend.model_stage2 import DiseaseClassifier
from backend.preprocessing import AudioPreprocessor

# Global variables for model
model = None
stage2_model = None
processor = None
device = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Load model on startup
    global model, stage2_model, processor, device
    
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model = RespiratoryCNN().to(device)
    stage2_model = DiseaseClassifier().to(device)
    processor = AudioPreprocessor()
    
    # Load Stage 1 Weights
    weights_path = "backend/model_weights.pth"
    if os.path.exists(weights_path):
        print(f"Loading Stage 1 weights from {weights_path}")
        model.load_state_dict(torch.load(weights_path, map_location=device))
    else:
        print("Warning: Stage 1 weights not found. Using random initialization.")
    
    # Load Stage 2 Weights
    stage2_weights_path = "backend/model_stage2_weights.pth"
    if os.path.exists(stage2_weights_path):
        print(f"Loading Stage 2 weights from {stage2_weights_path}")
        stage2_model.load_state_dict(torch.load(stage2_weights_path, map_location=device))
    else:
        print("Warning: Stage 2 weights not found. Disease prediction will be random.")

    model.eval()
    stage2_model.eval()
    yield
    # Cleanup if needed

app = FastAPI(
    title="Resp-AI API",
    description="Acoustic Respiratory Risk Assessment System",
    version="1.0.0",
    lifespan=lifespan
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "Resp-AI Inference Engine is Online", "system": "ready"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}

@app.post("/api/analyze")
async def analyze_audio(file: UploadFile = File(...)):
    global model, stage2_model, processor, device
    
    # Validation
    if not file.filename.endswith(('.wav', '.mp3')):
        raise HTTPException(status_code=400, detail="Invalid file format. Please upload a WAV or MP3 file.")
    
    try:
        # Save temp file
        temp_path = f"temp_{file.filename}"
        with open(temp_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
            
        # Process
        # extract_features returns (1, n_mfcc, time_steps) i.e. (C, H, W)
        features = processor.extract_features(temp_path)
        
        # Add Batch Dimension -> (1, 1, n_mfcc, time_steps)
        features = features.unsqueeze(0)
        
        features = features.to(device)
        
        # Inference
        with torch.no_grad():
            # Stage 1: Symptom Detection
            risk_prediction, embeddings = model(features)
            probability = risk_prediction.item()
            
            # Stage 2: Disease Association
            disease_probs = stage2_model.predict_probs(embeddings)
            top_prob, top_class_idx = torch.max(disease_probs, 1)
            
            predicted_disease = stage2_model.classes[top_class_idx.item()]
            disease_confidence = top_prob.item()
            
        # Cleanup
        os.remove(temp_path)
        
        # Risk Mapping
        # Probability 0.0 - 1.0 -> Risk 0 - 10
        risk_score = round(probability * 10, 1)
        
        classification = "Normal"
        if risk_score >= 7:
            classification = "High Risk"
        elif risk_score >= 4:
            classification = "Mild Risk"
            
        return {
            "filename": file.filename,
            "risk_score": risk_score,
            "probability": probability,
            "classification": classification,
            "disease_association": {
                "condition": predicted_disease,
                "confidence": f"{disease_confidence*100:.1f}%",
                "disclaimer": "Probabilistic association only. Not a clinical diagnosis."
            },
            "details": {
                "detected_anomalies": ["Abnormal Patterns"] if risk_score > 5 else [],
                "medical_disclaimer": "This system provides probabilistic risk assessment and pattern association. It is not a diagnostic device."
            }
        }
        
    except Exception as e:
        if os.path.exists(temp_path):
            os.remove(temp_path)
        raise HTTPException(status_code=500, detail=str(e))
