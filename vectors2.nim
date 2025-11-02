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

type
  TriangleType = enum
    Isosceles, Equilateral, RightAngled

proc main =
  initWindow(screenWidth, screenHeight, "raylib [vectors] lesson 2 - Shapes and Rotation")
  setTargetFPS(60)

  var v1, v2, v3: Vector2

  var currentType = Isosceles

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
    if isKeyPressed(Space):
      # Cycle through the triangle types
      # `.ord` gets the integer value of an enum (Isosceles=0, Equilateral=1, etc.).
      # `.high` gets the last enum member, so `.high.ord` is the highest index.
      # We add 1 to get the total count for the `mod` operator, which makes the
      # cycle wrap around to 0 when it goes past the end.
      # `cast` converts the resulting integer back to a TriangleType.
      currentType = cast[TriangleType]((currentType.ord + 1) mod (TriangleType.high.ord + 1))

    # LESSON 1: MODEL SPACE
    # We define our shape's vertices relative to its own center (0, 0).
    # This is "Model Space". It makes transformations like rotation much easier.
    if currentType == Isosceles:
      v1 = Vector2(x: 0.0, y: -25.0)
      v2 = Vector2(x: -25.0, y: 25.0)
      v3 = Vector2(x: 25.0, y: 25.0)
    elif currentType == RightAngled:
      v1 = Vector2(x: -25.0, y: -25.0)
      v2 = Vector2(x: 25.0, y: 25.0)
      v3 = Vector2(x: -25.0, y: 25.0)
    else: # Equilateral
      let side: float32 = 50.0
      let height = (sqrt(3.0) / 2.0) * side
      v1 = Vector2(x:  0.0, y: -height * 2.0/3.0)
      v2 = Vector2(x: -side / 2.0, y: height * 1.0/3.0)
      v3 = Vector2(x:  side / 2.0, y: height * 1.0/3.0)

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
    drawText("Press [Space] to switch triangle type.", 10, screenHeight - 30, 20, LightGray)

    # LESSON 3: DRAWING THE TRANSFORMED SHAPE
    # `drawTriangleLines` can take Vector2s directly to draw the shape.
    drawTriangleLines(transformedV1, transformedV2, transformedV3, Maroon)
    
    # We can also draw a small circle at the shape's origin to visualize the pivot point.
    # The `drawCircle` function is overloaded to accept a Vector2 for the center.
    drawCircle(shapePosition, 5, LightGray)
    endDrawing()
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context
  # --------------------------------------------------------------------------------------

main()