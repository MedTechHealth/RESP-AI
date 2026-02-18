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
    *   *Utility:* Augmenting the Asthma/COPD classes.
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

## 📝 Data Collection Protocol (Streaming Standard)
For custom data collected via the Resp-AI streaming app, the following standards are enforced:
*   **Format:** Raw PCM 16-bit Mono.
*   **Sampling Rate:** 16,000Hz (Optimized for both human hearing and AI feature extraction).
*   **Normalization:** Automated Z-Score normalization before storage.
*   **Metadata Requirements:** 
    - Age / Gender / BMI.
    - Smoking status.
    - Presence of fever or shortness of breath.
    - **Gold Standard:** Verification against PFT (Spirometry) or X-Ray.

---

© 2026 Resp-AI Data Science Team
Engineering Documentation
