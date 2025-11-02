# ****************************************************************************************
#
#   raylib [graphics] lesson 1 - Transformations
#
#   This lesson introduces the concept of transformations, which allow us to
#   move, rotate, and scale our drawings. This is the foundation of all
#   2D and 3D graphics.
#
#   We will combine our knowledge of:
#   - Vectors: To define the shape of our object.
#   - Trigonometry: To create continuous rotation.
#   - Matrices: Used internally by raylib to apply transformations.
#
# ****************************************************************************************

import raylib
import raymath
import rlgl # raylib's OpenGL abstraction layer, for matrix transformations
import math
import strformat

const
  screenWidth = 800
  screenHeight = 600

proc main =
  initWindow(screenWidth, screenHeight, "raylib [graphics] lesson 1 - Transformations")
  setTargetFPS(60)

  # LESSON 1: DEFINING AN OBJECT
  # We define our object (a triangle) using vectors.
  # Importantly, we define its vertices relative to a (0, 0) center point.
  # This makes rotating it around its own center much easier.
  let v1 = Vector2(x: 0, y: -50)
  let v2 = Vector2(x: -50, y: 50)
  let v3 = Vector2(x: 50, y: 50)

  var rotation: float32 = 0.0

  let font = getFontDefault()

  # Main game loop
  # --------------------------------------------------------------------------------------
  while not windowShouldClose():
    # Update
    # ----------------------------------------------------------------------------------
    # We use trigonometry implicitly! The angle increases smoothly, and the
    # rotation function will use sin() and cos() internally.
    rotation += 0.5 # Increase rotation angle every frame

    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)

    # LESSON 2: THE TRANSFORMATION STACK
    # Think of this like putting a new piece of transparent paper on top of
    # our drawing. Everything we do after `pushMatrix` happens on this new
    # sheet. `popMatrix` removes the sheet, returning to the original state.
    pushMatrix()

    # LESSON 3: TRANSLATION
    # We "translate" (move) our drawing origin to the center of the screen.
    # Any drawing commands that follow will now be relative to the screen's center,
    # not the top-left corner.
    translatef(screenWidth / 2, screenHeight / 2, 0)

    # LESSON 4: ROTATION
    # Now that we are at the center, we rotate our "transparent paper".
    # The rotation happens around the current origin (0,0), which we just
    # moved to the center of the screen.
    # rotatef(angle, x-axis, y-axis, z-axis)
    rotatef(rotation, 0, 0, 1) # We rotate on the Z-axis for 2D graphics

    # Now we can draw our triangle. Because we've transformed the world,
    # we can draw it at (0,0) and it will appear rotated in the screen's center.
    drawTriangle(v1, v2, v3, Red)
    drawTriangleLines(v1, v2, v3, DarkGray)

    # We are done with our transformed drawing, so we remove the "transparent paper".
    # This resets all transformations, so our UI text draws normally from the top-left.
    popMatrix()

    # --- Draw UI and Explanations ---
    drawText(font, "Transformations: Translate and Rotate", 
        Vector2(x: 20, y: 20), 30.0, 1.0, DarkGray)
    drawText(font, "1. We move the 'drawing origin' to the screen's center (Translate).", 
        Vector2(x: 20, y: 70), 20.0, 1.0, Gray)
    drawText(font, "2. We rotate the world around that new origin (Rotate).", 
        Vector2(x: 20, y: 100), 20.0, 1.0, Gray)
    drawText(font, "3. We draw the triangle at (0,0) in that new, rotated world.", 
        Vector2(x: 20, y: 130), 20.0, 1.0, Gray)
    drawText(font, fmt"Angle: {rotation:.0f}°", 
        Vector2(x: 20, y: screenHeight - 40), 20.0, 1.0, LightGray)

    endDrawing()
    # ------------------------------------------------------------------------------------

  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow()
  # --------------------------------------------------------------------------------------

main()

#[
Key takeaways from this lesson:

- Transformations (moving, rotating, scaling) are applied in reverse order of how
  you want to think about them. To rotate an object in place:
  1. Translate to the object's position.
  2. Rotate.
  3. Draw the object at (0,0).

- The `rlgl` module gives us direct access to the powerful matrix transformation
  stack, which is essential for all non-trivial graphics.
]#