# Nim & raylib: A Graphics Programming Journey

This repository documents a step-by-step journey into 2D graphics programming using the Nim language and the [naylib](https://github.com/planetis-m/naylib) wrapper for the [raylib](https://www.raylib.com/) library. Each file is a self-contained lesson that builds upon previous concepts, starting from basic vector math and progressing towards the foundations of a simple game.

The goal is a slow, smooth progression, ensuring each concept is well understood before moving to the next.

## Lessons

### The `vectors` Series

* **vectors.nim:** Demonstrates vector normalization for constant-speed movement. A ball follows the mouse by calculating a direction vector, normalizing it, and scaling it by a speed value.
* **vectors2.nim:** Introduces Model Space vs. World Space. A shape is defined relative to its own center and then transformed (rotated and translated) into the world for drawing.
* **vectors3.nim:** Builds on lesson 2 by introducing transformation matrices. It shows how to create rotation and translation matrices, combine them into a single model matrix, and use it to transform an object's vertices.
* **vectors4.nim:** A conceptual lesson on linear algebra. It visually demonstrates that a matrix transformation is defined by where the basis vectors land, and that any vector's transformation can be predicted using this information.
* **vectors5.nim:** Covers the three fundamental transformations: Scale, Rotate, and Translate (SRT). It demonstrates creating matrices for each and applying them to multiple, independent objects in the same scene.
* **vectors6.nim:** Introduces interactivity and state management. A 'ship' can fire a 'bullet' based on user input. The lesson covers object state (active/inactive), velocity calculation, and point-in-polygon collision detection.
* **vectors7.nim:** Visualizing quadratic functions (`y = ax² + bx + c`) and their roots. An introduction to mapping graph space to screen space.
* **vectors8.nim:** Plotting `sin(x)` and `cos(x)` functions to understand their wave-like nature and phase relationship.
* **vectors9.nim:** A dynamic visualization of the Unit Circle. This is a key lesson that demonstrates how `sin` and `cos` are geometrically derived from the coordinates of a rotating point, tying together angles, triangles, and waves.

### The `graphics` Series

* **graphics.nim:** The first step into transformations. This lesson demonstrates how to use the matrix stack (`pushMatrix`, `translatef`, `rotatef`) to position and animate an object on the screen.
* **graphics2.nim:** Shows how to programmatically generate vertices for any regular polygon (triangle, square, pentagon, etc.) and draw them.
* **graphics3.nim:** Manages a "scene" of multiple, independent objects. Each polygon has its own position, rotation, and scale, demonstrating how to apply unique transformations to each object in a shared world space.
* **graphics4.nim:** A complete mini-game that combines many previous concepts. It features a player-controlled ship, different enemy types with varying health, collectibles, a scoring and life system, and a full game loop with "Playing" and "Game Over" states.
* **graphics5.nim:** Introduces pixel-based drawing by creating two independent particle systems. A stream of "pixels" forms a sine wave, while a second system creates fiery sparks that are emitted from the rotating point, demonstrating how multiple effects can be managed simultaneously.
* **graphics6.nim:** Creates a multi-stage firework effect. This demonstrates a hierarchical particle system where a "rocket" particle, upon reaching its apex, explodes and spawns a burst of "spark" particles. This is a core technique for creating complex visual effects.
* **graphics7.nim:** A simple 2D particle physics simulation. Particles are affected by gravity and bounce realistically off of rotated polygon surfaces. This lesson covers collision detection, calculating surface normals, and using vector reflection for bounce physics.

... more to come!

## Web Version

These lessons can be viewed and run directly in your web browser!

**[→ View the interactive lessons at 2d.23bay.com](https://2d.23bay.com/)**

The Nim code is compiled to WebAssembly (WASM) using the [Emscripten](https://emscripten.org/) toolchain. This allows the C-based raylib library to run at near-native speed in a secure browser environment.

## How to Run

1. Make sure you have the Nim programming language installed.

2. Install the `naylib` raylib wrapper using the Nimble package manager:

    ```sh
    nimble install naylib
    ```

3. Navigate to the repository directory and run any of the lesson files:

    ```sh
    nim compile --run vectors9.nim
    ```

    or

    ```sh
    nim compile --run graphics3.nim
    ```

Enjoy the journey!
