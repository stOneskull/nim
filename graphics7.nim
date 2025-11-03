# ****************************************************************************************
#
#   raylib [graphics] lesson 7 - Particle Physics and Bouncing
#
#   This lesson combines particle systems with transformed polygons to create
#   a simple physics simulation.
#
#   It demonstrates:
#   - Applying gravity to particles.
#   - Detecting collisions between particles and rotated polygons.
#   - Calculating the surface normal of the polygon edge that was hit.
#   - Using vector reflection to make particles "bounce" realistically.
#   - Applying a damping factor to simulate energy loss on each bounce.
#
# ****************************************************************************************

import raylib
import raymath
import math
import random
import strformat
import rlgl # For matrix transformations
from deques import Deque, addLast, popFirst, popLast, len, `[]`, items, `[]=`

const
  screenWidth = 1000
  screenHeight = 700

# --- Type Definitions ---

type
  Particle = object
    position: Vector2
    velocity: Vector2
    color: Color
    radius: float32
    bounces: int

  PolygonCollider = object
    position: Vector2
    vertices: seq[Vector2] # Model-space vertices
    rotation: float32
    color: Color

# --- Helper Procedures ---

# Calculates the closest point on a line segment (p1 to p2) to a given point (p).
proc getClosestPointOnSegment(p, p1, p2: Vector2): Vector2 =
  let edge = p2 - p1
  let lenSq = lengthSqr(edge)
  if lenSq == 0.0: return p1 # The segment is just a point.

  # Project the point onto the line defined by the segment.
  # The 't' value is how far along the line the projection is.
  # A value of 0.0 means the closest point is p1, 1.0 means p2.
  let t = dotProduct(p - p1, edge) / lenSq

  # Clamp 't' to the 0.0 to 1.0 range to stay on the segment.
  # If t was < 0 or > 1, the closest point would be off the segment.
  let clampedT = clamp(t, 0.0'f32, 1.0'f32)
  return p1 + edge * clampedT

