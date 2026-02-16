import os
import sys
import torch
import numpy as np
from torch.utils.data import DataLoader
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, confusion_matrix

# Add project root to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from backend.dataset import ICBHIDataset
from backend.model import RespiratoryCNN

def evaluate():
    # Configuration
    BATCH_SIZE = 16
    # Corrected path to point to the parent 'raw' folder where all datasets live
    DATASET_PATH = os.path.abspath("dataset/raw")
    MODEL_PATH = "backend/model_weights.pth"
    
    print(f"📊 Loading dataset for evaluation...")
    dataset = ICBHIDataset(root_dir=DATASET_PATH)
    
    if len(dataset) == 0:
        print("❌ Dataset is empty! Evaluation cannot proceed.")
        return

    dataloader = DataLoader(dataset, batch_size=BATCH_SIZE, shuffle=False)
    
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"💻 Using device: {device}")
    
    # Load Model
    model = RespiratoryCNN().to(device)
    if os.path.exists(MODEL_PATH):
        model.load_state_dict(torch.load(MODEL_PATH, map_location=device))
        print(f"✅ Loaded model weights from {MODEL_PATH}")
    else:
        print("❌ Model weights not found! Please train the model first.")
        return

    model.eval()
    
    all_preds = []
    all_labels = []
    
    print("🚀 Starting Evaluation...")
    
    with torch.no_grad():
        for i, (inputs, labels, risks) in enumerate(dataloader):
            inputs = inputs.to(device)
            labels = labels.cpu().numpy()
            
            outputs, _ = model(inputs)
            preds = (torch.sigmoid(outputs).cpu().numpy() > 0.5).astype(int).flatten()
            
            all_preds.extend(preds)
            all_labels.extend(labels)
            
            if i % 10 == 0:
                print(f"   Processed batch {i}/{len(dataloader)}")

    # Calculate Metrics
    accuracy = accuracy_score(all_labels, all_preds)
    precision = precision_score(all_labels, all_preds, zero_division=0)
    recall = recall_score(all_labels, all_preds, zero_division=0)
    f1 = f1_score(all_labels, all_preds, zero_division=0)
    cm = confusion_matrix(all_labels, all_preds)
    
    print("\n" + "="*40)
    print(f"🏆 FINAL MODEL PERFORMANCE")
    print("="*40)
    print(f"✅ Accuracy:  {accuracy*100:.2f}%")
    print(f"🎯 Precision: {precision*100:.2f}%")
    print(f"🔎 Recall:    {recall*100:.2f}%")
    print(f"⚖️  F1-Score:  {f1*100:.2f}%")
    print("-" * 40)
    print("Confusion Matrix:")
    if cm.shape == (2, 2):
        print(f"True Negatives: {cm[0][0]} | False Positives: {cm[0][1]}")
        print(f"False Negatives: {cm[1][0]} | True Positives: {cm[1][1]}")
    else:
        print(f"Matrix shape: {cm.shape}")
        print(cm)
    print("="*40)

if __name__ == "__main__":
    evaluate()
