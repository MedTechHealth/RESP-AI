# Resp-AI 🫁

**Acoustic Respiratory Risk Assessment System using Real-time Deep Learning Streaming**

---

## 1. Project Overview

Resp-AI is an end-to-end artificial intelligence system designed to **analyze respiratory audio signals** (lung sounds) and estimate **respiratory health risk** in real-time. By utilizing a high-performance Python backend and a responsive Flutter frontend, Resp-AI provides immediate feedback on respiratory health.

The system identifies abnormal respiratory sound patterns (such as wheezes and crackles) and maps them to an interpretable **risk score** and **disease association**, mimicking a clinical triage workflow.

---

## 2. Key Features

- **🚀 Real-time Streaming:** Audio is streamed directly from the microphone to the AI engine via WebSockets, eliminating disk latency and improving reliability.
- **🏥 Two-Stage Cascade AI:**
    - **Stage 1 (Symptom Detection):** Identifies abnormalities (Crackles/Wheezes) and generates a 0-10 Risk Score.
    - **Stage 2 (Disease Association):** Maps acoustic embeddings to probable conditions (Asthma, COPD, etc.).
- **🛡️ Gatekeeper Logic:** Intelligent filtering that prevents misleading disease labels for healthy subjects.
- **📱 Cross-Platform Frontend:** Built with Flutter for a seamless experience on Android, iOS, and Desktop.
- **📉 Live Visualization:** Real-time feedback during the recording process.

---

## 3. System Architecture (High-Level)

```text
[ Patient Mic ] ──(Raw PCM Stream)──> [ WebSocket Gateway ]
                                              │
[ Final Report ] <──(JSON Result)─── [ AI Inference Engine ]
      │                                       │
      └─ Stage 1: Symptom Detection (CNN) ────┘
      └─ Stage 2: Disease Association (MLP) ──┘
```

---

## 4. Algorithmic Pipeline

### 4.1 Signal Processing
- **Sampling Rate:** 16kHz Mono (Medical Standard).
- **Butterworth Band-Pass Filter:** Preserves 50Hz - 2500Hz to focus on medical acoustic features.
- **Spectral Subtraction:** Reduces stationary background noise for cleaner input.
- **Feature Extraction:** Generates Log-Mel Spectrograms (40 MFCC coefficients).

### 4.2 Deep Learning (CNN)
- **Architecture:** 3-Layer Convolutional Neural Network with Max Pooling and Dropout.
- **Training Data:** ICBHI 2017 Challenge Dataset, COSWARA, and Fraiwan Lung Sound Dataset.
- **Optimization:** Z-Score Normalization and Hamming Windowing for spectral stability.

---

## 5. Getting Started

### 5.1 Backend (Python)
1. Navigate to the `backend/` directory.
2. Install dependencies: `pip install -r requirements.txt`.
3. Start the server: `python main.py`.
   - The server will run on `http://127.0.0.1:8000`.

### 5.2 Frontend (Flutter)
1. Navigate to the `app/` directory.
2. Install dependencies: `flutter pub get`.
3. Run the application: `flutter run`.

---

## 6. Ethical & Legal Considerations

- **NOT A MEDICAL DEVICE:** Resp-AI is a research prototype for screening and educational purposes. It does not provide clinical diagnoses.
- **Privacy First:** In the current version, audio is processed in-memory and not stored on disk, ensuring maximum patient privacy.
- **Transparency:** All outputs include a probabilistic disclaimer and advise consultation with a medical professional.

---

## 7. Future Roadmap

- **Research Vault:** Automatic archiving of anonymized audio for model retraining.
- **Multi-modal Fusion:** Integrating vitals (Heart Rate, SpO2) into the risk assessment.
- **On-device Inference:** Porting the CNN models to TensorFlow Lite for offline use.

---

© 2026 Resp-AI Project Team
Engineering & Documentation
