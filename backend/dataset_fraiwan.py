import os
import glob
import torch
from torch.utils.data import Dataset
from backend.preprocessing import AudioPreprocessor

class FraiwanDataset(Dataset):
    def __init__(self, root_dir, sample_rate=16000):
        self.root_dir = root_dir
        self.processor = AudioPreprocessor(sample_rate=sample_rate)
        
        # Path to Fraiwan Audio
        self.audio_path = os.path.join(root_dir, "Fraiwan", "Audio Files")
        
        if not os.path.exists(self.audio_path):
             # Try alternative path just in case
             self.audio_path = os.path.join(root_dir, "Fraiwan/Audio Files")
        
        print(f"🔍 Scanning Fraiwan dataset at: {self.audio_path}")
        
        # Class Mapping
        # 0: Normal
        # 1: Asthma
        # 2: COPD
        # 3: Pneumonia
        # 4: Other (Heart Failure, Fibrosis, etc.)
        self.class_counts = {0:0, 1:0, 2:0, 3:0, 4:0}
        
        self.data_list = []
        self._load_data()
        
    def _load_data(self):
        if not os.path.exists(self.audio_path):
            print(f"❌ Path not found: {self.audio_path}")
            return

        files = glob.glob(os.path.join(self.audio_path, "*.wav"))
        
        for wav_path in files:
            filename = os.path.basename(wav_path)
            label = self._get_label_from_filename(filename)
            
            if label is not None:
                self.data_list.append({'path': wav_path, 'label': label})
                self.class_counts[label] += 1
                
        print(f"📊 Fraiwan Stats: {self.class_counts}")
        print(f"   Total Samples: {len(self.data_list)}")

    def _get_label_from_filename(self, filename):
        # Format: BP101_Asthma,E W,P L U,45,F.wav
        # We look for the disease tag after the first underscore
        
        try:
            parts = filename.split('_')
            if len(parts) < 2: return 4 # Fallback
            
            # Use only the part before the first comma
            disease_tag = parts[1].split(',')[0].lower()
            
            # Parsing Logic
            if disease_tag == 'n':
                return 0 # Normal
            elif 'asthma' in disease_tag:
                return 1 # Asthma
            elif 'copd' in disease_tag:
                return 2 # COPD
            elif 'pneumonia' in disease_tag:
                return 3 # Pneumonia
            else:
                return 4 # Other (Heart Failure, Fibrosis, Pleural Effusion, etc.)
                
        except Exception as e:
            print(f"⚠️ Error parsing {filename}: {e}")
            return 4

    def __len__(self):
        return len(self.data_list)

    def __getitem__(self, idx):
        item = self.data_list[idx]
        
        # Extract Spectrogram (Same preprocessing as Stage 1)
        feature = self.processor.extract_features(item['path'])
        label = torch.tensor(item['label'], dtype=torch.long)
        
        return feature, label
