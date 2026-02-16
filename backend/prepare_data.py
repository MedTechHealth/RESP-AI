import os
import glob
import subprocess
import shutil
import tarfile

def run_command(command):
    try:
        subprocess.run(command, check=True, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except subprocess.CalledProcessError as e:
        print(f"⚠️  Command failed: {command}")

def prepare_coswara():
    print("🔹 Processing COSWARA Dataset...")
    coswara_root = "dataset/raw/COSWARA"
    archive_root = os.path.join(coswara_root, "archive")
    
    # 1. Find all date folders
    date_folders = glob.glob(os.path.join(archive_root, "202*"))
    
    for folder in date_folders:
        folder_name = os.path.basename(folder)
        # Check for split files (.tar.gz.aa, .ab, etc.)
        split_files = sorted(glob.glob(os.path.join(folder, "*.tar.gz.*")))
        
        if split_files:
            print(f"   🔧 Stitching {folder_name}...")
            # Combine split files
            output_tar = os.path.join(folder, f"{folder_name}.tar.gz")
            # Linux command to cat all parts into one file
            cat_cmd = f"cat {os.path.join(folder, '*.tar.gz.*')} > {output_tar}"
            run_command(cat_cmd)
            
            # Extract
            print(f"   📦 Extracting {folder_name}...")
            try:
                with tarfile.open(output_tar, "r:gz") as tar:
                    tar.extractall(path=folder)
                # Cleanup combined tar to save space
                os.remove(output_tar)
            except Exception as e:
                print(f"   ❌ Failed to extract {folder_name}: {e}")

def prepare_healthy():
    # Healthy dataset is already unzipped based on user feedback, 
    # but we need to verify standardization if needed.
    # Current analysis showed files are directly in 'Audio Files'.
    pass

if __name__ == "__main__":
    print("🚀 Starting Data Preparation Protocol...")
    prepare_coswara()
    print("✅ Data Preparation Complete.")
