# Resp-AI Flutter App Testing Guide

This guide will help you test the **Resp-AI Precision Instrument** locally on your machine.

## Prerequisites
1.  **Flutter SDK:** Ensure `flutter --version` works in your terminal.
2.  **Backend:** The Python backend must be running.
    *   Navigate to the `backend/` directory.
    *   Run: `python main.py`
    *   Verify by visiting: `http://localhost:8000/`

## 1. Running the App
Navigate to the `app/` directory and run the command for your target platform:

### Desktop (Recommended for quick testing)
*   **Windows:** `flutter run -d windows`
*   **macOS:** `flutter run -d macos`
*   **Linux:** `flutter run -d linux`

### Mobile (Requires Emulator or Physical Device)
*   **Android:** `flutter run -d android`
*   **iOS:** `flutter run -d ios`

## 2. Testing the Streaming Flow
1.  **Start Recording:** Click the **Blue Microphone** button.
    *   The app will ask for Microphone permission (Allow it).
    *   A WebSocket connection will open to the backend.
    *   The button will turn red and pulse, indicating it is **streaming raw audio data live**.
2.  **Stop & Analyze:** Click the **Red Square** button.
    *   A "FINISH" command is sent over the WebSocket.
    *   The backend processes the live buffer and returns the JSON result immediately.
3.  **View Results:** A modern results screen will appear showing:
    *   **Risk Score (0-10)**
    *   **Classification (Normal, Mild, High Risk)**
    *   **Acoustic Pattern Match (e.g., Asthma, Healthy Pattern)**
    *   **Gatekeeper Confirmation:** If your audio is healthy, the app will explicitly show "No abnormality detected."

## 3. Advanced Configuration
*   **WebSocket URL:** If testing on a physical Android device, the app will try to fallback to `10.0.2.2:8000`. For custom setups, update `lib/services/api_service.dart`.
*   **Raw PCM Data:** The app streams 16-bit PCM at 16,000Hz Mono. This is hardcoded to match the `RespiratoryCNN` requirements.

## 4. Troubleshooting
*   **Connection Refused:** Ensure the backend is running on port 8000.
*   **Stream Error:** Check the `backend.log` or the Flutter terminal for WebSocket handshake issues.
*   **Permission Denied:** Ensure your OS has granted microphone access to the terminal/IDE.
