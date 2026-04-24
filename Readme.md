<div align="center">
  <br/>
  <br/>

  <h1 align="center" style="font-size: 3rem; font-weight: 800; letter-spacing: 2px;">
    R E S P &nbsp;&nbsp;&nbsp; A I
  </h1>
  
  <p align="center" style="font-size: 1.2rem; color: #555; text-transform: uppercase; letter-spacing: 1px;">
    <strong>Real-Time Acoustic Respiratory Risk Assessment</strong>
  </p>

  <p align="center" style="font-size: 1.1rem; max-width: 600px; margin: 0 auto; color: #666;">
    An end-to-end artificial intelligence system designed to analyze respiratory audio signals and estimate health risk in real-time via continuous deep learning streaming.
  </p>

  <br />

  <p align="center">
    <a href="#architecture" style="text-decoration: none; color: inherit;"><b>ARCHITECTURE</b></a> &nbsp;&nbsp;&nbsp;︱&nbsp;&nbsp;&nbsp; 
    <a href="#pipeline" style="text-decoration: none; color: inherit;"><b>PIPELINE</b></a> &nbsp;&nbsp;&nbsp;︱&nbsp;&nbsp;&nbsp; 
    <a href="#getting-started" style="text-decoration: none; color: inherit;"><b>GETTING STARTED</b></a>
  </p>

  <br/>
  <br/>
</div>

### ✦ SYSTEM OVERVIEW ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

<table width="100%" style="border-collapse: separate; border-spacing: 15px; border: none;">
  <tr style="border: none;">
    <td width="50%" valign="top" style="border: 1px solid #eaeaea; padding: 24px; border-radius: 12px; background-color: #fafbfc;">
      <h3 style="margin-top: 0; font-size: 1.4em;">🚀 Real-Time Streaming</h3>
      <p style="color: #586069; margin-top: -10px;"><i>Zero-Latency Audio Ingestion</i></p>
      <p>Audio is streamed directly from the microphone to the AI engine via WebSockets, eliminating disk latency and significantly improving inference reliability.</p>
      <p><code>WebSocket</code> <code>Python Backend</code></p>
    </td>
    <td width="50%" valign="top" style="border: 1px solid #eaeaea; padding: 24px; border-radius: 12px; background-color: #fafbfc;">
      <h3 style="margin-top: 0; font-size: 1.4em;">🏥 Cascade AI Engine</h3>
      <p style="color: #586069; margin-top: -10px;"><i>Two-Stage Inference Pipeline</i></p>
      <p>Stage 1 utilizes a CNN for symptom detection (Crackles/Wheezes). Stage 2 maps acoustic embeddings to probable conditions (Asthma, COPD) via an MLP.</p>
      <p><code>CNN</code> <code>MLP</code> <code>PyTorch</code></p>
    </td>
  </tr>
  <tr style="border: none;">
    <td width="50%" valign="top" style="border: 1px solid #eaeaea; padding: 24px; border-radius: 12px; background-color: #fafbfc;">
      <h3 style="margin-top: 0; font-size: 1.4em;">🛡️ Gatekeeper Logic</h3>
      <p style="color: #586069; margin-top: -10px;"><i>Intelligent Signal Filtering</i></p>
      <p>Advanced algorithmic filtering prevents misleading disease labels for healthy subjects, ensuring high clinical precision and reducing false positives.</p>
      <p><code>Signal Processing</code> <code>Log-Mel</code></p>
    </td>
    <td width="50%" valign="top" style="border: 1px solid #eaeaea; padding: 24px; border-radius: 12px; background-color: #fafbfc;">
      <h3 style="margin-top: 0; font-size: 1.4em;">📱 Cross-Platform</h3>
      <p style="color: #586069; margin-top: -10px;"><i>Universal Deployment</i></p>
      <p>A highly responsive frontend built with Flutter, offering live visualization and seamless experiences across Android, iOS, and Desktop environments.</p>
      <p><code>Flutter</code> <code>Dart</code> <code>Riverpod</code></p>
    </td>
  </tr>
</table>

<br/>

### ✦ ARCHITECTURE ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```text
[ Patient Mic ] ──(Raw PCM Stream)──> [ WebSocket Gateway ]
                                              │
[ Final Report ] <──(JSON Result)─── [ AI Inference Engine ]
      │                                       │
      └─ Stage 1: Symptom Detection (CNN) ────┘
      └─ Stage 2: Disease Association (MLP) ──┘
```

<br/>

### ✦ ALGORITHMIC PIPELINE ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**1. Signal Processing**
- **Sampling Rate:** `16kHz Mono` (Medical Standard)
- **Band-Pass Filter:** Butterworth `50Hz - 2500Hz`
- **Noise Reduction:** Spectral Subtraction for background noise
- **Feature Extraction:** Log-Mel Spectrograms (`40 MFCC coefficients`)

**2. Deep Learning (CNN)**
- **Architecture:** 3-Layer Convolutional Neural Network (Max Pooling, Dropout)
- **Training Data:** ICBHI 2017 Challenge, COSWARA, Fraiwan Lung Sound Dataset
- **Optimization:** Z-Score Normalization & Hamming Windowing

<br/>

### ✦ GETTING STARTED ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

#### Backend (Python)
```bash
cd backend/
pip install -r requirements.txt
python main.py  # Server runs on http://127.0.0.1:8000
```

#### Frontend (Flutter)
```bash
cd app/
flutter pub get
flutter run
```

<br/>

### ✦ ETHICAL CONSIDERATIONS ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- **Not a Medical Device:** Prototype for screening and educational purposes.
- **Privacy First:** Audio processed entirely in-memory; zero disk storage.
- **Transparency:** All outputs include a probabilistic disclaimer.

<br/>
<br/>

<div align="center">
  <p style="color: #888;"><i>© 2026 Resp-AI Project Team &middot; Engineering & Documentation</i></p>
</div>
