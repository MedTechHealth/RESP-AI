import asyncio
import websockets
import json
import librosa
import numpy as np
import os
import sys

# Add root to path
sys.path.append(os.getcwd())

async def test_normal_streaming():
    uri = "ws://127.0.0.1:8000/api/ws-analyze"
    
    # Generate 5 seconds of silence (simulating healthy/normal sound)
    sr = 16000
    duration = 5.0
    y = np.zeros(int(sr * duration), dtype=np.float32)
    
    audio_int16 = (y * 32768.0).astype(np.int16)
    audio_bytes = audio_int16.tobytes()
    
    print(f"Streaming {duration}s of silence (Simulating Normal)...")

    async with websockets.connect(uri) as websocket:
        await websocket.send(audio_bytes)
        await websocket.send("FINISH")
        
        response = await websocket.recv()
        result = json.loads(response)
        print("\n--- Analysis Result ---")
        print(json.dumps(result, indent=2))
        return result

if __name__ == "__main__":
    asyncio.get_event_loop().run_until_complete(test_normal_streaming())
