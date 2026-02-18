import asyncio
import websockets
import json
import librosa
import numpy as np
import os
import torch
import sys

# Add root to path
sys.path.append(os.getcwd())

from backend.preprocessing import AudioPreprocessor

async def test_streaming_endpoint(wav_file_path):
    uri = "ws://127.0.0.1:8000/api/ws-analyze"
    
    # 1. Load the WAV file with librosa at target SR (16k)
    # This simulates what Flutter records (raw PCM 16-bit)
    y, sr = librosa.load(wav_file_path, sr=16000)
    
    # 2. Convert to raw 16-bit PCM bytes (as expected by backend main.py)
    # y is normalized (-1 to 1). We need to denormalize back to 16-bit int.
    audio_int16 = (y * 32768.0).astype(np.int16)
    audio_bytes = audio_int16.tobytes()
    
    print(f"File: {wav_file_path}")
    print(f"Audio Length: {len(y)/sr:.2f}s, Bytes: {len(audio_bytes)}")

    async with websockets.connect(uri) as websocket:
        # 3. Stream in chunks (simulating real-time)
        chunk_size = 4096
        for i in range(0, len(audio_bytes), chunk_size):
            chunk = audio_bytes[i:i + chunk_size]
            await websocket.send(chunk)
            await asyncio.sleep(0.01) # Simulate real-time gap
            
        # 4. Send FINISH command
        await websocket.send("FINISH")
        print("Sent FINISH command. Waiting for analysis...")
        
        # 5. Get and print the result
        response = await websocket.recv()
        result = json.loads(response)
        print("\n--- Analysis Result ---")
        print(json.dumps(result, indent=2))
        return result

if __name__ == "__main__":
    # Use any wav file from the dataset
    test_file = "dataset/raw/ICBHI_final_database/130_1p2_Tc_mc_AKGC417L.wav"
    if not os.path.exists(test_file):
        # Find ANY wav file
        import glob
        wav_files = glob.glob("dataset/raw/ICBHI_final_database/*.wav")
        if wav_files:
            test_file = wav_files[0]
        else:
            print("No test WAV file found in dataset/raw/ICBHI_final_database/")
            sys.exit(1)
            
    asyncio.get_event_loop().run_until_complete(test_streaming_endpoint(test_file))
