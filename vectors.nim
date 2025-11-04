# ****************************************************************************************
#
#   raylib [vectors] lesson 1 - Vector normalization and movement
#
#   This lesson demonstrates:
#   - Storing position with Vector2
#   - Calculating a direction vector between two points
#   - Normalizing a vector to get a "unit vector" (length of 1)
#   - Moving an object at a constant speed in that direction
#
# ****************************************************************************************

import raylib
import raymath # We need this module for vector functions like normalize()

const
  screenWidth = 800
  screenHeight = 450

proc main =
  initWindow(screenWidth, screenHeight, "raylib [vectors] lesson 1 - normalization")
  setTargetFPS(60)

  # LESSON 1: VECTORS AND POSITION
  # A Vector2 is a structure with two fields: x and y.
  # We can use it to represent a point in 2D space.
  # Let's create a vector to hold our ball's position, starting it in the center of the screen.
  var ballPosition = Vector2(x: screenWidth / 2.0, y: screenHeight / 2.0)
  let ballRadius = 20.0'f32
  let ballSpeed = 4.0'f32

  # Main game loop
  # --------------------------------------------------------------------------------------
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ----------------------------------------------------------------------------------
    # Get the mouse position on the screen. This is also a Vector2!
    let mousePosition = getMousePosition()

    # LESSON 2: DIRECTION VECTOR
    # To find the direction from the ball to the mouse, we subtract the ball's position
    # from the mouse's position. This gives us a new vector that "points" from the ball to the mouse.
    # The length (magnitude) of this vector is the distance between the two points.
    # (ball position + ? == mouse position.. so ? == mouse position - ball position)
    var direction = mousePosition - ballPosition

    const deadZoneRadius = 2.0 # We want a small "dead zone" of 2 pixels.
    const deadZoneRadiusSq = deadZoneRadius * deadZoneRadius # Compare squared values to avoid sqrt().

    # We only want to move if the mouse is a meaningful distance away from the ball
    # to prevent jittering. We can check the length of the direction vector.
    # To avoid a slow square root calculation, we'll compare the *squared* length.
    let lengthSq = direction.x * direction.x + direction.y * direction.y
    if lengthSq > deadZoneRadiusSq: # This is an efficient way of saying "if distance > deadZoneRadius"
      # LESSON 3: VECTOR NORMALIZATION
      # The `direction` vector has a variable length. If we used it for movement directly,
      # the ball would move faster the further the mouse is from it.
      # To get a *constant speed*, we need a pure direction vector with a length of 1.
      # This is called a "unit vector", and we get it by "normalizing" the vector.
      # `naylib` provides a `normalize` operator for this.
      let normalizedDir = normalize(direction)

      # LESSON 4: SCALAR MULTIPLICATION
      # Now that we have a direction (the unit vector), we can multiply it by a
      # single number (a "scalar") to get our desired speed.
      let velocity = normalizedDir * ballSpeed

      # Finally, we update the ball's position by adding the velocity.
      # This moves the ball `ballSpeed` pixels in the direction of the mouse each frame.
      ballPosition += velocity

    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)

    # A note on screen coordinates: The window's origin (0,0) is at the top-left corner.
    # The X-axis increases to the right, and the Y-axis increases downwards.
    # Therefore, drawing at (10, 10) places the text near the top-left.
    # drawText(text, posX, posY, fontSize, color)
    drawText("Move your mouse to make the ball follow!", 10, 10, 20, DarkGray)

    # Draw a line from the ball to the mouse to visualize the direction vector
    # Rather than having a separate `drawLineV`, raylib-nim overloads `drawLine` 
    # to accept Vector2s directly.
    drawLine(ballPosition, mousePosition, LightGray)

    # Draw our ball at its current position
    # `drawCircle` is also overloaded to accept a Vector2 for the center.
    drawCircle(ballPosition, ballRadius, Maroon)
    endDrawing()
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context
  # --------------------------------------------------------------------------------------

main()