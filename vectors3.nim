# ****************************************************************************************
#
#   raylib [vectors] lesson 3 - Transformation with Matrices
#
#   This lesson demonstrates:
#   - Creating rotation and translation matrices.
#   - Combining matrices into a single "model" matrix.
#   - Transforming vertices from Model Space to World Space using the matrix.
#   - The efficiency of using a single matrix for multiple transformations.
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
  initWindow(screenWidth, screenHeight, "raylib [vectors] lesson 3 - Matrices")
  setTargetFPS(60)

  # MODEL SPACE: The vertices are the same as in Lesson 2.
  let v1 = Vector2(x:  0.0, y: -25.0) # The top point of the triangle
  let v2 = Vector2(x: -25.0, y:  25.0) # The bottom-left point
  let v3 = Vector2(x:  25.0, y:  25.0) # The bottom-right point

  # This is the world position for our shape's center.
  let worldPosition = Vector2(x: screenWidth / 2.0, y: screenHeight / 2.0)

  # A variable to hold the current rotation of our shape in degrees.
  var rotation: float32 = 0.0

  # Main game loop
  # --------------------------------------------------------------------------------------
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ----------------------------------------------------------------------------------
    rotation += 1.0
    let angleInRadians = rotation * DEG2RAD

    # LESSON 1: CREATE INDIVIDUAL TRANSFORMATION MATRICES
    # A matrix can store transformations. We create one for rotation and one for translation.
    # For 2D, we rotate around the Z-axis.
    let rotationMatrix = rotateZ(angleInRadians)
    
    # We create a matrix that will move our shape to its world position.
    let translationMatrix = translate(worldPosition.x, worldPosition.y, 0)

    # LESSON 2: COMBINE MATRICES
    # The power of matrices is that they can be multiplied together to combine their
    # transformations. The order matters! We rotate first, then translate.
    let modelMatrix = multiply(rotationMatrix, translationMatrix)

    # LESSON 3: TRANSFORM VERTICES
    # Now, we apply our single, combined `modelMatrix` to each vertex.
    # The `vector2Transform` function performs the matrix-vector multiplication.
    let transformedV1 = transform(v1, modelMatrix)
    let transformedV2 = transform(v2, modelMatrix)
    let transformedV3 = transform(v3, modelMatrix)

    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)

    drawText("This triangle is transformed by a single matrix!", 10, 10, 20, DarkGray)

    drawTriangleLines(transformedV1, transformedV2, transformedV3, Maroon)
    drawCircle(worldPosition.x.int32, worldPosition.y.int32, 5, LightGray)
    endDrawing()
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context
  # --------------------------------------------------------------------------------------

main()