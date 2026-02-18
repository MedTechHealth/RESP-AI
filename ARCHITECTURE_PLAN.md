# Resp-AI System Architecture (v3.0)

## 1. System Overview

Resp-AI utilizes a **Two-Stage Cascade Architecture** to balance robust symptom detection with disease-specific interpretation. This design mimics clinical workflow: first identifying _abnormality_, then determining the _probable cause_.

The system is designed to be **modular** and **extensible**, allowing for future improvements to the disease classification layer without invalidating the core symptom detection model.

## 2. Component Architecture

### 🏥 Stage 1: Symptom Detection (The "Ears")

- **File:** `backend/model.py` (`RespiratoryCNN`)
- **Role:** The sensory organ. It listens to raw audio and converts it into mathematical understanding.
- **Input:** Mel-Spectrograms (Shape: `[Batch, 1, 40, Time]`)
- **Architecture:** 3-Layer CNN with Max Pooling and Dropout.
- **Training Data:** ICBHI 2017 (6,898 recordings), COSWARA.
- **Outputs:**
  1.  **Respiratory Risk Score (0-10):** A sigmoid probability indicating the presence of abnormalities (Crackles/Wheezes).
  2.  **Acoustic Embeddings (512-d):** The flattened feature vector from the penultimate layer (`fc1`). This contains the "texture" of the sound.
- **Status:** **Frozen & Validated**. This layer provides a stable, safety-critical baseline. **DO NOT RETRAIN** unless you have a massive new dataset (>10k samples) and regulatory approval.

### 🧠 Stage 2: Disease Association (The "Brain")

- **File:** `backend/model_stage2.py` (`DiseaseClassifier`)
- **Role:** The interpreter. It takes the "understanding" from Stage 1 and maps it to specific medical conditions.
- **Input:** Acoustic Embeddings (Shape: `[Batch, 512]`) - _Received from Stage 1_.
- **Architecture:** Linear Classifier (Fully Connected Layer).
- **Training Data:** Fraiwan Lung Sound Database (Verified Disease Labels).
- **Outputs:**
  - **Condition Probability:** Softmax distribution over classes: `[Normal, Asthma, COPD, Heart Failure, Pneumonia, Other]`.
- **Methodology:** Transfer Learning (Feature Extraction / Linear Probing).

## 3. Data Flow & Inference Pipeline

The `backend/main.py` coordinates the flow:

1.  **Input:** Patient Audio (WAV/MP3 or Live PCM Stream).
2.  **Preprocessing (`backend/preprocessing.py`):**
    - Resample to 16kHz.
    - Band-pass filter (50-2500Hz).
    - Generate Mel-Spectrogram.
3.  **Stage 1 Forward Pass:**
    - Audio Spectrogram enters `RespiratoryCNN`.
    - **Returns:** `risk_score` (float) AND `features` (tensor).
4.  **Stage 2 Forward Pass:**
    - `features` tensor enters `DiseaseClassifier`.
    - **Returns:** `disease_probs` (tensor).
5.  **Response Generation:**
    - Risk Score mapped to "Low/Mild/High".
    - Disease Probabilities mapped to specific labels (e.g., "Asthma (85%)").
    - **Safety Layer:** A rule-based check ensures "High Risk" is flagged even if Stage 2 is unsure of the specific disease.
    - **Gatekeeper Logic:** If Stage 1 `risk_score` is < 3.5, the system overrides Stage 2 output to "No abnormality detected," preventing misleading disease associations for healthy subjects.

## 4. Frontend Architecture (The Instrument)

The Flutter frontend is built as a reactive instrument for high-fidelity data capture.

### 4.1 State Management (Riverpod)
- **`recordingProvider`:** Manages the entire lifecycle of a recording session (Idle, Recording, Streaming, Analyzing, Result).
- **`audioServiceProvider`:** Scopes the native audio recorder and permissions.

### 4.2 Streaming Protocol (WebSockets)
- **Handshake:** On start, a WebSocket connection is opened to `/api/ws-analyze`.
- **Transmission:** Raw PCM 16-bit Mono (16kHz) chunks are sent in binary format.
- **Command Control:** The text command `FINISH` is sent to trigger the analysis phase on the backend.
- **Cleanup:** The socket is closed immediately after the JSON result is received and the user is navigated to the report.

## 5. Developer Guide: How to Extend

### Adding a New Disease

To add a new disease (e.g., Tuberculosis) to the system:

1.  **Data:** Gather labeled audio files for the new disease.
2.  **Preprocessing:** Place files in `dataset/raw/NewDisease/`.
3.  **Code:** Update `backend/dataset_fraiwan.py` to recognize the new label in filenames.
4.  **Architecture:** Update `backend/model_stage2.py` to increase the output class count (e.g., from 5 to 6).
5.  **Training:** Run `python backend/train_stage2.py`.
    - _Note:_ This will ONLY train the Stage 2 classifier. Stage 1 remains frozen, preserving core accuracy.

### Improving Accuracy

- **Do not touch Stage 1** (unless you find a bug).
- **Focus on Stage 2 Data:** The quality of the "Brain" depends entirely on the variety of disease-labeled data in the Fraiwan (or equivalent) dataset.

## 6. File Structure Responsibilities

- `backend/model.py`: Defines the Stage 1 CNN (The Ears).
- `backend/model_stage2.py`: Defines the Stage 2 Classifier (The Brain).
- `backend/train_stage2.py`: Script to train Stage 2 while keeping Stage 1 frozen.
- `backend/dataset_fraiwan.py`: Handles loading and parsing specific disease datasets.
- `backend/main.py`: The API that glues it all together.

## ⚠️ Medical Disclaimer

This system provides **probabilistic risk assessment** and **pattern association**. It is **not** a diagnostic device. "COPD-like pattern" means the sound shares acoustic characteristics with confirmed COPD cases, not that the patient has COPD.
