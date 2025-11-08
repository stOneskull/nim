# ****************************************************************************************
#
#   raylib [graphics] lesson 5 - Pixel Streams and Particles
#
#   This lesson introduces the concept of drawing with pixels to create a
#   particle system. It builds directly on the Unit Circle concept from the
#   `vectors` series.
#
#   It demonstrates:
#   - Creating a "particle" object to represent a single pixel with its own state.
#   - Using a Deque to efficiently manage a list of active particles.
#   - Emitting particles from a source (a point rotating on a unit circle).
#   - Managing two independent particle systems (a sine wave and sparks).
#   - Updating each particle's state (position, velocity, life, color) independently.
#   - Drawing particles as individual pixels (or small rectangles).
#   - Creating visual effects with particle streams.
#
# ****************************************************************************************

import raylib
import raymath
import math
import random
# We import specific procedures from the `deques` module.
# `[]` is the operator for accessing elements by index.
# `[]=` is for assigning elements by index.
# from deques import Deque, addLast, popFirst, len, `[]`, `[]=`,items
import deques

const
  screenWidth = 1000
  screenHeight = 600
  maxParticles = 800

# LESSON 1: THE PARTICLE
# We define a simple object to represent a single particle in our stream.
# It has a position, a color, and a "life" that determines how long it exists.
type
  Particle = object
    velocity: Vector2
    position: Vector2
    color: Color
    life: float32 # Remaining life in seconds

