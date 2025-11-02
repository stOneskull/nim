# Nim & raylib: A Graphics Programming Journey

This repository documents a step-by-step journey into 2D graphics programming using the Nim language and the [raylib](https://www.raylib.com/) library. Each file is a self-contained lesson that builds upon previous concepts, starting from basic vector math and progressing towards the foundations of a simple game.

The goal is a slow, smooth progression, ensuring each concept is well understood before moving to the next.

## Lessons

### The `vectors` Series

* **vectors.nim:** Demonstrates vector normalization for constant-speed movement. A ball follows the mouse by calculating a direction vector, normalizing it, and scaling it by a speed value.
* **vectors2.nim:** Introduces Model Space vs. World Space. A shape is defined relative to its own center and then transformed (rotated and translated) into the world for drawing.
* **vectors3.nim:** Builds on lesson 2 by introducing transformation matrices. It shows how to create rotation and translation matrices, combine them into a single model matrix, and use it to transform an object's vertices.
* **vectors4.nim:** A conceptual lesson on linear algebra. It visually demonstrates that a matrix transformation is defined by where the basis vectors land, and that any vector's transformation can be predicted using this information.
* **vectors5.nim:** Covers the three fundamental transformations: Scale, Rotate, and Translate (SRT). It demonstrates creating matrices for each and applying them to multiple, independent objects in the same scene.
* **vectors6.nim:** Introduces interactivity and state management. A 'ship' can fire a 'bullet' based on user input. The lesson covers object state (active/inactive), velocity calculation, and simple collision detection.
* **vectors7.nim:** Visualizing quadratic functions (`y = ax² + bx + c`) and their roots. An introduction to mapping graph space to screen space.
* **vectors8.nim:** Plotting `sin(x)` and `cos(x)` functions to understand their wave-like nature and phase relationship.
* **vectors9.nim:** A dynamic visualization of the Unit Circle. This is a key lesson that demonstrates how `sin` and `cos` are geometrically derived from the coordinates of a rotating point, tying together angles, triangles, and waves.

### The `graphics` Series

* **graphics.nim:** The first step into transformations. This lesson demonstrates how to use the matrix stack (`pushMatrix`, `translatef`, `rotatef`) to position and animate an object on the screen.

... more to come!

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
    nim compile --run graphics.nim
    ```

Enjoy the journey!