proc main =
  initWindow(screenWidth, screenHeight, "raylib [graphics] lesson 7 - Particle Physics")
  setTargetFPS(60)
  randomize()

  var particles: Deque[Particle]
  let font = getFontDefault()

  # A list of colors for our particles to choose from.
  let colors = [Red, Orange, Yellow, Green, Blue, Purple, Pink]

  # LESSON 1: CREATING COLLIDERS
  # These are static polygons that our particles will bounce off of.
  # We define their shapes as simple rectangles in their own model space.
  var colliders = @[
    PolygonCollider(
      position: Vector2(x: screenWidth / 2, y: screenHeight - 50),
      vertices: @[
        Vector2(x: -400, y: -25), Vector2(x: 400, y: -25),
        Vector2(x: 400, y: 25), Vector2(x: -400, y: 25)
      ],
      rotation: 0.0,
      color: DarkGray
    ),
    PolygonCollider(
      position: Vector2(x: 200, y: 450),
      vertices: @[
        Vector2(x: -150, y: -15), Vector2(x: 150, y: -15),
        Vector2(x: 150, y: 15), Vector2(x: -150, y: 15)
      ],
      rotation: 25.0,
      color: DarkGray
    ),
    PolygonCollider(
      position: Vector2(x: 750, y: 350),
      vertices: @[
        Vector2(x: -100, y: -15), Vector2(x: 100, y: -15),
        Vector2(x: 100, y: 15), Vector2(x: -100, y: 15)
      ],
      rotation: -35.0,
      color: DarkGray
    )
  ]

  let emitterPos = Vector2(x: screenWidth / 2, y: 50)
  var frameCounter = 0
  var time: float32 = 0.0

  # Main game loop
  # --------------------------------------------------------------------------------------
  while not windowShouldClose():
    # Update
    # ----------------------------------------------------------------------------------
    let dt = getFrameTime()
    time += dt
    frameCounter += 1

    # --- Animate Colliders ---
    # Make the two side platforms oscillate using sin and cos for a see-saw effect.
    # The floor (index 0) remains static.
    colliders[1].rotation = 25.0 + sin(time * 0.8) * 20.0
    colliders[2].rotation = -35.0 + cos(time * 0.6) * 25.0

    # --- Particle Emitter ---
    # Emit a new particle every few frames.
    if frameCounter mod 4 == 0: # Emit a particle every 4th frame
      let newParticle = Particle(
        position: emitterPos,
        velocity: Vector2(x: rand(-200.0 .. 200.0), y: rand(-50.0 .. 50.0)),
        color: colors[rand(0 ..< colors.len)],
        radius: 3.0,
        bounces: 0
      )
      particles.addLast(newParticle)

    # --- Particle Update and Physics ---
    const gravity = 400.0
    const damping = 0.7 # Energy lost on bounce (1.0 = perfect bounce, 0.0 = no bounce)
    var i = 0
    while i < particles.len:
      let currentPos = particles[i].position
      # Apply gravity
      particles[i].velocity.y += gravity * dt
      # Update position
      let nextPos = currentPos + particles[i].velocity * dt
      
      var collidedThisFrame = false
      # LESSON 2: COLLISION DETECTION AND RESPONSE
      for collider in colliders:
        # We need the collider's vertices in World Space for the check.
        let rotationMatrix = rotateZ(degToRad(collider.rotation))
        let translationMatrix = translate(collider.position.x, collider.position.y, 0)
        let modelMatrix = multiply(rotationMatrix, translationMatrix)
        
        var worldVertices: seq[Vector2]
        for v in collider.vertices:
          worldVertices.add(transform(v, modelMatrix))

        # Check if the particle's NEXT position is inside the polygon. This helps
        # catch "tunneling" where a particle moves through an object in one frame.
        if checkCollisionPointPoly(nextPos, worldVertices):
          # Collision detected!
          particles[i].bounces += 1

          # Find the closest point on the polygon's boundary to the particle's CURRENT position.
          var closestPoint = worldVertices[0]
          var closestDistSq = float32.high
          for j in 0 ..< worldVertices.len:
            let p1 = worldVertices[j]
            let p2 = worldVertices[(j + 1) mod worldVertices.len]
            let pointOnEdge = getClosestPointOnSegment(currentPos, p1, p2)
            let distSq = distanceSqr(currentPos, pointOnEdge)
            if distSq < closestDistSq:
              closestDistSq = distSq
              closestPoint = pointOnEdge

          # The surface normal is the direction from the closest point to the particle's center.
          let surfaceNormal = normalize(currentPos - closestPoint)

          # LESSON 4: REFLECT THE VELOCITY
          particles[i].velocity = reflect(particles[i].velocity, surfaceNormal) * damping

          # Nudge the particle to be exactly on the surface to prevent it from getting stuck.
          # We place it at the point of impact for this frame.
          particles[i].position = closestPoint
          # We must break the inner loop to avoid multiple collision checks in one frame.
          collidedThisFrame = true
          break

      # If after checking all colliders, no collision occurred, then we can
      # safely move the particle to its next position.
      if not collidedThisFrame:
        particles[i].position = nextPos

      # Remove particles that fall off-screen or have bounced too many times.
      if particles[i].position.y > screenHeight + 20 or particles[i].bounces > 5:
        particles[i] = particles[particles.len - 1]
        particles.popLast()
      else:
        i += 1

    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(Black)

    # --- Draw Colliders ---
    for collider in colliders:
      pushMatrix()
      translatef(collider.position.x, collider.position.y, 0)
      rotatef(collider.rotation, 0, 0, 1)
      # We draw the polygon manually to use our model-space vertices
      for i in 0 ..< collider.vertices.len:
        let p1 = collider.vertices[i]
        let p2 = collider.vertices[(i + 1) mod collider.vertices.len]
        drawLine(p1, p2, 2.0, LightGray)
      popMatrix()

    # --- Draw Particles ---
    for p in particles:
      drawCircle(p.position, p.radius, p.color)

    # --- Draw UI ---
    drawText(font, "A simple particle physics simulation", 
             Vector2(x: 20, y: 20), 20.0, 1.0, Gray)
    drawText(font, fmt"Particles: {particles.len}", 
             Vector2(x: 20, y: 50), 20.0, 1.0, Gray)
    drawCircle(emitterPos, 5.0, White)

    endDrawing()
    # ------------------------------------------------------------------------------------

  closeWindow()

main()

#[
Key takeaways from this lesson:

- Physics Simulation: The core loop of a physics simulation is:
  1. Apply forces (like gravity) to update velocity.
  2. Update position based on velocity.
  3. Check for collisions.
  4. Resolve collisions (like bouncing).

- Surface Normal: The "normal" is a vector that points perpendicular to a
  surface. It's essential for calculating how light and objects should bounce.

- Vector Reflection: The `reflect(vector, normal)` function is a powerful tool
  provided by `raymath`. It takes an incoming vector and a surface normal and
  calculates the resulting "bounce" vector.
]#