proc main =
  initWindow(screenWidth, screenHeight, "raylib [graphics] lesson 5 - Pixel Streams")
  setTargetFPS(60)
  randomize()

  # --- Visualization Setup ---
  let circleCenter = Vector2(x: 800, y: screenHeight / 2)
  let circleRadius: float32 = 100.0

  # The point where the sine wave will be drawn from.
  let graphOriginX: float32 = 550

  # We use a Deque (Double-Ended Queue) to efficiently manage the particles.
  # It's fast to add to the end and remove from the front.
  var sineWaveParticles: Deque[Particle]
  var sparkParticles: Deque[Particle]

  var angle: float32 = 0.0
  let font = getFontDefault()
  
  var frameCounter = 0
  var useFirstColor = true

  # Main game loop
  # --------------------------------------------------------------------------------------
  while not windowShouldClose():
    # Update
    # ----------------------------------------------------------------------------------
    let dt = getFrameTime()
    angle += 1.5 * dt # Increment the angle each frame to animate

    frameCounter += 1

    # LESSON 2: PARTICLE EMISSION
    # We now create a new particle every other frame to create gaps.
    if frameCounter mod 2 == 0:
      # The particle's initial Y position is determined by the sine of the current angle,
      # just like in the unit circle lesson.
      let emitterY = circleCenter.y - sin(angle) * circleRadius

      # Determine the color for this particle, alternating each time.
      var particleColor: Color
      if useFirstColor:
        particleColor = DarkGreen
      else:
        particleColor = Orange
      useFirstColor = not useFirstColor

      # Create the new particle at the graph's origin with an initial life.
      let newParticle = Particle(
        velocity: Vector2(x: -80.0, y: 0.0), # Moves left at a constant speed
        position: Vector2(x: graphOriginX, y: emitterY),
        color: particleColor,
        life: 5.0 # This particle will live for 5 seconds
      )
      sineWaveParticles.addLast(newParticle)

    # Prune the particle list if it gets too long to maintain performance.
    if sineWaveParticles.len > maxParticles:
      sineWaveParticles.popFirst()

    # LESSON 3: SINE WAVE PARTICLE UPDATE
    # We loop through all active sine wave particles and update their state.
    # We must use a `for i in 0 ..< len` loop here. This allows us to use the
    # `[]` operator to get a mutable reference to each particle, which is
    # required to modify its fields directly within the Deque.
    for i in 0 ..< sineWaveParticles.len:
      # Move the particle to the left.
      sineWaveParticles[i].position += sineWaveParticles[i].velocity * dt

      # Decrease the particle's life.
      sineWaveParticles[i].life -= dt

      # Fade the particle's color as it gets older.
      # The alpha component is based on the percentage of life remaining.
      let lifePercent = sineWaveParticles[i].life / 5.0
      sineWaveParticles[i].color.a = (lifePercent * 255).uint8

    # Remove dead particles from the front of the deque.
    while sineWaveParticles.len > 0 and sineWaveParticles[0].life <= 0:
      sineWaveParticles.popFirst()

    # Calculate the position of the rotating emitter point on the unit circle
    let pointOnCircle = Vector2(
      x: circleCenter.x + cos(angle) * circleRadius,
      y: circleCenter.y - sin(angle) * circleRadius # Y is inverted
    )

    # --- Spark Emitter ---
    # Emit a few sparks on each frame from the rotating point.
    for _ in 0..1:
      # Sparks fly off tangentially to the circle's rotation.
      let tangent = Vector2(x: -sin(angle), y: -cos(angle))
      let randomSpeed = rand(50.0 .. 150.0)
      let sparkVelocity = tangent * randomSpeed

      let newSpark = Particle(
        velocity: sparkVelocity,
        position: pointOnCircle,
        color: Yellow,
        life: rand(0.3 .. 1.1) # Sparks are short-lived
      )
      sparkParticles.addLast(newSpark)

    # --- Spark Update ---
    const gravity = 200.0
    for i in 0 ..< sparkParticles.len:
      sparkParticles[i].position += sparkParticles[i].velocity * dt
      sparkParticles[i].velocity.y += gravity * dt # Apply gravity
      sparkParticles[i].life -= dt

      # Sparks fade from yellow to red
      let lifePercent = sparkParticles[i].life / 1.2
      sparkParticles[i].color = colorFromNormalized(
        lerp(colorNormalize(Red), colorNormalize(Yellow), lifePercent))

    # Remove dead sparks
    while sparkParticles.len > 0 and sparkParticles[0].life <= 0:
      sparkParticles.popFirst()

    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)

    # --- Draw UI and Explanations ---
    drawText(font, "Pixel Streams & Particles",
             Vector2(x: 20, y: 20), 30.0, 1.0, DarkGray)
    let line1 = "A new particle is emitted every other frame."
    drawText(font, line1, Vector2(x: 20, y: 70), 20.0, 1.0, Gray)
    let line2 = "Its Y-position comes from the rotating point on the circle."
    drawText(font, line2, Vector2(x: 20, y: 95), 20.0, 1.0, Gray)
    let line3 = "Each particle then moves left and fades over time."
    drawText(font, line3, Vector2(x: 20, y: 120), 20.0, 1.0, Gray)
    let line4 = "Sparks are also emitted from the rotating point."
    drawText(font, line4, Vector2(x: 20, y: 145), 20.0, 1.0, Gray)

    # --- Draw Unit Circle Visualization ---
    drawCircleLines(circleCenter, circleRadius, LightGray)
    drawCircle(pointOnCircle, 8.0, Black)

    # --- Draw the Connecting Line ---
    let lineStart = Vector2(x: pointOnCircle.x, y: pointOnCircle.y)
    let lineEnd = Vector2(x: graphOriginX, y: pointOnCircle.y)
    drawLine(lineStart, lineEnd, 2.0, colorAlpha(DarkGreen, 0.4))

    # LESSON 4: DRAWING THE PARTICLES
    # We loop through our list of particles and draw each one.
    # We use `drawRectangle` to make the "pixels" visible.
    for p in sineWaveParticles:
      drawRectangle(p.position.x.int32, p.position.y.int32, 2, 2, p.color)
    
    # Draw the sparks
    for p in sparkParticles:
      drawRectangle(p.position.x.int32, p.position.y.int32, 2, 2, p.color)

    endDrawing()
    # ------------------------------------------------------------------------------------

  closeWindow()

main()

#[
Key takeaways from this lesson:

- Particle Systems: A "particle system" is just a collection of many simple
  objects (particles) that are updated and drawn each frame. We can manage
  multiple, independent systems to create complex visual effects.

- State Management: Each particle has its own independent state (`position`,
  `velocity`, `life`, `color`). The core of a particle system is managing the state of
  a large number of these objects simultaneously.

- Performance: For systems with many short-lived particles, using a data
  structure like a Deque is very efficient. Adding new particles to the end
  and removing old ones from the front is much faster than removing from the
  middle of a standard sequence or array.
]#
