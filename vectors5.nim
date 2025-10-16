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
  DEG2RAD = PI / 180.0

proc main =
  initWindow(screenWidth, screenHeight, "raylib [vectors] lesson 5 - SRT")
  setTargetFPS(60)

  # LESSON 1: OBJECT DESCRIPTION (MODEL SPACE)
  # An object is just a list of vertices (points) that describe its shape.
  # These are defined in "Model Space", meaning they are relative to the object's
  # own center (0,0), not the world.
  let triangleVertices = [
    Vector2(x:  0.0, y: -30.0),
    Vector2(x: -30.0, y:  30.0),
    Vector2(x:  30.0, y:  30.0)
  ]

  let quadVertices = [
    Vector2(x: -25.0, y: -25.0),
    Vector2(x:  25.0, y: -25.0),
    Vector2(x:  25.0, y:  25.0),
    Vector2(x: -25.0, y:  25.0)
  ]

  # LESSON 2: THE UNDERLYING SPACE (WORLD SPACE)
  # We can place multiple objects in our world. Each needs its own position.
  let triangleWorldPos = Vector2(x: screenWidth * 0.25, y: screenHeight / 2.0)
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

    # 1. The Rotation Matrix: Rotates the object around its own origin.
    # For 2D, this is a rotation around the Z-axis.
    let rotationMatrix: Matrix = rotateZ(triRotation * DEG2RAD)

    # 2. The Translation Matrix: Moves the object to its final position in the world.
    let triTranslationMatrix: Matrix = translate(triangleWorldPos.x, triangleWorldPos.y, 0.0)

    # Combine them: Rotate first, then translate.
    # The standard SRT (Scale, Rotate, Translate) order is achieved by multiplying
    # the matrices in the reverse order: T * R * S.
    let triangleModelMatrix: Matrix = multiply(rotationMatrix, triTranslationMatrix)

    # --- Quad: Scaling and Translation ---
    # Create a "pulsing" scale effect using the sine function.
    let scaleFactor = 1.0 + sin(time * 2.0) * 0.4

    # 3. The Scaling Matrix: Stretches or shrinks the object from its origin.
    # It looks like this, with scale factors on the diagonal:
    # | sx  0   0   0 |
    # | 0   sy  0   0 |
    # | 0   0   sz  0 |
    # | 0   0   0   1 |
    let scalingMatrix: Matrix = scale(scaleFactor, scaleFactor, 1.0)

    # It needs its own translation matrix to move it to its world position.
    let quadTranslationMatrix: Matrix = translate(quadWorldPos.x, quadWorldPos.y, 0.0)

    # Combine them using the correct SRT order: Scale first, then Translate.
    # To achieve the effect of "Scale, then Translate", we must multiply the matrices
    # as M_model = M_scale * M_translate.
    let quadModelMatrix: Matrix = multiply(scalingMatrix, quadTranslationMatrix)

    # LESSON 4: TRANSFORMING THE VERTICES (CPU-side)
    # We apply the final combined matrix to each vertex of each shape.
    let transformedTriV1 = transform(triangleVertices[0], triangleModelMatrix)
    let transformedTriV2 = transform(triangleVertices[1], triangleModelMatrix)
    let transformedTriV3 = transform(triangleVertices[2], triangleModelMatrix)


    # For clarity and scalability, let's put the transformed quad vertices into an array.
#[  let transformedQuadV1 = transform(quadVertices[0], quadModelMatrix)
    let transformedQuadV2 = transform(quadVertices[1], quadModelMatrix)
    let transformedQuadV3 = transform(quadVertices[2], quadModelMatrix)
    let transformedQuadV4 = transform(quadVertices[3], quadModelMatrix) ]#
    var transformedQuadVertices: array[4, Vector2]
    for i, v in quadVertices:
      transformedQuadVertices[i] = transform(v, quadModelMatrix)

    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)

    drawText("Rotation + Translation", triangleWorldPos.x.int32 - 100, 50, 20, DarkGray)
    drawTriangleLines(transformedTriV1, transformedTriV2, transformedTriV3, Maroon)

    drawText("Scaling + Translation", quadWorldPos.x.int32 - 100, 50, 20, DarkGray)
    # Use `drawPolygonLines` for a more robust way to draw the quad's outline.
    # Since `drawPolyLinesEx` isn't found, we'll draw the quad with four `drawLine` calls.

  #[  
    drawLine(transformedQuadV1.x.int32, transformedQuadV1.y.int32, transformedQuadV2.x.int32,       transformedQuadV2.y.int32, DarkBlue)
    drawLine(transformedQuadV2.x.int32, transformedQuadV2.y.int32, transformedQuadV3.x.int32, transformedQuadV3.y.int32, DarkBlue)
    drawLine(transformedQuadV3.x.int32, transformedQuadV3.y.int32, transformedQuadV4.x.int32, transformedQuadV4.y.int32, DarkBlue)
    drawLine(transformedQuadV4.x.int32, transformedQuadV4.y.int32, transformedQuadV1.x.int32, transformedQuadV1.y.int32, DarkBlue) 
    ]#

    for i in 0 ..< transformedQuadVertices.len:
      let startPoint = transformedQuadVertices[i]
      # Use the modulo operator to wrap around and connect the last vertex to the first.
      let endPoint = transformedQuadVertices[(i + 1) mod transformedQuadVertices.len]
      drawLine(startPoint.x.int32, startPoint.y.int32, endPoint.x.int32, endPoint.y.int32, DarkBlue)

    drawText("Each object has its own vertices (Model Space) and its own transformation matrix.", 10, screenHeight - 30, 15, Gray)

    endDrawing()
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow()
  # --------------------------------------------------------------------------------------

main()

#[ Think of it like a "connect-the-dots" puzzle.

Your original shape (quadVertices) is the set of numbered dots on the page in their starting positions.
The transformation matrix (quadModelMatrix) is a set of instructions that tells you where to move each individual dot.
The drawing functions (drawLine in your case) are you, with a pencil, drawing straight lines between the new positions of the dots.
The matrix itself has no concept of a "line"; it only knows how to take an input point (x, y) and output a new point (x', y'). ]#