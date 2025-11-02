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

      #     Basis Vectors (Orientation & Scale)      |  Perspective
      # ---------------------------------------------+---------------
      # | m0 (Xx)   m4 (Yx)   m8 (Zx)   m12 (Tx) |   <- X-component of each axis
      # | m1 (Xy)   m5 (Yy)   m9 (Zy)   m13 (Ty) |   <- Y-component of each axis
      # | m2 (Xz)   m6 (Yz)   m10(Zz)   m14 (Tz) |   <- Z-component of each axis
      # +--------------------------------------------+
      # | m3        m7        m11       m15 (W)  |   <- Homogeneous Coordinate
      # ---------------------------------------------
      #   ^         ^         ^          ^
      #   |         |         |          |
      # X-axis    Y-axis    Z-axis    Translation (Position)


    # A matrix can store transformations. We create one for rotation and one for translation.

    # A 2D rotation matrix (embedded in raylib's 4x4 matrix) looks like this:
    # | cos(a)  -sin(a)   0   0 |
    # | sin(a)   cos(a)   0   0 |
    # |   0        0      1   0 |
    # |   0        0      0   1 |
    # where 'a' is the angle. `rotateZ` creates this for us.

        # The `rotateZ` function creates a matrix where the X and Y axis columns
    # are rotated around the Z axis. For an angle 'a', the first two columns become:
    # X-axis column: (cos(a), sin(a), 0)
    # Y-axis column: (-sin(a), cos(a), 0)

    let rotationMatrix = rotateZ(angleInRadians)
    
    # We create a matrix that will move our shape to its world position.
    # A translation matrix looks like this, storing the translation in the last row:
    # |   1     0     0     0 |
    # |   0     1     0     0 |
    # |   0     0     1     0 |
    # |  tx    ty    tz     1 |
    # where (tx, ty, tz) is the amount to move.

    # The `translate` function creates an "identity" matrix (which does nothing)
    # and then puts the translation values into the 4th row.. 
    # X-axis: (1, 0, 0)
    # Y-axis: (0, 1, 0)
    # Z-axis: (0, 0, 1)
    # Position: (worldPosition.x, worldPosition.y, 0)

    let translationMatrix = translate(worldPosition.x, worldPosition.y, 0)

    # LESSON 2: COMBINE MATRICES
    # The power of matrices is that they can be multiplied together to combine their
    # transformations. The order matters! We rotate first, then translate.
    # `multiply(A, B)` creates a new matrix that represents doing transform A, then B.
    # The resulting `modelMatrix` now contains the rotated axes from the rotationMatrix
    # AND the position offset from the translationMatrix, all in one place.

    let modelMatrix = multiply(rotationMatrix, translationMatrix)

    # LESSON 3: TRANSFORM VERTICES
    # Now, we apply our single, combined `modelMatrix` to each vertex.
    # The `transform` function performs the matrix-vector multiplication, which looks
    # like this: transformed_vector = original_vector * modelMatrix
    # This is much more efficient than doing a rotate and then an add for every vertex.

    let transformedV1 = transform(v1, modelMatrix)
    let transformedV2 = transform(v2, modelMatrix)
    let transformedV3 = transform(v3, modelMatrix)

    # We can also transform other points in the model's local space,
    # like the endpoints of its local X and Y axes.
    let localXAxisStart = Vector2(x: -40, y: 0)
    let localXAxisEnd   = Vector2(x: 40, y: 0)
    let localYAxisStart = Vector2(x: 0, y: -40)
    let localYAxisEnd   = Vector2(x: 0, y: 40)

    let worldXAxisStart = transform(localXAxisStart, modelMatrix)
    let worldXAxisEnd   = transform(localXAxisEnd, modelMatrix)
    let worldYAxisStart = transform(localYAxisStart, modelMatrix)
    let worldYAxisEnd   = transform(localYAxisEnd, modelMatrix)

    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)

    drawText("This triangle is transformed by a single matrix!", 10, 10, 20, DarkGray)
    drawText("Gray lines are local axes. Blue lines are world axes.", 10, 40, 20, DarkGray)

    # Draw the static World Space axes for reference
    let worldXStart = Vector2(x: 0, y: worldPosition.y)
    let worldXEnd = Vector2(x: screenWidth.float, y: worldPosition.y)
    drawLine(worldXStart, worldXEnd, colorAlpha(Blue, 0.4))
    let worldYStart = Vector2(x: worldPosition.x, y: 0)
    let worldYEnd = Vector2(x: worldPosition.x, y: screenHeight.float)
    drawLine(worldYStart, worldYEnd, colorAlpha(Blue, 0.4))

    drawTriangleLines(transformedV1, transformedV2, transformedV3, Maroon)
    drawCircle(worldPosition, 5, LightGray)

    # Draw the transformed local axes
    drawLine(worldXAxisStart, worldXAxisEnd, LightGray)
    drawLine(worldYAxisStart, worldYAxisEnd, LightGray)
    endDrawing()
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context
  # --------------------------------------------------------------------------------------

main()