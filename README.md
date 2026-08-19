# 🏠 AutoPlan 3D

**AutoPlan 3D** is a sophisticated interior design and space planning application that bridges the gap between 2D drafting and 3D visualization. By leveraging **Flutter** for a seamless mobile UI and **Unity** for high-fidelity 3D rendering, the app empowers users to design, furnish, and walk through their dream spaces in real-time.

---

## ✨ Key Features

*   **2D-to-3D Generation:** Convert 2D drawings and bubble diagrams into procedural 3D walls and rooms using custom Unity mesh generation.
*   **Interactive Interior Design:** Drag-and-drop furniture placement with real-time control over position, rotation, scale, and materials.
*   **Immersive Walkthroughs:** Switch between **Orbit Mode** for planning, **Third-Person** for overview, and **First-Person Mode** for a realistic walkthrough of the space.
*   **Scene Synchronization:** Bi-directional data syncing between the Unity 3D environment and Flutter's local/cloud storage.
*   **Pro Tools:** High-resolution snapshots, day/night lighting toggles, and project export/import functionality.
*   **Modern Tech Stack:** Built with GetX for state management, Stripe for premium features, and OpenCV for intelligent layout processing.

---

## 🛠️ Tech Stack

*   **Frontend:** Flutter (Dart)
*   **3D Engine:** Unity
*   **State Management:** GetX
*   **Persistence:** GetStorage & Shared Preferences
*   **Integrations:** 
    *   `flutter_unity_widget`: The core bridge for Unity embedding.
    *   `flutter_stripe`: Payment processing for premium features.
    *   `opencv_dart`: Image processing for floor plan analysis.
    *   `photo_manager`: Managing exported snapshots.

---

## 🏗️ Project Architecture

The app uses a bi-directional messaging protocol to communicate between the Flutter UI and the Unity 3D engine:

1.  **Flutter to Unity:** Commands are sent via `postMessage` to specific Unity GameObjects (e.g., `FurnitureManager`, `UniversalCameraController`) to spawn objects or change scene states.
2.  **Unity to Flutter:** The `SceneStateReporter` sends JSON payloads back to Flutter via `onUnityMessage`, which are then parsed by the `SceneSyncService` to update the local database.

---

## 🚀 Getting Started

1.  **Flutter Setup:**
    *   Run `flutter pub get` to install dependencies.
    *   Ensure you have a supported Android/iOS environment.
2.  **Unity Integration:**
    *   This repository contains the Flutter wrapper. The Unity source project must be exported as a `unityLibrary` and placed in the appropriate native directory (`/android` or `/ios`) to build the project.
3.  **Run:**
    *   `flutter run`

---

## 📄 License

This project is for demonstration purposes as part of the `flutter_unity_widget` ecosystem.
