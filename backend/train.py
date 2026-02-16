import os
import sys
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader

# Add project root to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from backend.dataset import ICBHIDataset
from backend.model import RespiratoryCNN

def train_rigorous():
    # Diagnostic-Grade Training Config
    BATCH_SIZE = 8       # Keep 8 for GTX 1650
    EPOCHS = 20          # Increased for deep convergence
    LEARNING_RATE = 0.0005 # Slower learning rate for precision
    
    # Point to parent 'raw' to trigger multi-dataset loading
    DATASET_PATH = os.path.abspath("dataset/raw")
    MODEL_SAVE_PATH = "backend/model_weights.pth"
    
    # Fresh Start
    if os.path.exists(MODEL_SAVE_PATH):
        print(f"🧹 Removing existing weights for fresh training...")
        os.remove(MODEL_SAVE_PATH)
    
    # 1. Load Data
    print(f"📂 Loading Multi-Source Dataset...")
    dataset = ICBHIDataset(root_dir=DATASET_PATH)
    
    if len(dataset) == 0:
        print("❌ No data found. Run backend/prepare_data.py first!")
        return
        
    dataloader = DataLoader(dataset, batch_size=BATCH_SIZE, shuffle=True)
    
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"💻 Using device: {device}")
    
    model = RespiratoryCNN().to(device)
    
    # 2. Weighted Loss for Medical Sensitivity
    # We want to punish False Negatives (missing a sick person) more than False Positives.
    # Pos_weight > 1 increases recall.
    criterion = nn.BCELoss() # Switched back to BCELoss since model outputs sigmoid
    
    optimizer = optim.Adam(model.parameters(), lr=LEARNING_RATE, weight_decay=1e-5) # Added weight_decay for regularization
    
    print(f"🚀 Starting High-Precision Training ({EPOCHS} Epochs)...")
    model.train()
    
    for epoch in range(EPOCHS):
        running_loss = 0.0
        correct = 0
        total = 0
        
        for i, (inputs, labels, risks) in enumerate(dataloader):
            inputs = inputs.to(device)
            labels = labels.unsqueeze(1).to(device)
            
            optimizer.zero_grad()
            outputs, _ = model(inputs)
            
            # Loss Calculation
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()
            
            running_loss += loss.item()
            
            # Quick Accuracy Check
            preds = (outputs > 0.5).float()
            correct += (preds == labels).sum().item()
            total += labels.size(0)
            
        epoch_acc = 100 * correct / total
        print(f"Epoch {epoch+1}/{EPOCHS} | Loss: {running_loss/len(dataloader):.4f} | Train Acc: {epoch_acc:.1f}%")
        
    print("✅ Training Complete.")
    torch.save(model.state_dict(), MODEL_SAVE_PATH)
    print(f"💾 Model saved to {MODEL_SAVE_PATH}")

if __name__ == "__main__":
    train_rigorous()
