# ****************************************************************************************
#
#   raylib [graphics] lesson 4 - A Simple Game
#
#   This lesson combines many previous concepts into a simple interactive game.
#
#   It demonstrates:
#   - A player-controlled object (the "ship").
#   - A scene of "enemy" objects with independent state (health, position).
#   - Handling keyboard input for movement and shooting.
#   - State management for a bullet projectile.
#   - Collision detection between the bullet and enemy polygons.
#   - Updating object state based on game events (e.g., reducing health on hit).
#   - Respawning objects when they are destroyed or go off-screen.
#
# ****************************************************************************************

import raylib
import raymath
import strformat
import rlgl # For matrix transformations
import math
import random

const
  screenWidth = 800
  screenHeight = 600

# --- Type Definitions ---
type
  GameState = enum
    Playing, GameOver

type
  GameObject = object
    name: string
    sides: int32
    position: Vector2
    vertices: seq[Vector2] # Model-space vertices
    rotation: float32
    radius: float32
    collisionRadius: float32 # A separate radius for collision/boundary checks
    color: Color
    hp: int
    maxHp: int
    speed: float32
    scale: Vector2
    rotationSpeed: float32


  Bullet = object
    position: Vector2
    velocity: Vector2
    active: bool
    radius: float32
    color: Color


# --- Helper Procedures ---

proc generateRegularPolygon(sides: int, radius: float32): seq[Vector2] =
  var vertices: seq[Vector2] = @[]
  let angleStep = TAU / sides.float
  let angleOffset = -PI / 2.0 # Start with a point at the top

  for i in 0 ..< sides:
    let angle = i.float * angleStep + angleOffset
    vertices.add(Vector2(x: cos(angle) * radius, y: sin(angle) * radius))
  
  return vertices

proc resetEnemy(enemy: var GameObject, player: GameObject) =
  enemy.hp = enemy.maxHp

  # Add some randomization for pentagons
  if enemy.name == "Pentagon":
    enemy.speed = rand(70.0 .. 110.0)
    enemy.rotationSpeed = rand(-60.0 .. 60.0)

  # Ensure objects don't spawn on top of the player.
  while true:
    let minX = enemy.collisionRadius.float
    let maxX = screenWidth.float - enemy.collisionRadius.float
    enemy.position.x = rand(minX .. maxX)

    # Check for collision with the player at the spawn position. If there is a collision,
    # the loop continues and we try a new random X position.
    let spawnPos = Vector2(x: enemy.position.x, y: 0)
    if not checkCollisionCircles(spawnPos, enemy.collisionRadius, player.position, player.collisionRadius):
      break # Found a safe spot, exit the loop.

  enemy.position.y = -enemy.collisionRadius # Start just above the screen

proc resetPlayer(player: var GameObject) =
  player.position.x = screenWidth / 2
  player.position.y = screenHeight - 50
  player.rotation = 0
  # A short invincibility could be added here later

