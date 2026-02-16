# Resp-AI 🫁

**## Acoustic Respiratory Risk Assessment System using Deep Learning**

---

## 1. Project Overview

Resp-AI is an end-to-end artificial intelligence system designed to **analyze respiratory audio signals** (lung sounds) and estimate **respiratory health risk** using signal processing and deep learning techniques.

The system does **not perform clinical diagnosis**. Instead, it functions as a **screening and decision-support tool**, identifying abnormal respiratory sound patterns (such as wheezes and crackles) and mapping them to an interpretable **risk score** for early triage and monitoring.

---

## 2. Motivation

Respiratory diseases are among the leading causes of global morbidity. Traditional diagnosis requires trained clinicians and medical equipment, which may not be accessible in rural or low-resource settings.

Resp-AI aims to:

- Enable **early screening** using low-cost microphones
- Assist **telemedicine and remote monitoring**
- Provide **explainable, non-invasive risk estimation**
- Support healthcare professionals, not replace them

---

## 3. Scope and Limitations

### What Resp-AI CAN do

- Detect abnormal respiratory sound patterns
- Classify sounds as normal or abnormal
- Estimate a continuous respiratory risk score (0–10)
- Provide triage-level recommendations

### What Resp-AI CANNOT do

- Diagnose diseases (e.g., asthma, pneumonia)
- Replace medical professionals
- Act as a certified medical device

This distinction is intentional and critical for ethical and academic correctness.

---

## 4. System Architecture (High-Level)

Respiratory Audio Input
↓
Signal Preprocessing
↓
Feature Extraction (MFCC)
↓
Deep Learning Model (CNN)
↓
Probability Estimation
↓
Risk Scoring & Smoothing
↓
Final Output

---

## 5. Algorithmic Pipeline (Detailed)

### 5.1 Audio Acquisition

- Input: WAV audio (lung sounds)
- Source: Digital stethoscope / smartphone microphone / dataset recordings
- Sampling rate standardized during preprocessing

---

### 5.2 Butterworth Band-Pass Filter

**Purpose:**  
Remove irrelevant frequency components while preserving signal amplitude.

**Reason for choice:**  
Butterworth filters have a maximally flat frequency response, avoiding distortion of medically relevant acoustic features.

---

### 5.3 Spectral Subtraction

**Purpose:**  
Reduce stationary background noise.

**Method:**  
Estimate noise spectrum and subtract it from the signal spectrum in the frequency domain.

**Benefit:**  
Improves signal-to-noise ratio for real-world recordings.

---

### 5.4 Short-Time Fourier Transform (STFT)

**Purpose:**  
Convert time-domain signal into time–frequency representation.

**Why STFT:**  
Respiratory sounds are non-stationary; STFT captures temporal variations in frequency.

---

### 5.5 Hamming Window

**Purpose:**  
Reduce spectral leakage during STFT.

**Effect:**  
Improves frequency resolution and reduces edge artifacts.

---

### 5.6 Mel Filter Bank

**Purpose:**  
Map linear frequency spectrum to Mel scale.

**Reason:**  
Aligns acoustic features with human auditory perception.

---

### 5.7 Log Mel Energies

**Purpose:**  
Compress dynamic range and stabilize variance.

---

### 5.8 Discrete Cosine Transform (DCT-II)

**Purpose:**  
Decorrelate Mel energies to generate MFCCs.

**Output:**  
Compact, low-dimensional feature vectors suitable for ML.

---

### 5.9 Z-Score Normalization

**Purpose:**  
Standardize features across datasets and devices.

---

### 5.10 Convolutional Neural Network (CNN)

**Architecture:**

- Convolution layers
- ReLU activation
- Pooling layers
- Fully connected layers

**Input:** MFCC spectrograms  
**Output:** Class probabilities

**Why CNN:**  
MFCCs form image-like representations, ideal for convolutional pattern learning.

---

### 5.11 Softmax Classifier

**Purpose:**  
Convert logits into normalized probability distribution.

---

### 5.12 Risk Score Mapping

**Method:** Min–Max scaling  
**Range:** 0 (Normal) → 10 (High Risk)

---

### 5.13 Moving Average Filter

**Purpose:**  
Smooth risk values across time to reduce false positives.

---

### 5.14 Threshold-Based Decision Rule

| Risk Range | Interpretation |
| ---------- | -------------- |
| 0–3        | Normal         |
| 4–6        | Mild Risk      |
| 7–10       | High Risk      |

---

## 6. Dataset Strategy

### 6.1 Training Philosophy

- Learn **sound abnormalities first**
- Learn **disease-associated risk patterns second**
- Never claim clinical diagnosis

---

### 6.2 Primary Training Dataset (Tier-1)

- ICBHI 2017 Respiratory Sound Database
- Expert-annotated wheeze/crackle events
- High academic credibility

### 6.3 Supplementary Datasets (Tier-2)

- COSWARA (breathing & cough with symptom metadata)
- Other open research respiratory datasets

### 6.4 Noise Augmentation

- Environmental noise datasets (ESC-50, UrbanSound8K)
- Used only for robustness

---

## 7. Training Strategy

### 7.1 Incremental Training

- Initial training on Tier-1 dataset
- Continued training (fine-tuning) with Tier-2 datasets
- Previously learned weights preserved

### 7.2 Avoiding Catastrophic Forgetting

- Mix old and new data during fine-tuning
- Use lower learning rate
- Optionally freeze early CNN layers

---

## 8. Evaluation Metrics

- Accuracy
- Precision / Recall
- F1-score
- ROC-AUC
- Confusion Matrix

Evaluation is performed **across datasets** to ensure generalization.

---

## 9. Deployment Concept

### Possible Platforms

- Desktop application
- Mobile application
- Embedded system (edge AI)

### Real-Time Capability

- MFCC extraction: real-time
- CNN inference: lightweight model
- End-to-end latency suitable for live screening

---

## 10. Ethical & Legal Considerations

- No medical diagnosis claims
- Transparent explainable outputs
- User advised to consult professionals
- Dataset licenses respected
- Designed as a **screening & triage tool**

---

## 11. Applications

- Telemedicine support
- Remote health monitoring
- Rural healthcare screening
- Academic research
- Educational demonstrations

---

## 12. Future Enhancements

- Multimodal fusion (audio + vitals)
- Transformer-based audio models
- On-device learning
- Federated learning for privacy
- Clinical validation studies (long-term)

---

## 13. Conclusion

Resp-AI demonstrates that **respiratory risk screening using acoustic signals and AI is technically feasible, ethically responsible, and practically valuable** when framed correctly.

By combining signal processing, perceptual modeling, and deep learning, Resp-AI bridges the gap between raw respiratory sounds and actionable health insights.

---

## 14. Disclaimer

Resp-AI is a research and educational project.  
It is **not a medical device** and must not be used for clinical diagnosis.

---

© Resp-AI Project  
Engineering Documentation
