import os
import glob
import subprocess
import tarfile

def process_coswara():
    base_dir = "dataset/raw/COSWARA/archive"
    print(f"🚀 Starting COSWARA Extraction in {base_dir}...")
    
    # Find all date directories
    date_dirs = glob.glob(os.path.join(base_dir, "202*"))
    
    for d in date_dirs:
        date_name = os.path.basename(d)
        print(f"   Processing {date_name}...")
        
        # Check if already extracted (look for wav files deep inside)
        existing_wavs = glob.glob(os.path.join(d, "**/*.wav"), recursive=True)
        if len(existing_wavs) > 10:
            print(f"      ✅ Already extracted ({len(existing_wavs)} files found). Skipping.")
            continue
            
        # Check for split files
        split_files = sorted(glob.glob(os.path.join(d, "*.tar.gz.*")))
        if not split_files:
            print(f"      ⚠️ No split archives found in {date_name}.")
            continue
            
        combined_tar = os.path.join(d, f"{date_name}.tar.gz")
        
        # 1. Stitch files
        print(f"      🔗 Stitching {len(split_files)} parts...")
        # Use simple file concatenation
        with open(combined_tar, 'wb') as outfile:
            for fname in split_files:
                with open(fname, 'rb') as infile:
                    outfile.write(infile.read())
                    
        # 2. Extract
        print(f"      📦 Extracting archive...")
        try:
            with tarfile.open(combined_tar, "r:gz") as tar:
                tar.extractall(path=d)
            print("      ✅ Done.")
            
            # Optional: Remove the huge combined file to save space
            os.remove(combined_tar)
            
        except Exception as e:
            print(f"      ❌ Error extracting: {e}")

if __name__ == "__main__":
    process_coswara()