proc main =
  initWindow(screenWidth, screenHeight, "raylib [graphics] lesson 4 - Simple Game")
  setTargetFPS(60)
  randomize()

  let font = getFontDefault()

  # --- Player Ship Setup ---
  var player = GameObject(
    name: "Player",
    sides: 3,
    position: Vector2(x: screenWidth / 2, y: screenHeight - 50),
    vertices: generateRegularPolygon(3, 25),
    radius: 25,
    collisionRadius: 25,
    rotation: 0,
    color: Maroon,
    speed: 300.0, # pixels per second
    scale: Vector2(x: 1.0, y: 1.0),
    rotationSpeed: 0.0
  )

  # --- Bullet Setup ---
  var bullet = Bullet(
    active: false,
    radius: 5.0,
    color: Black
  )
  const bulletSpeed = 500.0

  # --- Enemy Setup ---
  var enemies: seq[GameObject] = @[
    GameObject(
      name: "Hexagon",
      sides: 6,
      vertices: generateRegularPolygon(6, 50),
      radius: 50,
      collisionRadius: 50,
      color: DarkGray,
      hp: 3, maxHp: 3,
      speed: 60.0,
      scale: Vector2(x: 1.0, y: 1.0),
      rotationSpeed: 0.0
    ),
    GameObject(
      name: "Pentagon",
      sides: 5,
      vertices: generateRegularPolygon(5, 40),
      radius: 40,
      collisionRadius: 40,
      color: DarkBlue,
      hp: 2, maxHp: 2,
      speed: 80.0,
      scale: Vector2(x: 1.0, y: 1.0),
      rotationSpeed: 45.0 # Base rotation speed
    ),
    GameObject(
      name: "Diamond",
      sides: 4,
      # Define as a regular square. The matrix will do the stretching.
      vertices: generateRegularPolygon(4, 30),
      radius: 30, # Base radius for drawing.
      collisionRadius: 30 * 1.4, # Use the largest scaled dimension for checks.
      color: colorAlpha(Orange, 0.8),
      hp: 0, maxHp: 0, # Not an enemy, so no HP needed
      speed: 100.0,
      scale: Vector2(x: 0.7, y: 1.4), # Squish horizontally, stretch vertically
      rotationSpeed: 0.0
    )
  ]

  for i in 0 ..< enemies.len:
    resetEnemy(enemies[i], player)
  var score = 0
  var lives = 3
  var gameState = Playing

  var time: float32 = 0.0

  # For the game over screen stars
  var stars: seq[GameObject] = @[]

  # Main game loop
  # --------------------------------------------------------------------------------------
  while not windowShouldClose():
    
    case gameState
    of Playing:
      # Update
      # ----------------------------------------------------------------------------------
      let dt = getFrameTime()
      time += dt

      # --- Update Object Properties (like twinkling and rotation) ---
      for i in 0 ..< enemies.len:
        if enemies[i].name == "Diamond":
          const diamondColor1 = Orange
          const diamondColor2 = Yellow
          const twinkleSpeed = 10.0
          let factor = (sin(time * twinkleSpeed) + 1.0) / 2.0
          let startColorVec = colorNormalize(diamondColor1)
          let endColorVec = colorNormalize(diamondColor2)
          let finalColorVec = lerp(startColorVec, endColorVec, factor.float32)
          enemies[i].color = colorFromNormalized(finalColorVec)
        
        if enemies[i].rotationSpeed != 0.0:
          enemies[i].rotation += enemies[i].rotationSpeed * dt

      # --- Player Update ---
      if isKeyDown(Right): player.position.x += player.speed * dt
      if isKeyDown(Left): player.position.x -= player.speed * dt

      if player.position.x < player.radius: player.position.x = player.radius
      if player.position.x > screenWidth - player.radius:
        player.position.x = screenWidth - player.radius

      player.rotation = sin(time * 1.5) * 45.0

      # --- Shooting Logic ---
      if isKeyPressed(Space) and not bullet.active:
        bullet.active = true
        let rotationMatrix = rotateZ(degToRad(player.rotation))
        bullet.position = transform(player.vertices[0], rotationMatrix) + player.position
        let forward = Vector2(x: 0, y: -1)
        let direction = rotate(forward, degToRad(player.rotation))
        bullet.velocity = direction * bulletSpeed

      # --- Bullet Update ---
      if bullet.active:
        bullet.position += bullet.velocity * dt
        if bullet.position.y < 0 or bullet.position.y > screenHeight or 
           bullet.position.x < 0 or bullet.position.x > screenWidth:
          bullet.active = false

      # --- Enemy Update and Collision ---
      for i in 0 ..< enemies.len:
        enemies[i].position.y += enemies[i].speed * dt

        if enemies[i].position.y > screenHeight + enemies[i].collisionRadius:
          resetEnemy(enemies[i], player)

        # Bullet vs Enemy collision
        if bullet.active and enemies[i].name != "Diamond":
          # To get the correct world-space vertices for collision, we must apply
          # the same transformations we use for drawing. We build the model matrix.
          let translationMatrix = translate(enemies[i].position.x, enemies[i].position.y, 0)
          let scaleMatrix = scale(enemies[i].scale.x, enemies[i].scale.y, 1.0)
          let modelMatrix = multiply(scaleMatrix, translationMatrix)
          var worldVertices: seq[Vector2] = @[]
          for v in enemies[i].vertices: worldVertices.add(transform(v, modelMatrix))

          if checkCollisionPointPoly(bullet.position, worldVertices):
            bullet.active = false
            enemies[i].hp -= 1
            if enemies[i].hp <= 0:
              score += enemies[i].maxHp
              resetEnemy(enemies[i], player)

        # Player vs Diamond collision
        if enemies[i].name == "Diamond":
          let collected = checkCollisionCircles(
            player.position, player.collisionRadius, 
            enemies[i].position, enemies[i].collisionRadius)
          if collected:
            score += 10
            resetEnemy(enemies[i], player)
        
        # Player vs Enemy collision
        elif enemies[i].name == "Hexagon" or enemies[i].name == "Pentagon":
          let hit = checkCollisionCircles(
            player.position, player.collisionRadius, 
            enemies[i].position, enemies[i].collisionRadius)
          if hit:
            lives -= 1
            resetPlayer(player)
            resetEnemy(enemies[i], player)
            if lives <= 0:
              gameState = GameOver
              # Prepare stars for game over screen
              for _ in 0..50:
                var star = enemies[2] # Use diamond object as a template
                star.position = Vector2(x: rand(0.0..screenWidth.float), y: rand(0.0..screenHeight.float))
                star.scale = Vector2(x: rand(0.1..0.4), y: rand(0.2..0.8))
                stars.add(star)

    of GameOver:
      # Update logic for the game over screen
      time += getFrameTime()
      # Twinkle the stars
      for i in 0 ..< stars.len:
        const twinkleSpeed = 10.0
        let factor = (sin(time * twinkleSpeed + i.float) + 1.0) / 2.0 # Add offset
        stars[i].color = colorFromNormalized(lerp(colorNormalize(Orange), colorNormalize(Yellow), factor.float32))

      if isKeyPressed(Enter):
        # Reset game
        lives = 3
        score = 0
        for i in 0 ..< enemies.len:
          resetEnemy(enemies[i], player)
        resetPlayer(player)
        gameState = Playing

    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)

    case gameState
    of Playing:
      # --- Draw Enemies ---
      for enemy in enemies:
        pushMatrix()
        translatef(enemy.position.x, enemy.position.y, 0)
        if enemy.name == "Diamond":
          scalef(enemy.scale.x, enemy.scale.y, 1.0)
          drawPoly(Vector2(x:0, y:0), enemy.sides, enemy.radius, 0.0, enemy.color)
        else:
          drawPolyLines(Vector2(x:0, y:0), enemy.sides, enemy.radius, enemy.rotation, 3.0, enemy.color)
        if enemy.hp > 0:
          let hpPercentage = enemy.hp.float / enemy.maxHp.float
          let barWidth = enemy.radius * 1.5
          let barPos = Vector2(x: -barWidth / 2, y: -enemy.radius - 15)
          drawRectangle(barPos.x.int32, barPos.y.int32, barWidth.int32, 8, LightGray)
          drawRectangle(barPos.x.int32, barPos.y.int32, (barWidth * hpPercentage).int32, 8, Green)
        popMatrix()

      # --- Draw Player ---
      pushMatrix()
      translatef(player.position.x, player.position.y, 0)
      rotatef(player.rotation, 0, 0, 1)
      drawTriangle(player.vertices[0], player.vertices[1], player.vertices[2], player.color)
      drawTriangleLines(player.vertices[0], player.vertices[1], player.vertices[2], Black)
      popMatrix()

      # --- Draw Bullet ---
      if bullet.active:
        drawCircle(bullet.position, bullet.radius, bullet.color)

      # --- Draw UI ---
      let instructions = "Use [Left]/[Right] to move, [Space] to fire"
      drawText(font, instructions, Vector2(x: 10, y: 10), 20.0, 1.0, Gray)

      let scoreText = fmt"Score: {score}"
      let scorePos = Vector2(x: screenWidth - measureText(font, scoreText, 20.0, 1.0).x - 10, y: 10)
      drawText(font, scoreText, scorePos, 20.0, 1.0, Gray)
      
      # Draw lives
      drawText(font, "Lives:", Vector2(x: screenWidth - 150, y: 40), 20.0, 1.0, Gray)
      for i in 0 ..< lives:
        let lifePos = Vector2(x: (screenWidth - 80 + i * 25).float32, y: 50.0'f32)
        
        # Pre-calculate the scaled vertices for the life icon to ensure type consistency
        let v1 = player.vertices[0] * 0.4'f32
        let v2 = player.vertices[1] * 0.4'f32
        let v3 = player.vertices[2] * 0.4'f32
        
        let 
          p1 = lifePos + v1
          p2 = lifePos + v2
          p3 = lifePos + v3
        drawTriangle(p1, p2, p3, Maroon)
        # Add a black outline to make the life icons clearly visible.
        drawTriangleLines(p1, p2, p3, Black)

      drawFPS(screenWidth - 80, screenHeight - 30)

    of GameOver:
      # Draw the twinkling stars
      for star in stars:
        pushMatrix()
        translatef(star.position.x, star.position.y, 0)
        scalef(star.scale.x, star.scale.y, 1.0)
        drawPoly(Vector2(x:0, y:0), star.sides, star.radius, 0.0, star.color)
        popMatrix()

      let titleText = "GAME OVER"
      let titleSize = measureText(font, titleText, 80.0, 1.0)
      drawText(font, titleText, Vector2(x: (screenWidth - titleSize.x)/2, y: 150), 80.0, 1.0, DarkGray)

      let scoreText = fmt"Final Score: {score}"
      let scoreSize = measureText(font, scoreText, 40.0, 1.0)
      drawText(font, scoreText, Vector2(x: (screenWidth - scoreSize.x)/2, y: 250), 40.0, 1.0, Gray)

      let restartText = "Press [ENTER] to play again"
      let restartSize = measureText(font, restartText, 20.0, 1.0)
      drawText(font, restartText, Vector2(x: (screenWidth - restartSize.x)/2, y: 350), 20.0, 1.0, LightGray)

    endDrawing()
    # ------------------------------------------------------------------------------------

  closeWindow()

main()

#[
Key Concepts in this Lesson:

- Game State Management: Using an enum (`GameState`) and a `case` statement to
  control the entire flow of the game, switching between `Playing` and `GameOver`
  update and draw logic.

- Player State: The player now has `lives`, and the game reacts to changes in
  this state, leading to a game over condition.

- Collision Detection: We implemented two types of collision:
  1. Point-to-Poly for the bullet against complex shapes.
  2. Circle-to-Circle for player-enemy and player-collectible interactions.

- Full Game Loop: The game now has a complete beginning, middle, and end, with a
  clear win/loss condition (surviving and scoring) and the ability to restart,
  which is the core of any arcade-style game.
]#
