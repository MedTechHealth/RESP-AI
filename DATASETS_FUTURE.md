# Respiratory Datasets for Future Enhancement

To further improve the diagnostic accuracy of Resp-AI, the following datasets are recommended for integration into **Stage 2** (Disease Association).

## ✅ Currently Integrated
1.  **ICBHI 2017 Challenge Dataset**
    *   *Focus:* Anomalies (Wheezes, Crackles).
    *   *Role:* Backbone training for Stage 1.
2.  **COSWARA**
    *   *Focus:* COVID-19, Normal Breathing, Coughs.
    *   *Role:* Healthy baseline and symptom validation.
3.  **Fraiwan Lung Sound Dataset**
    *   *Focus:* Explicit Disease Labels (Asthma, COPD, etc.).
    *   *Role:* Stage 2 Disease Classification.

## 🚀 Recommended for Future Integration (Open Access)
1.  **Project Breathe (Cystic Fibrosis)**
    *   *Description:* Longitudinal data from Cystic Fibrosis patients.
    *   *Utility:* Improving accuracy for chronic obstructive conditions.
    *   *Access:* Research collaboration often required.
2.  **Jordan University Respiratory Dataset**
    *   *Description:* High-quality recordings of labeled lung sounds.
    *   *Utility:* augmenting the Asthma/COPD classes.
3.  **COVID-19 Sounds App (Cambridge)**
    *   *Description:* Large-scale crowd-sourced respiratory sounds.
    *   *Utility:* Robustness to background noise and different microphones.

## 💼 Commercial / Restricted (High Value)
1.  **RALE® Lung Sounds**
    *   *Description:* The premier teaching repository for lung sounds.
    *   *Status:* Commercial/Educational license required.
2.  **Stethographics**
    *   *Description:* Clinical-grade recordings used in medical training.
    *   *Status:* Commercial.

## 📝 Data Collection Protocol
For future custom data collection, ensure:
*   **Sampling Rate:** Minimum 4000Hz (to capture wheezes up to 2000Hz).
*   **Format:** Uncompressed WAV (16-bit PCM).
*   **Metadata:** Age, Sex, BMI, and **Gold Standard Diagnosis** (PFT or X-Ray confirmed).
