# The Last World

An atmospheric 3D game project developed using the **Godot Engine 4**. Explore a desolated world, control your character, and interact with mysterious objects and shield mechanics.

---

## 🚀 Features

* **Player Controlls:** Fully implemented character movement, physics, and camera controls.
* **Bulwark Shell Enemy:** A unique enemy that chases the player and can charge at them. The only way to damage the mis on their back site.
* **User Interface:** A main screen, with a working loading screen for the world.
* **Procedural generated World** The world is always different, but at the moment pretty empty.

---

## 🛠️ Technical Details & Structure

The project is built entirely using **GDScript** and utilizes the modern 3D features of Godot 4.

```text
├── addons/                  # Wakatime and animations
├── bulwark-shell.tscn       # Scene for the Bulwark Shell (3D Enemy)
├── bulwark_shell.gd         # Logic and mechanics for the Bulwark Shell
├── load-screen.tscn         # Loading screen scene
├── loading_screen.gd        # Logic for asynchronous scene loading
├── main-screen.tscn         # Main menu scene
├── main_screen.gd           # Main menu UI logic
├── player.tscn              # Player scene (3D Character)
├── player.gd                # Player movement and input script
├── world.tscn               # The primary game world scene
└── project.godot            # Godot project configuration file
```

---

## Thanks too

* **Quaternius** For the animations. Here is a Link to his patreon and check it out
  https://quaternius.com/index.html

---

## 💻 Installation & Setup

To run or develop this project locally, follow these steps:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/IBimsHedebe/The-last-World
   ```
2. **Open in Godot Engine:**
   * Make sure you have **Godot 4.x** installed.
   * In the Godot Project Manager, click **Import**.
   * Browse and select the `project.godot` file from the cloned folder.
3. **Run the project:**
   * Press `F5` inside the Godot editor to launch the project from the main screen.

---

## 📜 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for more details.
