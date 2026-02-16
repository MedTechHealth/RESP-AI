import os
import sys
import torch
import numpy as np
from torch.utils.data import DataLoader
from sklearn.metrics import accuracy_score, confusion_matrix

# Add project root to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from backend.dataset_fraiwan import FraiwanDataset
from backend.model import RespiratoryCNN
from backend.model_stage2 import DiseaseClassifier

def print_medical_report(name, cm, labels, accuracy):
    print(f"\n🏥 MEDICAL TRUST REPORT: {name}")
    print("="*60)
    print(f"Overall Accuracy: {accuracy*100:.2f}%")
    print("-" * 60)
    
    row_sums = cm.sum(axis=1)
    col_sums = cm.sum(axis=0)
    
    print(f"{'Condition':<15} | {'Sensitivity (Recall)':<20} | {'Precision (PPV)':<20} | {'Samples'}")
    print("-" * 75)
    
    for i, label in enumerate(labels):
        if i >= len(cm): break
        tp = cm[i, i]
        fn = row_sums[i] - tp
        fp = col_sums[i] - tp
        
        sensitivity = tp / (tp + fn) if (tp + fn) > 0 else 0
        precision = tp / (tp + fp) if (tp + fp) > 0 else 0
        
        print(f"{label:<15} | {sensitivity*100:6.1f}%              | {precision*100:6.1f}%              | {row_sums[i]}")

    print("-" * 60)
    print("Confusion Matrix:")
    print(cm)
    print("="*60)

def evaluate_stage2():
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"💻 Evaluation running on: {device}")
    
    STAGE1_WEIGHTS = "backend/model_weights.pth"
    STAGE2_WEIGHTS = "backend/model_stage2_weights.pth"
    DATASET_PATH = os.path.abspath("dataset/raw")

    # Load Model 1
    model1 = RespiratoryCNN().to(device)
    if os.path.exists(STAGE1_WEIGHTS):
        model1.load_state_dict(torch.load(STAGE1_WEIGHTS, map_location=device))
        model1.eval()
    
    # Load Model 2
    model2 = DiseaseClassifier().to(device)
    if os.path.exists(STAGE2_WEIGHTS):
        model2.load_state_dict(torch.load(STAGE2_WEIGHTS, map_location=device))
        model2.eval()
    else:
        print("❌ Stage 2 weights not found.")
        return

    # Load Data
    dataset2 = FraiwanDataset(root_dir=DATASET_PATH)
    # Use larger batch size to speed up
    loader2 = DataLoader(dataset2, batch_size=32, shuffle=False)
    
    y_true = []
    y_pred = []
    
    print("Processing Fraiwan Dataset...")
    with torch.no_grad():
        for i, (inputs, labels) in enumerate(loader2):
            inputs, labels = inputs.to(device), labels.to(device)
            _, features = model1(inputs)
            logits = model2(features)
            _, preds = torch.max(logits, 1)
            
            y_true.extend(labels.cpu().numpy())
            y_pred.extend(preds.cpu().numpy())
            if i % 5 == 0: print(f"Batch {i}")

    cm = confusion_matrix(y_true, y_pred)
    acc = accuracy_score(y_true, y_pred)
    labels = ["Normal", "Asthma", "COPD", "Pneumonia", "Other"]
    
    print_medical_report("STAGE 2 (Disease Classification)", cm, labels, acc)

if __name__ == "__main__":
    evaluate_stage2()
