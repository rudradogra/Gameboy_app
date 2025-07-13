<div align="center">
<h1>🎮 GameBoy Dating App</h1>

![GameBoy Style Dating App](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Node.js Backend](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![Supabase Database](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Railway Deployment](https://img.shields.io/badge/Railway-0B0D0E?style=for-the-badge&logo=railway&logoColor=white)

*Step into the past with the future of dating - A fully functional GameBoy-themed dating app with an authentic retro experience*

[🎥 Demo Video](https://youtube.com/shorts/_ZogtFTygEc) | [📱 Download APK]([https://github.com/your-repo/releases](https://drive.google.com/file/d/1NZY6sp396ejUND6L2rexybx5yUfknHjc/view?usp=sharing))

</div>



---

🌟 What Is It?

GameBoy Dating App is a nostalgic twist on modern dating. Imagine Tinder, but inside a fully functional GameBoy interface — pixelated profiles, tactile D-pad navigation, crunchy button sounds, and a heart-based liking system. All wrapped in authentic 8-bit vibes.

---

🧩 Key Features

🎮 GameBoy Interface
- Exact GameBoy design: D-pad, A/B buttons, screen glow
- Fully interactive UI mimicking a handheld console

🧡 Heart-Based Matching
- Start with 10 hearts per session
- Like = 0.5 ❤️, Superlike = 1 ❤️
- Adds strategic and gamified behavior to swiping

🖼️ Retro Image Processing
- Uploaded photos are transformed into pixelated 8-bit avatars
- Uses only 8 basic RGB colors: red, green, blue, black, white, yellow, cyan, magenta

🔊 Sound & Feedback
- Every click and move plays authentic GameBoy sounds
- Haptic and visual feedback just like an old-school console

📸 Profile Gallery
- Swipe through user images like a slideshow
- View bios with ↓ and toggle profile info on demand

---

## 🛠️ Tech Behind the Magic

| **Layer**           | **Stack**                                                                                         | **Description** |
|---------------------|---------------------------------------------------------------------------------------------------|------------------|
| **Frontend**         | `Flutter` (Android, Web, iOS) + Custom GameBoy UI                                                 | Built with Flutter for true cross-platform support. The GameBoy interface is fully recreated with custom widgets, retro typography, D-pad controls, and smooth animations. |
| **Backend**          | `Node.js` + `Express.js`                                                                          | Handles user authentication, profile management, image uploads, and match logic. Cleanly structured with RESTful APIs. |
| **Auth & Database**  | `Supabase` (PostgreSQL + JWT Auth)                                                                | Supabase provides scalable authentication and database services. Stores user profiles, image URLs, and matches, all secured with JWT tokens. |
| **Image Pixelation** | `sharp` (Node.js image processing library)                                                        | Converts uploaded profile photos into pixelated retro-style images with reduced resolution and a strict 8-color RGB palette. Uses nearest-neighbor scaling to maintain crisp pixels. |
| **Hosting & Deployment** | `Railway` (backend server), `Supabase` (database & file storage) | The backend is deployed on Railway. Supabase handles real-time database and file storage. |

---

🔧 Local Setup (Dev Only)
1.	Clone the repo
```
git clone https://github.com/rudradogra/Gameboy_app.git
```

2.	Backend Setup
```
cd server
npm install
npm run dev
```

3.	Frontend (Flutter)
```
cd ..
flutter pub get
flutter run
```
---

## 📝 License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.

---
<div align="center">


Built with ❤️ and nostalgia for a new generation of retro lovers

</div>
