# Nim & raylib: A Graphics Programming Journey

This repository documents a step-by-step journey into 2D graphics programming using the Nim language and the [raylib](https://www.raylib.com/) library. Each file is a self-contained lesson that builds upon previous concepts, starting from basic vector math and progressing towards the foundations of a simple game.

The goal is a slow, smooth progression, ensuring each concept is well understood before moving to the next.

## Lessons

### The `vectors` Series

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
