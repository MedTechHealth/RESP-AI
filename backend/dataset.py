import os
import glob
import pandas as pd
import torch
from torch.utils.data import Dataset
from backend.preprocessing import AudioPreprocessor

class ICBHIDataset(Dataset):
    def __init__(self, root_dir, transform=None, sample_rate=16000):
        self.root_dir = root_dir
        self.processor = AudioPreprocessor(sample_rate=sample_rate)
        
        # Paths
        self.icbhi_path = os.path.join(root_dir, "ICBHI_final_database")
        self.coswara_path = os.path.join(root_dir, "COSWARA")
        self.healthy_path = os.path.join(root_dir, "Healthy_Respiratory")
        
        print(f"🔍 Scanning datasets at root: {root_dir}")
        self.data_list = []
        
        # 1. ICBHI (Gold Standard Abnormal)
        icbhi_data = self._load_icbhi()
        print(f"   found {len(icbhi_data)} ICBHI samples")
        self.data_list += icbhi_data
        
        # 2. COSWARA (Supplementary Normal)
        coswara_data = self._load_coswara()
        print(f"   found {len(coswara_data)} COSWARA samples")
        self.data_list += coswara_data
        
        # 3. Healthy Respiratory (High Quality Mixed)
        healthy_data = self._load_healthy()
        print(f"   found {len(healthy_data)} Healthy samples")
        self.data_list += healthy_data
        
        # Statistics
        normals = sum(1 for x in self.data_list if x['label'] == 0)
        abnormals = sum(1 for x in self.data_list if x['label'] == 1)
        print(f"📊 Final Dataset Balance: Normal={normals} | Abnormal={abnormals} | Total={len(self.data_list)}")

    def _load_icbhi(self):
        data = []
        if not os.path.exists(self.icbhi_path): 
            print(f"   ⚠️ Path not found: {self.icbhi_path}")
            return data
        
        files = glob.glob(os.path.join(self.icbhi_path, "*.wav"))
        for wav in files:
            txt = wav.replace(".wav", ".txt")
            if not os.path.exists(txt): continue
            
            try:
                df = pd.read_csv(txt, sep='\t', header=None, names=['start', 'end', 'crackles', 'wheezes'])
                c = df['crackles'].sum() > 0
                w = df['wheezes'].sum() > 0
                
                if c and w: risk = 0.9
                elif c or w: risk = 0.6
                else: risk = 0.2
                
                label = 1 if (c or w) else 0
                data.append({'path': wav, 'label': label, 'risk': risk})
            except: continue
        return data

    def _load_coswara(self):
        data = []
        if not os.path.exists(self.coswara_path): 
            print(f"   ⚠️ Path not found: {self.coswara_path}")
            return data
        
        # Recursive search
        files = glob.glob(os.path.join(self.coswara_path, "**/*.wav"), recursive=True)
        for wav in files:
            name = os.path.basename(wav).lower()
            if "breathing" in name:
                data.append({'path': wav, 'label': 0, 'risk': 0.1})
        return data

    def _load_healthy(self):
        data = []
        # The user has files in dataset/raw/Healthy_Respiratory/jwyy9np4gv-3/Audio Files/
        # So we need to be aggressive with the search path
        if not os.path.exists(self.healthy_path): 
            print(f"   ⚠️ Path not found: {self.healthy_path}")
            return data
            
        files = glob.glob(os.path.join(self.healthy_path, "**/*.wav"), recursive=True)
        
        for wav in files:
            name = os.path.basename(wav)
            
            if "_N," in name or "_N_" in name:
                data.append({'path': wav, 'label': 0, 'risk': 0.0})
            elif "COPD" in name or "Asthma" in name or "Heart Failure" in name:
                data.append({'path': wav, 'label': 1, 'risk': 0.95})
            else:
                continue
                
        return data

    def __len__(self):
        return len(self.data_list)

    def __getitem__(self, idx):
        item = self.data_list[idx]
        feature = self.processor.extract_features(item['path'])
        label = torch.tensor(item['label'], dtype=torch.float32)
        risk = torch.tensor(item['risk'], dtype=torch.float32)
        return feature, label, risk
