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
    let angleInRadians = rotation.degToRad

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
    # A translation matrix stores the translation values in the final column:
    # | 1  0  0  tx |
    # | 0  1  0  ty |
    # | 0  0  1  tz |
    # | 0  0  0  1  |
    # where (tx, ty, tz) is the amount to move. This is the m12, m13, m14 part of the matrix.

    # The `translate` function creates an "identity" matrix (which does nothing)
    # and then puts the translation values into the 4th column.
    # X-axis: (1, 0, 0)
    # Y-axis: (0, 1, 0)
    # Z-axis: (0, 0, 1)
    # Translation Column: (worldPosition.x, worldPosition.y, 0)

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

    # To better visualize the transformation, we can define lines representing
    # the model's own local X and Y axes. The "model" is the triangle in its
    # original, untransformed state, centered at (0,0). This is its "local space".
    # These lines will be transformed by the exact same modelMatrix as the triangle
    # to show how the model's coordinate system is oriented in the world.
    const axisLength = 40.0
    let localXAxisStart = Vector2(x: -axisLength, y: 0) # A line from -40 to +40 on the local X-axis
    let localXAxisEnd   = Vector2(x:  axisLength, y: 0)
    let localYAxisStart = Vector2(x: 0, y: -axisLength) # A line from -40 to +40 on the local Y-axis
    let localYAxisEnd   = Vector2(x: 0, y:  axisLength)

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

    # Draw the static World Space axes (the blue lines) for reference.
    # These lines represent the fixed coordinate system of the screen/world.
    # They do not move or rotate.
    # The alpha value controls opacity. 1.0 is fully opaque, 0.0 is fully transparent.
    const axisAlpha = 0.4
    let worldXStart = Vector2(x: 0, y: worldPosition.y)
    let worldXEnd = Vector2(x: screenWidth.float, y: worldPosition.y)
    # 2.0 for line thickness
    drawLine(worldXStart, worldXEnd, 2.0, colorAlpha(Blue, axisAlpha))
    let worldYStart = Vector2(x: worldPosition.x, y: 0)
    let worldYEnd = Vector2(x: worldPosition.x, y: screenHeight.float)
    drawLine(worldYStart, worldYEnd, 2.0, colorAlpha(Blue, axisAlpha))
    
    # Draw the triangle's vertices after they have been transformed into world space.
    const centerMarkerRadius = 5.0
    drawTriangleLines(transformedV1, transformedV2, transformedV3, Maroon)
    # Draw a marker at the pivot point to make the center of the transformation visible.
    drawCircle(worldPosition, centerMarkerRadius, LightGray)

    # Draw the transformed local axes (the gray lines).
    # These represent the triangle's own coordinate system (its "Model Space").
    # By applying the same modelMatrix, we can see how the model's personal
    # X and Y axes are oriented in the world. Notice they rotate with the triangle.
    drawLine(worldXAxisStart, worldXAxisEnd, 2.0, LightGray)
    drawLine(worldYAxisStart, worldYAxisEnd, 2.0, LightGray)
    endDrawing()
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context
  # --------------------------------------------------------------------------------------

main()