# ****************************************************************************************
#
#   raylib [vectors] lesson 9 - The Unit Circle
#
#   This lesson demonstrates:
#   - The direct relationship between a point rotating on a circle and the
#     sine and cosine functions.
#   - How sin(x) corresponds to the Y-coordinate of the point.
#   - How cos(x) corresponds to the X-coordinate of the point.
#   - Animating a value over time to generate the graphs.
#
# ****************************************************************************************

import raylib
import raymath
import math
import strformat
from deques import Deque, addLast, popFirst, len, `[]`

const
  screenWidth = 1000
  screenHeight = 600
  maxWavePoints = 500

proc main =
  initWindow(screenWidth, screenHeight, "raylib [vectors] lesson 9 - The Unit Circle")
  setTargetFPS(60)

  # --- Visualization Setup ---
  let circleCenter = Vector2(x: 800, y: screenHeight / 2)
  let circleRadius = 100.0

  # Both waves will share a single origin point
  let graphOrigin = Vector2(x: 450, y: screenHeight / 2)
  let graphScale = Vector2(x: 50.0, y: 100.0) # x-scale, y-scale (amplitude)

  # We use a Deque (Double-Ended Queue) to efficiently store the wave points.
  # It lets us add to one end and remove from the other in constant time.
  var sinWavePoints: Deque[Vector2]
  var cosWavePoints: Deque[Vector2]

  var angle: float32 = 0.0
  var prevAngle: float32 = 0.0
  var isPaused = false

  # We'll update this text less frequently to make it readable.
  var frameCounter = 0
  var continuousAngleText = fmt"Continuous Angle (for graph): {angle / PI:.2f}pi rad"
  # Use `mod` from the math module for float modulo.
  let wrappedAngleRad = math.mod(angle, TAU)
  var wrappedAngleText =
    fmt"Effective Angle (for circle): {wrappedAngleRad * 360.0 / TAU:.1f}°"

  let font = getFontDefault()

  # Main game loop
  # --------------------------------------------------------------------------------------
  while not windowShouldClose():
    # Update
    # ----------------------------------------------------------------------------------
    if isKeyPressed(Space): # Manual pause/unpause has priority
      isPaused = not isPaused
      if not isPaused:
        # When we manually unpause, immediately advance the angle
        # to prevent the auto-pause from re-triggering on the same frame.
        prevAngle = angle
        angle += 0.03
    elif not isPaused: # Only run animation logic if not manually paused
      prevAngle = angle
      angle += 0.03 # Increment the angle each frame to animate

      # --- Auto-pause logic ---
      # Check if we crossed a 45-degree (PI/4) boundary
      let boundary = PI / 4.0
      let prevStep = floor(prevAngle / boundary)
      let currentStep = floor(angle / boundary)

      if currentStep > prevStep:
        # We crossed a boundary! Pause the animation.
        isPaused = true
        # Snap the angle to the boundary for perfect alignment
        angle = currentStep * boundary

      # Calculate current sin and cos values
      let sinValue = sin(angle)
      let cosValue = cos(angle)

      # Add new points to our wave history
      sinWavePoints.addLast(Vector2(x: angle, y: sinValue))
      cosWavePoints.addLast(Vector2(x: angle, y: cosValue))

      # Prune the history if it gets too long
      if sinWavePoints.len() > maxWavePoints:
        sinWavePoints.popFirst()
      if cosWavePoints.len() > maxWavePoints:
        cosWavePoints.popFirst()

    # Calculate the position of the point on the unit circle
    let pointOnCircle = Vector2(
      x: circleCenter.x + cos(angle) * circleRadius,
      y: circleCenter.y - sin(angle) * circleRadius # Y is inverted
    )

    # Update the angle text every 6 frames (10 times per second at 60 FPS)
    frameCounter += 1
    if frameCounter mod 6 == 0:
      continuousAngleText = fmt"Continuous Angle (for graph): {angle / PI:.2f}pi rad"
      # Use `mod` from math module for float modulo
      let wrappedAngleRad = math.mod(angle, TAU)
      wrappedAngleText =
        fmt"Effective Angle (for circle): {wrappedAngleRad * 360.0 / TAU:.1f}°"

    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)

    # --- Draw UI and Explanations ---
    drawText(font, "The Unit Circle and Trigonometry",
             Vector2(x: 20, y: 20), 30.0, 1.0, DarkGray)
    if isPaused:
      drawText(font, "Press [Space] to resume",
               Vector2(x: 20, y: screenHeight - 40), 20.0, 1.0, DarkGray)

      # When paused, show the exact numerical values
      # TAU is a constant equal to 2*PI, representing a full circle in radians.
      # It's often clearer than writing 2*PI everywhere.
      let angleDeg = math.mod(angle, TAU) * (360.0 / TAU)
      let sinVal = sin(angle)
      let cosVal = cos(angle)

      # Helper to format the values intelligently
      proc formatTrigValue(val: float32): string =
        const epsilon = 1e-6
        let roundedVal = round(val)
        # Check if the value is very close to a whole number
        if abs(val - roundedVal) < epsilon:
          if roundedVal == 0.0: return "0" # Explicitly handle zero to avoid "-0"
          return fmt"{roundedVal:.0f}"
        else:
          return fmt"{val:.3f}"

      let sinValText = fmt"sin({angleDeg:.0f}°) = {formatTrigValue(sinVal)}"
      let cosValText = fmt"cos({angleDeg:.0f}°) = {formatTrigValue(cosVal)}"
      drawText(font, sinValText,
               Vector2(x: graphOrigin.x - 200, y: graphOrigin.y + 100), 20.0, 1.0, Red)
      drawText(font, cosValText,
               Vector2(x: graphOrigin.x - 200, y: graphOrigin.y + 125), 20.0, 1.0, Blue)
    else:
      drawText(font, "Press [Space] to pause",
               Vector2(x: 20, y: screenHeight - 40), 20.0, 1.0, LightGray)
    drawText(font, wrappedAngleText,
             Vector2(x: circleCenter.x - 320, y: circleCenter.y + circleRadius + 20),
             20.0, 1.0, Black)
    drawText(font, continuousAngleText,
             Vector2(x: circleCenter.x - 320, y: circleCenter.y + circleRadius + 45),
             20.0, 1.0, Gray)

    # --- Draw Unit Circle Visualization (Left) ---
    drawCircleLines(circleCenter, circleRadius, LightGray)
    let xAxisStart = Vector2(x: circleCenter.x - circleRadius - 20, y: circleCenter.y)
    let xAxisEnd = Vector2(x: circleCenter.x + circleRadius + 20, y: circleCenter.y)
    drawLine(xAxisStart, xAxisEnd, LightGray) # X-axis
    let yAxisStart = Vector2(x: circleCenter.x, y: circleCenter.y - circleRadius - 20)
    let yAxisEnd = Vector2(x: circleCenter.x, y: circleCenter.y + circleRadius + 20)
    drawLine(yAxisStart, yAxisEnd, LightGray) # Y-axis

    # Draw the rotating radius line
    drawLine(circleCenter, pointOnCircle, 2.0, Black)
    drawCircle(pointOnCircle, 8.0, Black)

    # --- Draw Combined Graph Visualization ---
    drawText(font, "y = sin(angle)",
             Vector2(x: graphOrigin.x - 200, y: graphOrigin.y - 150), 20.0, 1.0, Red)
    drawText(font, "y = cos(angle)",
             Vector2(x: graphOrigin.x - 200, y: graphOrigin.y - 125), 20.0, 1.0, Blue)

    # Draw the -1, 0, and 1 horizontal lines
    let yZero = graphOrigin.y
    let yPlusOne = graphOrigin.y - 1 * graphScale.y
    let yMinusOne = graphOrigin.y + 1 * graphScale.y
    let lineStartX = graphOrigin.x - maxWavePoints
    let lineEndX = graphOrigin.x + maxWavePoints
    drawLine(Vector2(x: lineStartX, y: yZero), Vector2(x: lineEndX, y: yZero), LightGray)
    drawLine(Vector2(x: lineStartX, y: yPlusOne), Vector2(x: lineEndX, y: yPlusOne),
             colorAlpha(LightGray, 0.5))
    drawLine(Vector2(x: lineStartX, y: yMinusOne), Vector2(x: lineEndX, y: yMinusOne),
             colorAlpha(LightGray, 0.5))

    # Add labels for the horizontal lines
    let labelX = circleCenter.x + circleRadius + 20
    drawText(font, "1", Vector2(x: labelX, y: yPlusOne - 10), 20.0, 1.0, Gray)
    drawText(font, "0", Vector2(x: labelX, y: yZero - 10), 20.0, 1.0, Gray)
    drawText(font, "-1", Vector2(x: labelX, y: yMinusOne - 10), 20.0, 1.0, Gray)

    # Draw Sine Wave
    for i in 0 ..< sinWavePoints.len() - 1:
      # Draw the wave relative to the current angle, so it scrolls left.
      let p1 = Vector2(
        x: graphOrigin.x + (sinWavePoints[i].x - angle) * graphScale.x, 
        y: graphOrigin.y - sinWavePoints[i].y * graphScale.y)
      let p2 = Vector2(
        x: graphOrigin.x + (sinWavePoints[i+1].x - angle) * graphScale.x, 
        y: graphOrigin.y - sinWavePoints[i+1].y * graphScale.y)
      drawLine(p1, p2, 2.0, Red)

    # Draw Cosine Wave
    for i in 0 ..< cosWavePoints.len() - 1:
      let p1 = Vector2(
        x: graphOrigin.x + (cosWavePoints[i].x - angle) * graphScale.x, 
        y: graphOrigin.y - cosWavePoints[i].y * graphScale.y)
      let p2 = Vector2(
        x: graphOrigin.x + (cosWavePoints[i+1].x - angle) * graphScale.x, 
        y: graphOrigin.y - cosWavePoints[i+1].y * graphScale.y)
      drawLine(p1, p2, 2.0, Blue)

    # --- Draw the Connecting Lines ---
    # Line from circle's Y to the start of the sine wave
    let sinStartPoint =
      Vector2(x: graphOrigin.x, y: graphOrigin.y - sin(angle) * graphScale.y)
    drawLine(Vector2(x: pointOnCircle.x, y: pointOnCircle.y),
             Vector2(x: sinStartPoint.x, y: pointOnCircle.y), 2.0, colorAlpha(Red, 0.5))
    drawLine(Vector2(x: sinStartPoint.x, y: pointOnCircle.y),
             sinStartPoint, 2.0, colorAlpha(Red, 0.5))
    drawCircle(sinStartPoint, 5.0, Red)

    # Line from circle's X to the start of the cosine wave
    let cosStartPoint =
      Vector2(x: graphOrigin.x, y: graphOrigin.y - cos(angle) * graphScale.y)
    drawLine(Vector2(x: pointOnCircle.x, y: pointOnCircle.y),
             Vector2(x: pointOnCircle.x, y: cosStartPoint.y), 2.0, colorAlpha(Blue, 0.5))
    drawLine(Vector2(x: pointOnCircle.x, y: cosStartPoint.y),
             cosStartPoint, 2.0, colorAlpha(Blue, 0.5))
    drawCircle(cosStartPoint, 5.0, Blue)

    # --- Draw the triangle inside the circle and label the sides ---
    let projectionPoint = Vector2(x: pointOnCircle.x, y: circleCenter.y)
    # Draw the vertical "sin" side
    drawLine(pointOnCircle, projectionPoint, 2.0, Red)
    drawText(font, "sin",
             Vector2(x: pointOnCircle.x + 10,
                     y: circleCenter.y + (pointOnCircle.y - circleCenter.y)/2),
             20.0, 1.0, Red)
    # Draw the horizontal "cos" side
    drawLine(circleCenter, projectionPoint, 2.0, Blue)
    drawText(font, "cos",
             Vector2(x: circleCenter.x + (pointOnCircle.x - circleCenter.x)/2,
                     y: circleCenter.y + 10),
             20.0, 1.0, Blue)

    endDrawing()
    # ------------------------------------------------------------------------------------

  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow()
  # --------------------------------------------------------------------------------------

main()

#[
Key takeaways from this lesson:

- Sine and Cosine are geometric functions. They directly describe the coordinates
  of a point on a circle of radius 1 as it rotates.
- sin(angle) is the Y-coordinate.
- cos(angle) is the X-coordinate.
- The wave shape is what you get when you "unroll" the circle's motion over time.
- The `deques` module is very useful for managing a fixed-size list of historical
  data, like the points of our wave, because adding to one end and removing from
  the other is very fast.
]#
