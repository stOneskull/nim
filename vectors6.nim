# ****************************************************************************************
#
#   raylib [vectors] lesson 6 - Interactivity and State
#
#   This lesson demonstrates:
#   - Handling user input to trigger actions.
#   - Managing the state of dynamic objects (e.g., a bullet).
#   - Calculating directional vectors for movement.
#   - Basic collision detection between a point and a polygon.
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
  initWindow(screenWidth, screenHeight, "raylib [vectors] lesson 6 - Pew Pew!")
  setTargetFPS(60)

  # --- Model Space Definitions ---
  let triangleVertices = [
    Vector2(x:  0.0, y: -30.0), # Tip of the "ship"
    Vector2(x: -25.0, y:  30.0),
    Vector2(x:  25.0, y:  30.0)
  ]

  let quadVertices = [
    Vector2(x: -25.0, y: -25.0),
    Vector2(x:  25.0, y: -25.0),
    Vector2(x:  25.0, y:  25.0),
    Vector2(x: -25.0, y:  25.0)
  ]

  # --- World Space Positions ---
  let triangleBasePos = Vector2(x: screenWidth * 0.25, y: screenHeight / 2.0)
  let quadWorldPos = Vector2(x: screenWidth * 0.75, y: screenHeight / 2.0)

  # --- Game State Variables ---
  var time: float32 = 0.0
  var quadColor = DarkBlue
  var quadHitCooldown: float32 = 0.0
  const hitDisplayTime: float32 = 0.5 # How long the quad stays red (in seconds)

  # LESSON 1: BULLET STATE
  # We need variables to track the bullet's state: its activity, position, and velocity.
  var bulletActive = false
  var bulletPos: Vector2
  var bulletVelocity: Vector2
  const bulletSpeed: float32 = 400.0

  # Main game loop
  # --------------------------------------------------------------------------------------
  while not windowShouldClose():
    # Update
    # ----------------------------------------------------------------------------------
    time += getFrameTime()
    if quadHitCooldown > 0:
      quadHitCooldown -= getFrameTime()
    elif quadColor == Red:
      quadColor = DarkBlue

    # --- Triangle Transformation ---
    let triRotation = time * 50.0
    let movementFactor = (sin(time) + 1.0) / 2.0
    let startPos = triangleBasePos
    let endPos = Vector2(x: 100.0, y: screenHeight - 100.0)
    let triangleWorldPos = lerp(startPos, endPos, movementFactor)
    let rotationMatrix: Matrix = rotateZ(triRotation * DEG2RAD)

    # --- Quad Transformation ---
    let scaleFactor = 1.0 + sin(time * 2.0) * 0.4
    let scalingMatrix: Matrix = scale(scaleFactor, scaleFactor, 1.0)
    let quadTranslationMatrix: Matrix = translate(quadWorldPos.x, quadWorldPos.y, 0.0)
    let quadModelMatrix: Matrix = multiply(quadTranslationMatrix, scalingMatrix)
    
    # --- Vertex Transformations (using loops for clarity) ---
    var transformedTriVertices: array[3, Vector2]
    for i, v in triangleVertices:
      transformedTriVertices[i] = transform(v, rotationMatrix) + triangleWorldPos
    var transformedQuadVertices: array[4, Vector2]
    for i, v in quadVertices:
      transformedQuadVertices[i] = transform(v, quadModelMatrix)

    # LESSON 2: INPUT HANDLING AND FIRING
    # Check if the space key is pressed and if there isn't already an active bullet.
    if isKeyPressed(Space) and not bulletActive:
      bulletActive = true
      # The bullet starts at the tip of the triangle. The tip is the first vertex,
      # so we use its transformed position.
      bulletPos = transformedTriVertices[0]

      # To get the direction, we rotate a "forward" vector (0, -1) by the triangle's
      # current rotation. This gives us a normalized direction vector.
      let forwardVector = Vector2(x: 0.0, y: -1.0)
      let direction = rotate(forwardVector, triRotation * DEG2RAD)

      # The velocity is the direction multiplied by the speed.
      bulletVelocity = direction * bulletSpeed

    # LESSON 3: BULLET UPDATE AND COLLISION
    if bulletActive:
      # Update bullet position based on its velocity and the frame time.
      bulletPos += bulletVelocity * getFrameTime()

      # Deactivate bullet if it goes off-screen
      if bulletPos.x < 0 or bulletPos.x > screenWidth.float or
         bulletPos.y < 0 or bulletPos.y > screenHeight.float:
        bulletActive = false

      # Check for collision between the bullet's position and the quad's vertices.
      # `checkCollisionPointPoly` requires a pointer to the start of the vertex array.
      if checkCollisionPointPoly(bulletPos, transformedQuadVertices):
        bulletActive = false
        quadColor = Red          # Change color on hit!
        quadHitCooldown = hitDisplayTime # Start the cooldown timer.

    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)

    # --- Draw UI and Titles ---
    # drawText("Rotation + Translation", triangleBasePos.x.int32 - 100, 50, 20, DarkGray)
    # drawText("Scaling + Translation", quadWorldPos.x.int32 - 100, 50, 20, DarkGray)
    drawText("Press [Space] to fire!", 10, 10, 20, LightGray)

    # --- Draw Shapes ---
    drawTriangleLines(transformedTriVertices[0], transformedTriVertices[1], transformedTriVertices[2], Maroon)

    # `drawPolyLinesEx` is not available in all raylib-nim versions.
    # We can draw the lines manually using `drawLineEx` to control thickness.
    for i in 0 ..< transformedQuadVertices.len:
      let startPoint = transformedQuadVertices[i]
      let endPoint = transformedQuadVertices[(i + 1) mod 4]
      drawLine(startPoint.x.int32, startPoint.y.int32, endPoint.x.int32, endPoint.y.int32, quadColor)

    # LESSON 4: DRAWING THE BULLET
    # Only draw the bullet if it's active.
    if bulletActive:
      # `drawCircleV` is not in all versions; use `drawCircle` with explicit coordinates.
      drawCircle(bulletPos.x.int32, bulletPos.y.int32, 5.0, Black)

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
