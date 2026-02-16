import os
import sys
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, random_split

# Add project root to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from backend.dataset_fraiwan import FraiwanDataset
from backend.model import RespiratoryCNN
from backend.model_stage2 import DiseaseClassifier

def train_stage2():
    # Configuration
    BATCH_SIZE = 8
    EPOCHS = 50
    LEARNING_RATE = 0.001
    
    DATASET_PATH = os.path.abspath("dataset/raw")
    STAGE1_WEIGHTS = "backend/model_weights.pth"
    STAGE2_SAVE_PATH = "backend/model_stage2_weights.pth"
    
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"💻 Device: {device}")

    # 1. Load Stage 1 (The Ears) - FROZEN
    print("🧊 Loading Stage 1 Model (Frozen)...")
    stage1 = RespiratoryCNN().to(device)
    
    if os.path.exists(STAGE1_WEIGHTS):
        stage1.load_state_dict(torch.load(STAGE1_WEIGHTS, map_location=device))
        print("   ✅ Stage 1 weights loaded.")
    else:
        print("   ❌ Stage 1 weights missing! Cannot proceed.")
        return

    # FREEZE STAGE 1
    for param in stage1.parameters():
        param.requires_grad = False
    stage1.eval() # Set to eval mode (fix dropout/batchnorm)

    # 2. Load Data
    print("📂 Loading Fraiwan Dataset...")
    full_dataset = FraiwanDataset(root_dir=DATASET_PATH)
    
    if len(full_dataset) == 0:
        print("   ❌ No data found.")
        return

    # Split Train/Val (80/20)
    train_size = int(0.8 * len(full_dataset))
    val_size = len(full_dataset) - train_size
    train_dataset, val_dataset = random_split(full_dataset, [train_size, val_size])
    
    train_loader = DataLoader(train_dataset, batch_size=BATCH_SIZE, shuffle=True)
    val_loader = DataLoader(val_dataset, batch_size=BATCH_SIZE, shuffle=False)

    # 3. Init Stage 2 (The Brain)
    print("🧠 Initializing Stage 2 Model...")
    stage2 = DiseaseClassifier().to(device)
    
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(stage2.parameters(), lr=LEARNING_RATE)

    # 4. Training Loop
    print(f"🚀 Starting Stage 2 Training ({EPOCHS} Epochs)...")
    
    best_val_acc = 0.0
    
    for epoch in range(EPOCHS):
        stage2.train()
        running_loss = 0.0
        correct = 0
        total = 0
        
        for inputs, labels in train_loader:
            inputs, labels = inputs.to(device), labels.to(device)
            
            # Step A: Get Features from Frozen Stage 1
            with torch.no_grad():
                _, features = stage1(inputs) # Ignore risk score, keep features
            
            # Step B: Train Stage 2
            optimizer.zero_grad()
            logits = stage2(features)
            loss = criterion(logits, labels)
            loss.backward()
            optimizer.step()
            
            running_loss += loss.item()
            _, predicted = torch.max(logits.data, 1)
            total += labels.size(0)
            correct += (predicted == labels).sum().item()
            
        train_acc = 100 * correct / total
        
        # Validation
        stage2.eval()
        val_correct = 0
        val_total = 0
        
        with torch.no_grad():
            for inputs, labels in val_loader:
                inputs, labels = inputs.to(device), labels.to(device)
                _, features = stage1(inputs)
                logits = stage2(features)
                _, predicted = torch.max(logits.data, 1)
                val_total += labels.size(0)
                val_correct += (predicted == labels).sum().item()
        
        val_acc = 100 * val_correct / val_total
        
        print(f"Epoch {epoch+1}/{EPOCHS} | Loss: {running_loss/len(train_loader):.4f} | Train Acc: {train_acc:.1f}% | Val Acc: {val_acc:.1f}%")
        
        # Save Best
        if val_acc > best_val_acc:
            best_val_acc = val_acc
            torch.save(stage2.state_dict(), STAGE2_SAVE_PATH)
            
    print(f"✅ Training Complete. Best Val Acc: {best_val_acc:.1f}%")
    print(f"💾 Saved Stage 2 weights to {STAGE2_SAVE_PATH}")

if __name__ == "__main__":
    train_stage2()
