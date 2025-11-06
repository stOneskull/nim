# ****************************************************************************************
#
#   raylib [vectors] lesson 5 - The Transformation Trinity
#
#   This lesson demonstrates:
#   - The three fundamental transformations: Scale, Rotate, Translate.
#   - The matrix representation for each transformation.
#   - The difference between an object's description (Model Space) and the
#     underlying scene (World Space).
#   - How multiple objects can be transformed independently in the same space.
#
# ****************************************************************************************

import raylib
import raymath
import math

const
  screenWidth = 800
  screenHeight = 450

proc main =
  initWindow(screenWidth, screenHeight, "raylib [vectors] lesson 5 - SRT")
  setTargetFPS(60)

  # LESSON 1: OBJECT DESCRIPTION (MODEL SPACE)
  # An object is just a list of vertices (points) that describe its shape.
  # These are defined in "Model Space", meaning they are relative to the object's
  # own center (0,0), not the world.
  let triangleVertices = [
    Vector2(x: 0.0, y: -30.0),
    Vector2(x: -30.0, y: 30.0),
    Vector2(x: 30.0, y: 30.0)
  ]

  let quadVertices = [
    Vector2(x: -25.0, y: -25.0),
    Vector2(x: 25.0, y: -25.0),
    Vector2(x: 25.0, y: 25.0),
    Vector2(x: -25.0, y: 25.0)
  ]

  # LESSON 2: THE UNDERLYING SPACE (WORLD SPACE)
  # We can place multiple objects in our world. Each needs its own position.
  let triangleBasePos = Vector2(x: screenWidth * 0.25, y: screenHeight / 2.0)
  let quadWorldPos = Vector2(x: screenWidth * 0.75, y: screenHeight / 2.0)

  var time: float32 = 0.0

  # Main game loop
  # --------------------------------------------------------------------------------------
  while not windowShouldClose():
    # Update
    # ----------------------------------------------------------------------------------
    time += getFrameTime() # Accumulate time for smooth animation

    # LESSON 3: THE TRANSFORMATION MATRICES
    # We will create a unique transformation matrix for each object.

    # --- Triangle: Rotation and Translation ---
    let triRotation = time * 50.0 # Degrees

    # Create a diagonal movement from the base position towards the bottom-left.
    # The sin() function oscillates between -1.0 and 1.0. To use it for linear
    # interpolation (which needs a 0.0 to 1.0 factor), we must remap its range.
    # 1. Add 1.0 to shift the range from [-1, 1] to [0, 2].
    # 2. Divide by 2.0 to scale the range from [0, 2] to [0, 1].
    let movementFactor = (sin(time) + 1.0) / 2.0
    let startPos = triangleBasePos
    let endPos = Vector2(x: 100.0, y: screenHeight - 100.0)
    # "lerp" stands for Linear Interpolation. It finds a point on the line
    # between startPos and endPos. The movementFactor (0.0 to 1.0) determines
    # how far along that line the point is, creating smooth movement.
    let triangleWorldPos = lerp(startPos, endPos, movementFactor)

    # 1. The Rotation Matrix: Rotates the object around its own origin.
    # For 2D, this is a rotation around the Z-axis.
    # The `.degToRad` is a convenient converter provided by the `math` module.
    # `triRotation.degToRad` is equivalent to calling `degToRad(triRotation)`.
    let rotationMatrix: Matrix = rotateZ(triRotation.degToRad)

    # 2. The Translation: This is handled by vector addition later on (see LESSON 4).
    # --- Quad: Scaling and Translation ---
    # Create a "pulsing" scale effect using the sine function.
    const pulseFrequency = 2.0 # How fast the pulse is.
    const pulseAmplitude = 0.4 # How intense the pulse is (from 0.0 to 1.0).
    let scaleFactor = 1.0 + sin(time * pulseFrequency) * pulseAmplitude

    # 3. The Scaling Matrix: Stretches or shrinks the object from its origin.
    # It looks like this, with scale factors on the diagonal:
    # | sx  0   0   0 |
    # | 0   sy  0   0 |
    # | 0   0   sz  0 |
    # | 0   0   0   1 |
    # Even in 2D, raylib uses a 4x4 matrix, so we provide a Z-scale of 1.0
    # to signify "no change" on the unused Z-axis.
    # The 'W' component in the bottom-right is implicitly set to 1.0 by the `scale`
    # function itself, as this is required for a standard affine transformation matrix.
    # We only need to provide the arguments the function asks for (sx, sy, sz).
    let scalingMatrix: Matrix = scale(scaleFactor, scaleFactor, 1.0)

    # 4. The Translation Matrix: Moves the object to its final world position.
    let quadTranslationMatrix: Matrix = translate(quadWorldPos.x, quadWorldPos.y, 0.0)

    # Combine them into a single Model Matrix.
    # IMPORTANT: Matrix multiplication order is the reverse of the transformation order.
    # To achieve the effect of "1. Scale, then 2. Translate", we must multiply
    # the matrices as `M_translate * M_scale`.
    let quadModelMatrix: Matrix = multiply(quadTranslationMatrix, scalingMatrix)
    
    # LESSON 4: TRANSFORMING THE VERTICES (CPU-side)
    # For the triangle, we'll demonstrate a "hybrid" transformation approach.
    # This is different from the full matrix method in vectors3.nim.
    # Step 1: Rotate the vertex in its local space using the rotation matrix.
    # Step 2: Translate the now-rotated vertex to its world position by adding the position vector.
    # This method can be more intuitive for simple cases but is less scalable than
    # using a single, combined model matrix for all transformations.
    let transformedTriV1 = transform(triangleVertices[0], rotationMatrix) + triangleWorldPos
    let transformedTriV2 = transform(triangleVertices[1], rotationMatrix) + triangleWorldPos
    let transformedTriV3 = transform(triangleVertices[2], rotationMatrix) + triangleWorldPos

    # For clarity and scalability, let's put the transformed quad vertices into an array.
