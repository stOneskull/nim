# ****************************************************************************************
#
#   raylib [graphics] lesson 6 - Fireworks!
#
#   This lesson builds on the particle system from the previous lesson to create
#   a multi-stage firework effect.
#
#   It demonstrates:
#   - Hierarchical particle systems (particles creating other particles).
#   - Managing different particle types (Rocket vs. Spark) with an enum.
#   - Triggering events based on a particle's state (e.g., exploding at peak).
#   - Using randomness to create organic, varied visual effects.
#   - Handling user input (mouse clicks) to trigger particle events.
#
# ****************************************************************************************

import raylib
import raymath
import math
import random
# We import specific procedures from the `deques` module.
# `[]` and `[]=` are the operators for accessing and assigning elements by index.
from deques import Deque, addLast, popFirst, popLast, len, `[]`, items, `[]=`

const
  screenWidth = 800
  screenHeight = 600

# LESSON 1: PARTICLE TYPES
# To create fireworks, we need different kinds of particles.
# A 'Rocket' flies up, and a 'Spark' is part of the explosion.
type
  ParticleType = enum
    Rocket, Spark

  Particle = object
    pType: ParticleType
    position: Vector2
    velocity: Vector2
    color: Color
    life: float32

# --- Helper Procedures ---

# A procedure to create a firework explosion at a given position.
proc createExplosion(particles: var Deque[Particle], position: Vector2, baseColor: Color) =
  let sparkCount = rand(80..150)
  for _ in 0 ..< sparkCount:
    let angle = rand(0.0 .. TAU) # Random angle for the spark to fly out
    let speed = rand(50.0 .. 250.0) # Random initial speed
    let sparkVelocity = Vector2(x: cos(angle) * speed, y: sin(angle) * speed)

    let newSpark = Particle(
      pType: Spark,
      position: position,
      velocity: sparkVelocity,
      color: baseColor,
      life: rand(1.0 .. 2.5) # Sparks fade out over 1-2.5 seconds
    )
    particles.addLast(newSpark)

proc main =
  initWindow(screenWidth, screenHeight, "raylib [graphics] lesson 6 - Fireworks")
  setTargetFPS(60)
  randomize()

  var particles: Deque[Particle]
  let font = getFontDefault()

  # A list of colors for our fireworks to choose from.
  let colors = [Red, Orange, Yellow, Green, Blue, Purple, Pink]

  # Main game loop
  # --------------------------------------------------------------------------------------
  while not windowShouldClose():
    # Update
    # ----------------------------------------------------------------------------------
    let dt = getFrameTime()

    # LESSON 2: LAUNCHING FIREWORKS
    # When the user clicks, launch a new 'Rocket' particle from the bottom.
    if isMouseButtonPressed(MouseButton.Left):
      let mousePos = getMousePosition()
      
      # The rocket aims for the mouse position.
      let startPos = Vector2(x: screenWidth / 2, y: screenHeight.float)
      let direction = normalize(mousePos - startPos)
      let speed = rand(450.0 .. 550.0)

      let newRocket = Particle(
        pType: Rocket,
        position: startPos,
        velocity: direction * speed,
        color: White, # Make rocket more visible
        life: 2.0 # Rockets have a max lifetime to ensure they explode
      )
      particles.addLast(newRocket)

    # LESSON 3: PARTICLE UPDATE
    const gravity = 280.0
    var i = 0
    while i < particles.len:
      # Apply velocity and gravity
      particles[i].position += particles[i].velocity * dt
      particles[i].velocity.y += gravity * dt
      particles[i].life -= dt

      # Check for state changes
      if particles[i].pType == Rocket and particles[i].velocity.y > 0:
        # The rocket has reached its peak (velocity.y is now positive/downward).
        # Time to explode!
        let explosionPos = particles[i].position
        let explosionColor = colors[rand(0 ..< colors.len)]
        createExplosion(particles, explosionPos, explosionColor)
        
        # Mark the rocket as dead so it gets removed.
        particles[i].life = -1.0

      # Fade the sparks over their lifetime
      if particles[i].pType == Spark:
        let lifePercent = particles[i].life / 2.5
        particles[i].color.a = (lifePercent * 255).uint8

      if particles[i].life <= 0:
        # This is an efficient way to remove an item from a sequence
        # while iterating, by swapping it with the last item.
        particles[i] = particles[particles.len - 1]
        particles.popLast()
        # Do not increment `i`, as we need to process the swapped-in particle.
      else:
        i += 1

    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(Black)

    # --- Draw UI ---
    drawText(font, "Click to launch a firework!", 
             Vector2(x: 20, y: 20), 20.0, 1.0, Gray)

    # LESSON 4: DRAWING THE PARTICLES
    for p in particles:
      if p.pType == Rocket:
        # Draw rockets as small, bright rectangles
        drawRectangle(p.position.x.int32, p.position.y.int32, 3, 3, p.color)
      else: # It's a Spark
        # Draw sparks as single pixels
        drawPixel(p.position.x.int32, p.position.y.int32, p.color)

    endDrawing()
    # ------------------------------------------------------------------------------------

  closeWindow()

main()

#[
Key takeaways from this lesson:

- Particle Hierarchies: A single "parent" particle (the rocket) can trigger the
  creation of many "child" particles (the sparks). This is a fundamental
  pattern for creating complex effects like explosions, trails, and impacts.

- State-Driven Events: We monitor the state of each particle (its type and
  velocity) to trigger new events. The firework explodes not after a fixed
  time, but when its physics state changes (it reaches its apex).

- Efficient Removal: When removing items from a list while iterating, the
  "swap with last and pop" technique is much more efficient for large lists
  than removing from the middle, as it avoids shifting all subsequent elements.
]#
