import os
import sys
import torch
import numpy as np
from torch.utils.data import DataLoader
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, confusion_matrix, classification_report

# Add project root to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from backend.dataset import ICBHIDataset
from backend.dataset_fraiwan import FraiwanDataset
from backend.model import RespiratoryCNN
from backend.model_stage2 import DiseaseClassifier

def print_medical_report(name, cm, labels, accuracy):
    print(f"\n🏥 MEDICAL TRUST REPORT: {name}")
    print("="*60)
    print(f"Overall Accuracy: {accuracy*100:.2f}%")
    print("-" * 60)
    
    # Calculate Per-Class Metrics
    # Precision (PPV) = TP / (TP + FP) -> Trust in positive prediction
    # Recall (Sensitivity) = TP / (TP + FN) -> Trust in finding the disease
    
    row_sums = cm.sum(axis=1)
    col_sums = cm.sum(axis=0)
    
    print(f"{'Condition':<15} | {'Sensitivity (Recall)':<20} | {'Precision (PPV)':<20} | {'Samples'}")
    print("-" * 75)
    
    for i, label in enumerate(labels):
        tp = cm[i, i]
        fn = row_sums[i] - tp
        fp = col_sums[i] - tp
        tn = cm.sum() - (tp + fp + fn)
        
        sensitivity = tp / (tp + fn) if (tp + fn) > 0 else 0
        precision = tp / (tp + fp) if (tp + fp) > 0 else 0
        
        print(f"{label:<15} | {sensitivity*100:6.1f}%              | {precision*100:6.1f}%              | {row_sums[i]}")

    print("-" * 60)
    print("Confusion Matrix (Rows=True, Cols=Pred):")
    print(cm)
    print("="*60)

def evaluate_system():
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"💻 Evaluation running on: {device}")
    
    # Paths
    STAGE1_WEIGHTS = "backend/model_weights.pth"
    STAGE2_WEIGHTS = "backend/model_stage2_weights.pth"
    DATASET_PATH = os.path.abspath("dataset/raw")

    # ==========================================
    # STAGE 1 EVALUATION (Symptom/Risk)
    # ==========================================
    print("\n\n📊 EVALUATING STAGE 1: SYMPTOM DETECTION (The Ears)")
    
    # Load Model
    model1 = RespiratoryCNN().to(device)
    if os.path.exists(STAGE1_WEIGHTS):
        model1.load_state_dict(torch.load(STAGE1_WEIGHTS, map_location=device))
        model1.eval()
    else:
        print("❌ Stage 1 weights not found.")
        return

    # Load Data (ICBHI + COSWARA)
    dataset1 = ICBHIDataset(root_dir=DATASET_PATH)
    loader1 = DataLoader(dataset1, batch_size=16, shuffle=False)
    
    y_true_1 = []
    y_pred_1 = []
    
    with torch.no_grad():
        for inputs, labels, _ in loader1:
            inputs = inputs.to(device)
            # Stage 1 returns (risk, features) now
            outputs, _ = model1(inputs) 
            
            preds = (outputs.cpu().numpy() > 0.5).astype(int).flatten()
            y_true_1.extend(labels.numpy())
            y_pred_1.extend(preds)
            
    cm1 = confusion_matrix(y_true_1, y_pred_1)
    acc1 = accuracy_score(y_true_1, y_pred_1)
    print_medical_report("STAGE 1 (Anomaly Detection)", cm1, ["Normal", "Abnormal"], acc1)

    # ==========================================
    # STAGE 2 EVALUATION (Disease Interpretation)
    # ==========================================
    print("\n\n📊 EVALUATING STAGE 2: DISEASE ASSOCIATION (The Brain)")
    
    # Load Model
    model2 = DiseaseClassifier().to(device)
    if os.path.exists(STAGE2_WEIGHTS):
        model2.load_state_dict(torch.load(STAGE2_WEIGHTS, map_location=device))
        model2.eval()
    else:
        print("❌ Stage 2 weights not found.")
        return

    # Load Data (Fraiwan)
    dataset2 = FraiwanDataset(root_dir=DATASET_PATH)
    loader2 = DataLoader(dataset2, batch_size=16, shuffle=False)
    
    y_true_2 = []
    y_pred_2 = []
    
    with torch.no_grad():
        for inputs, labels in loader2:
            inputs, labels = inputs.to(device), labels.to(device)
            
            # Pass through Stage 1 first (to get features)
            _, features = model1(inputs)
            
            # Pass features to Stage 2
            logits = model2(features)
            _, preds = torch.max(logits, 1)
            
            y_true_2.extend(labels.cpu().numpy())
            y_pred_2.extend(preds.cpu().numpy())
            
    cm2 = confusion_matrix(y_true_2, y_pred_2)
    acc2 = accuracy_score(y_true_2, y_pred_2)
    labels2 = ["Normal", "Asthma", "COPD", "Pneumonia", "Other"]
    
    # Handle case where not all classes are present in validation batch
    # Resize labels list to match confusion matrix if needed
    if cm2.shape[0] < 5:
        print("⚠️ Note: Not all disease classes were present in the test set.")
        
    print_medical_report("STAGE 2 (Disease Classification)", cm2, labels2, acc2)

if __name__ == "__main__":
    evaluate_system()