#[  let transformedQuadV1 = transform(quadVertices[0], quadModelMatrix)
    let transformedQuadV2 = transform(quadVertices[1], quadModelMatrix)
    let transformedQuadV3 = transform(quadVertices[2], quadModelMatrix)
    let transformedQuadV4 = transform(quadVertices[3], quadModelMatrix) ]#
    # For the quad, we use the full model matrix and loop through the vertices.
    var transformedQuadVertices: array[4, Vector2]
    for i, v in quadVertices:
      # This loop is the Nim equivalent of Python's `for i, v in enumerate(...)`.
      transformedQuadVertices[i] = transform(v, quadModelMatrix)

    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)

    drawText("Rotation + Translation", triangleBasePos.x.int32 - 100, 50, 20, DarkGray)
    drawTriangleLines(transformedTriV1, transformedTriV2, transformedTriV3, Maroon)

    drawText("Scaling + Translation", quadWorldPos.x.int32 - 100, 50, 20, DarkGray)
    
    # Draw the quad's outline by connecting its transformed vertices.
    for i in 0 ..< transformedQuadVertices.len:
      let startPoint = transformedQuadVertices[i]
      # The modulo operator (%) ensures that the last vertex (index 3) connects
      # back to the first vertex (index 0), closing the shape. (3 + 1) mod 4 = 0.
      let endPoint = transformedQuadVertices[(i + 1) mod 4]
      drawLine(startPoint, endPoint, 2.0, DarkBlue)

    drawText("Each object has its own vertices (Model Space) and its own " &
             "transformation matrix.", 10, screenHeight - 30, 17, Gray)

    endDrawing()
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow()
  # --------------------------------------------------------------------------------------

main()

#[ Think of it like a "connect-the-dots" puzzle.

Your original shape (quadVertices) is the set of numbered dots on the page 
in their starting positions.
The transformation matrix (quadModelMatrix) is a set of instructions 
that tells you where to move each individual dot.
The drawing functions (drawLine in your case) are you, with a pencil, 
drawing straight lines between the new positions of the dots.
The matrix itself has no concept of a "line"; 
it only knows how to take an input point (x, y) and output a new point (x', y'). ]#