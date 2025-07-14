# 🚗 Car GPS - QBCore Resource

A simple and lightweight GPS tracking system for FiveM servers using QBCore. This resource provides a functional in-game GPS interface for vehicles with an integrated UI and database tracking support.

---

## 📦 Features

- 📍 Real-time GPS tracking UI using NUI
- 🔁 Seamless server ↔ client communication
- 💾 MySQL support via `car_gps.sql`
- 🎨 Fully customizable HTML/CSS/JS interface
- ✅ Plug-and-play with QBCore

---

## 🧰 Requirements

- FiveM Server (Latest recommended)
- QBCore Framework
- MySQL / MariaDB
- `oxmysql` or compatible database resource

---

## 🚀 Installation

1. **Download & Extract:**
   Place the `car_gps` folder into your `resources` directory.
2. **Copy & Paste this item code into your items.lua:**
    ["gps"] = {
    ['name'] = "gps",
    ['label'] = "GPS Tracker",
    ['weight'] = 200,
    ['type'] = "item",
    ['image'] = "gps.png",
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = true,
    ['combinable'] = nil,
    ['description'] = "Used to track vehicles remotely."
},
3. **Save & Paste PNG Into your images folder:**

<img width="100" height="100" alt="gps" src="https://github.com/user-attachments/assets/9ef3c5bd-3ee1-4aea-b46f-38a0ff889966" />

3. **Import SQL:**
   Import the `car_gps.sql` into your database using phpMyAdmin or a tool like HeidiSQL.

4. **Add to `server.cfg`:**

   ```cfg
   ensure car_gps


🤝 Credits
Developed by Noor Taliep
Feel free to contribute or fork for improvements!
Demo Video
https://youtu.be/tg6DvbZgOQQ
