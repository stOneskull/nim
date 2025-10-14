# ****************************************************************************************
#
#   raylib [vectors] lesson 2 - Drawing and Rotating Shapes
#
#   This lesson demonstrates:
#   - Defining a shape's vertices (points) using Vector2.
#   - The concept of "Model Space" (coordinates relative to the shape's own center).
#   - Rotating vertices using `vector2Rotate`.
#   - Translating vertices to a "World Space" position.
#
# ****************************************************************************************

import raylib
import raymath
import math # Import Nim's standard math library for the PI constant

const
  screenWidth = 800
  screenHeight = 450
  DEG2RAD = PI / 180.0 # Define the conversion constant ourselves

proc main =
  initWindow(screenWidth, screenHeight, "raylib [vectors] lesson 2 - Shapes and Rotation")
  setTargetFPS(60)

  # LESSON 1: MODEL SPACE
  # We define our shape's vertices relative to its own center (0, 0).
  # This is called "Model Space" or "Local Space". It makes transformations
  # like rotation much easier.
  let v1 = Vector2(x:  0.0, y: -25.0) # The top point of the triangle
  let v2 = Vector2(x: -25.0, y:  25.0) # The bottom-left point
  let v3 = Vector2(x:  25.0, y:  25.0) # The bottom-right point

  # This is the position where we will draw our shape in the world.
  # This is "World Space".
  let shapePosition = Vector2(x: screenWidth / 2.0, y: screenHeight / 2.0)

  # A variable to hold the current rotation of our shape in degrees.
  var rotation: float32 = 0.0

  # Main game loop
  # --------------------------------------------------------------------------------------
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ----------------------------------------------------------------------------------
    # Increment the rotation by 1 degree each frame.
    rotation += 1.0

    # LESSON 2: TRANSFORMATION (Rotate and Translate)
    # To draw our shape, we must transform each vertex from Model Space to World Space.
    # We do this in two steps for each vertex:
    # 1. Rotate the vertex around the origin (0,0).
    # 2. Translate (move) the rotated vertex to its final position on the screen.

    # The `rotate` operator takes a vector and an angle in RADIANS.
    # We multiply our angle in degrees by this constant.
    let angleInRadians = rotation * DEG2RAD
    let transformedV1 = rotate(v1, angleInRadians) + shapePosition
    let transformedV2 = rotate(v2, angleInRadians) + shapePosition
    let transformedV3 = rotate(v3, angleInRadians) + shapePosition

    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)

    drawText("This triangle is defined by 3 vectors (vertices)!", 10, 10, 20, DarkGray)
    drawText("We rotate the vertices, then add the position vector.", 10, 40, 20, DarkGray)

    # LESSON 3: DRAWING THE TRANSFORMED SHAPE
    # `drawTriangleLines` can take Vector2s directly to draw the shape.
    drawTriangleLines(transformedV1, transformedV2, transformedV3, Maroon)
    
    # We can also draw a small circle at the shape's origin to visualize the pivot point.
    drawCircle(shapePosition.x.int32, shapePosition.y.int32, 5, LightGray)
    endDrawing()
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context
  # --------------------------------------------------------------------------------------

main()