# 2D Visibility Polygon Simulation

A real-time 2D visibility polygon and ray-casting simulation implemented in **Processing (Java)**.

## 📌 Overview
This project demonstrates how to calculate a visibility field from a single light source (the mouse) in an environment with static rectangular obstacles. The simulation uses **Ray Casting** and **Vertex Scanning** to determine which areas of the 2D space are visible and which are in shadow.

## 📺 Demo

https://github.com/user-attachments/assets/0f09a22f-0b56-4dfd-a4b5-038ac8638539

Figure 1: Visibility Polygon Simulation.</em>


## 🚀 Features
* **Ray Casting with Offsets**: For every vertex, the engine casts 3 rays (the vertex angle and $\pm 0.001$ radians) to correctly "hug" corners and capture the empty space behind them.
* **Procedural Environment**: Generates a set of non-overlapping rectangular obstacles every time the environment is reset.
* **Efficient Sorting**: Vertices are sorted by their polar angle relative to the light source to ensure the `beginShape()` function renders a clean, non-intersecting polygon.
* **Real-time Interaction**: The visibility field updates instantly as the mouse (light source) moves across the canvas.

## 🧠 The Algorithm
The visibility polygon is constructed through these core steps:
1.  **Vertex Collection**: The algorithm identifies all vertices of the obstacles and the four corners of the screen.
2.  **Ray Casting**: For each vertex, it casts a ray from the mouse position. It calculates the closest intersection point with any obstacle's edge.
3.  **Angular Sorting**: All resulting intersection points are sorted by their angle relative to the mouse:
    $$\text{angle} = \mathrm{atan2}(y_{point} - y_{mouse}, x_{point} - x_{mouse})$$
4.  **Polygon Rendering**: The sorted points are connected in sequence to form a single, translucent `PShape` representing the visible area.

## 🛠️ Installation & Usage
1.  Download and install [Processing 4](https://processing.org/).
2.  Clone this repository or copy the code into a new sketch.
3.  Run the sketch and interact with the simulation:
    *   **Move Mouse**: Change the position of the light source.
    *   **Left Click**: Regenerate a new set of random obstacles.

## 📝 License
This project is open-source and available under the MIT License. Feel free to use it for educational purposes!
