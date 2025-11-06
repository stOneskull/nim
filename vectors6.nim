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

proc main =
  initWindow(screenWidth, screenHeight, "raylib [vectors] lesson 6 - Pew Pew!")
  setTargetFPS(60)

  # Define the screen boundaries as a rectangle for collision checks.
  let screenBounds = Rectangle(x: 0, y: 0, width: screenWidth, height: screenHeight)

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
  # These variables manage the "hit" feedback for the quad.
  var quadColor = DarkBlue
  # When the quad is hit, this cooldown is set. It counts down each frame.
  var quadHitCooldown: float32 = 0.0 
  const hitDisplayTime: float32 = 0.5 # How long the quad stays red (in seconds)

  # LESSON 1: BULLET STATE
  # We need variables to track the bullet's state: its activity, position, and velocity.
  var bulletActive = false
  var bulletPos: Vector2
  var bulletVelocity: Vector2
  # The 'f32 suffix is a shorthand to create a float32 literal.
  # Nim's type inference automatically makes `bulletSpeed` a float32,
  # so we don't need to write `const bulletSpeed: float32 = ...`.
  const bulletSpeed = 400.0'f32

  # Main game loop
  # --------------------------------------------------------------------------------------
  while not windowShouldClose():
    # Update
    # ----------------------------------------------------------------------------------
    let dt = getFrameTime() # Get the time elapsed since the last frame.
    time += dt
    # Manage the quad's hit-flash effect.
    if quadHitCooldown > 0:
      quadHitCooldown -= dt
    # When the cooldown finishes, reset the color from Red back to DarkBlue.
    elif quadColor == Red:
      quadColor = DarkBlue

    # --- Triangle Transformation ---
    let triRotation = time * 50.0
    let movementFactor = (sin(time) + 1.0) / 2.0
    let startPos = triangleBasePos
    let endPos = Vector2(x: 100.0, y: screenHeight - 100.0)
    # "lerp" stands for Linear Interpolation. It finds a point on the line
    # between startPos and endPos. The movementFactor (0.0 to 1.0) determines
    # how far along that line the point is, creating smooth back-and-forth movement.
    let triangleWorldPos = lerp(startPos, endPos, movementFactor)
    let rotationMatrix: Matrix = rotateZ(triRotation.degToRad)

    # --- Quad Transformation ---
    let scaleFactor = 1.0 + sin(time * 2.0) * 0.4
    let scalingMatrix: Matrix = scale(scaleFactor, scaleFactor, 1.0)
    let quadTranslationMatrix: Matrix = translate(quadWorldPos.x, quadWorldPos.y, 0.0)
    # remember: to scale then translate, we multiply in reverse order
    let quadModelMatrix: Matrix = multiply(quadTranslationMatrix, scalingMatrix)
    # right-to-left <-
    
    # --- Vertex Transformations (using loops for clarity) ---
    # For the triangle, we use a "hybrid" method: rotate with a matrix, 
    # then translate with vector addition.
    var transformedTriVertices: array[3, Vector2]
    # In Python, we would would say 'for i, v in enumerate(triangleVertices):'
    # In Nim, the 'enumerate' is implicit because we are using 2 variables to iterate
    for i, v in triangleVertices:
      transformedTriVertices[i] = transform(v, rotationMatrix) + triangleWorldPos

    # For the quad, we use the full model matrix to transform each vertex.
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

      # To get the direction, we start with a "forward" vector in model space.
      # Since the triangle's tip points up (negative Y), our forward is (0, -1).
      let forwardVector = Vector2(x: 0.0, y: -1.0)
      # We then rotate this vector by the triangle's current rotation to get the
      # final direction in world space. This gives us a normalized direction vector.
      let direction = rotate(forwardVector, triRotation.degToRad)

      # The velocity is the direction multiplied by the speed.
      bulletVelocity = direction * bulletSpeed

    # LESSON 3: BULLET UPDATE AND COLLISION
    if bulletActive:
      # Update bullet position based on its velocity and the frame time.
      bulletPos += bulletVelocity * dt

      # Deactivate bullet if it goes off-screen. A convenient shorthand for this
      # is to use raylib's built-in function to check if the point is no longer
      # inside the screen's rectangle.
      if not checkCollisionPointRec(bulletPos, screenBounds):
        bulletActive = false

      # Check for collision between the bullet's position and the quad's vertices.
      # `checkCollisionPointPoly` is a C-style function that expects a pointer to the
      # start of the vertex array. Nim's `[]` slice operator on an array provides
      # this pointer automatically.
      if checkCollisionPointPoly(bulletPos, transformedQuadVertices):
        bulletActive = false
        quadColor = Red          # Change color on hit!
        quadHitCooldown = hitDisplayTime # Start the cooldown timer.

    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)

    # --- Draw UI ---
    drawText("Press [Space] to fire!", 10, 10, 20, LightGray)

    # --- Draw Shapes ---
    drawTriangleLines(
      transformedTriVertices[0], transformedTriVertices[1], transformedTriVertices[2], Maroon)

    for i in 0 ..< transformedQuadVertices.len:
      drawLine(
        transformedQuadVertices[i], transformedQuadVertices[(i + 1) mod 4], 2.0, quadColor)

    # LESSON 4: DRAWING THE BULLET
    # Only draw the bullet if it's active.
    if bulletActive:
      drawCircle(bulletPos, 5.0, Black)

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
