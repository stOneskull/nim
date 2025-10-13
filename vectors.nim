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
    var direction = mousePosition - ballPosition

    # We only want to move if the mouse is a meaningful distance away from the ball
    # to prevent jittering. We can check the length of the direction vector.
    # After many attempts to find a library function, we'll do the math ourselves!
    # To avoid a slow square root calculation, we'll compare the *squared* length.
    # The squared length is simply x*x + y*y. We compare it to our threshold squared (1.0*1.0 = 1.0).
    # This is a very common and efficient technique in graphics programming.
    let lengthSq = direction.x * direction.x + direction.y * direction.y
    if lengthSq > 1.0:
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

    drawText("Move your mouse to make the ball follow!", 10, 10, 20, DarkGray)

    # Draw a line from the ball to the mouse to visualize the direction vector
    # Since `drawLineV` isn't being found, we'll fall back to the basic `drawLine`
    # function, which takes integer coordinates. We convert our vector's float
    # components to int32 for the function call.
    drawLine(ballPosition.x.int32, ballPosition.y.int32, mousePosition.x.int32, mousePosition.y.int32, LightGray)

    # Draw our ball at its current position
    # Similar to drawLine, we'll use the basic `drawCircle` function which takes
    # integer coordinates for the center.
    drawCircle(ballPosition.x.int32, ballPosition.y.int32, ballRadius, Maroon)
    endDrawing()
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context
  # --------------------------------------------------------------------------------------

main()