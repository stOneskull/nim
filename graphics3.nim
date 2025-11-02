# ****************************************************************************************
#
#   raylib [graphics] lesson 3 - A Scene of Objects
#
#   This lesson combines concepts from the `vectors` and `graphics` series.
#
#   We will build on the previous lesson by:
#   - Creating multiple polygon objects, each with its own state (position, rotation, scale).
#   - Iterating through a list of these objects in our draw loop.
#   - Applying unique transformations for each object. We use the rlgl matrix stack
#     for translation and scaling, but pass rotation directly to the drawing functions
#     for convenience.
#   - This demonstrates how to manage a "scene" of independent objects.
#
# ****************************************************************************************

import raylib
import raymath
import rlgl # raylib's OpenGL abstraction layer, for matrix transformations
import math
import strformat

const
  screenWidth = 800
  screenHeight = 600

# LESSON 1: EXPANDING THE OBJECT DEFINITION
# We enhance our Polygon object to include its own transformation properties.
# This is similar to the concepts in the `vectors` series where each object
# had its own state.
type
  Polygon = object
    name: string
    sides: int32 
    radius: float32 
    vertices: seq[Vector2]
    position: Vector2
    rotation: float32
    scale: float32
    rotationSpeed: float32
    color: Color

# This procedure is unchanged from graphics2.nim
proc generateRegularPolygon(sides: int, radius: float32): seq[Vector2] =
  var vertices: seq[Vector2] = @[]
  let angleStep = TAU / sides.float
  let angleOffset = -PI / 2.0

  for i in 0 ..< sides:
    let angle = i.float * angleStep + angleOffset
    vertices.add(Vector2(x: cos(angle) * radius, y: sin(angle) * radius))
  
  return vertices

proc main =
  initWindow(screenWidth, screenHeight, "raylib [graphics] lesson 3 - A Scene of Objects")
  setTargetFPS(60)

  # LESSON 2: CREATING A SCENE OF OBJECTS
  # We create a sequence of polygons, each with unique properties.
  # This is our "scene".
  var scene: seq[Polygon] = @[
    # A rotating triangle
    Polygon(
      name: "Triangle",
      sides: 3,
      radius: 50,
      vertices: generateRegularPolygon(3, 50),
      position: Vector2(x: 150, y: 200),
      rotation: 0,
      scale: 1.0,
      rotationSpeed: 60.0, # degrees per second
      color: Maroon
    ),
    # A large, oscillating hexagon
    Polygon(
      name: "Hexagon",
      sides: 6,
      radius: 80,
      vertices: generateRegularPolygon(6, 80),
      position: Vector2(x: 400, y: 400), # Y-position is updated dynamically
      rotation: 15,
      scale: 1.0,
      rotationSpeed: 0,
      color: DarkGray
    ),
    # A "pulsing" pentagon
    Polygon(
      name: "Pentagon",
      sides: 5,
      radius: 60,
      vertices: generateRegularPolygon(5, 60),
      position: Vector2(x: 650, y: 250),
      rotation: 0,
      scale: 1.0,
      rotationSpeed: -30.0,
      color: DarkBlue
    ),
    # A new square drawn with drawPoly (filled)
    Polygon(
      name: "Square",
      sides: 4,
      radius: 40,
      vertices: generateRegularPolygon(4, 40), # Vertices not used for drawing, but good practice
      position: Vector2(x: 150, y: 450),
      rotation: 45.0,
      scale: 1.0,
      rotationSpeed: 20.0,
      color: colorAlpha(Orange, 0.8)
    )
  ]

  var time: float32 = 0.0
  let font = getFontDefault()

  # Main game loop
  # --------------------------------------------------------------------------------------
  while not windowShouldClose():
    # Update
    # ----------------------------------------------------------------------------------
    let dt = getFrameTime()
    time += dt

    # Update each object in the scene
    for i in 0 ..< scene.len:
      scene[i].rotation += scene[i].rotationSpeed * dt
    
    # Make the pentagon "pulse" using a sine wave for its scale
    scene[2].scale = 1.0 + sin(time * 2.5) * 0.4

    # Make the hexagon oscillate vertically.
    # The center of its movement is y=300, with an amplitude of 100.
    # This makes it move between y=200 (the triangle's height) and y=400 (its start).
    scene[1].position.y = 300.0 - cos(time) * 100.0

    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)

    # LESSON 3: RENDERING THE SCENE
    # We loop through each object and apply its unique transformation.
    for i, poly in scene:
      # Save the current state of the world (which is the default, untransformed state)
      pushMatrix()

      # Apply this object's transformations in SRT order (Scale, Rotate, Translate)
      # but the function calls are in the reverse: Translate, then Scale.
      translatef(poly.position.x, poly.position.y, 0)
      # We use scalef() for the pulsing effect.
      # Rotation is handled differently: we pass the angle directly to the
      # drawPoly/drawPolyLines functions instead of using rlgl's rotatef().
      scalef(poly.scale, poly.scale, 1.0) 

      # Now that the world is transformed for this object, draw it at (0,0).
      if i == 3: # The new square
        # Use drawPoly for a FILLED shape. It generates vertices internally.
        # We pass its own rotation value directly.
        drawPoly(Vector2(x:0, y:0), poly.sides, 40.0, poly.rotation, poly.color)
      else:
        # Use drawPolyLines for an OUTLINE shape. It also generates vertices internally.
        var thickness: float32 = 2.0
        if poly.name == "Hexagon":
          thickness = 5.0 # Make the hexagon's lines noticeably thicker
        
        drawPolyLines(
          Vector2(x:0, y:0),
          poly.sides, poly.radius, poly.rotation, thickness, poly.color)

      # The original loop method still works perfectly and is more versatile.
      # for j in 0 ..< poly.vertices.len:
      #   ...
      #   drawLine(v1, v2, 2.0, poly.color)


      # Restore the world to its previous state for the next object.
      popMatrix()

    # --- Draw UI and Object Labels ---
    drawText(font, "A Scene of Objects", 
        Vector2(x: 20, y: 20), 30.0, 1.0, DarkGray)
    drawText(font, "Each object has its own position, rotation, and scale.", 
        Vector2(x: 20, y: 70), 20.0, 1.0, Gray)
    drawText(font, "We loop through the scene, applying a unique transformation for each one.", 
        Vector2(x: 20, y: 100), 20.0, 1.0, Gray)    
    drawText(font, "Using drawPoly (filled) and drawPolyLines (outline).", 
        Vector2(x: 20, y: 130), 20.0, 1.0, Gray)
    
    # LESSON 4: DRAWING LABELS
    # We loop through the scene again (outside of any matrix transforms) to draw the UI.
    const labelFontSize = 15.0
    const labelSpacing = 1.5
    for poly in scene:
      let nameText = poly.name
      let posText = fmt"P:({poly.position.x:.0f}, {poly.position.y:.0f})"
      let displayRotation = math.mod(poly.rotation, 360.0)
      let rotText = fmt"R:{displayRotation:.0f}°"
      let scaleText = fmt"S:{poly.scale:.2f}"

      # Position the labels slightly below the object, accounting for its radius and current scale.
      let labelY = poly.position.y + poly.radius * poly.scale + 10

      # Center each line of text under the object's position.
      drawText(font, nameText, Vector2(
        x: poly.position.x - measureText(font, nameText, labelFontSize, labelSpacing).x / 2, 
        y: labelY), labelFontSize, labelSpacing, Black)
      drawText(font, posText, Vector2(
        x: poly.position.x - measureText(font, posText, labelFontSize, labelSpacing).x / 2, 
        y: labelY + 16), labelFontSize, labelSpacing, Gray)
      drawText(font, rotText, Vector2(
        x: poly.position.x - measureText(font, rotText, labelFontSize, labelSpacing).x / 2, 
        y: labelY + 32), labelFontSize, labelSpacing, Gray)
      drawText(font, scaleText, Vector2(
        x: poly.position.x - measureText(font, scaleText, labelFontSize, labelSpacing).x / 2, 
        y: labelY + 48), labelFontSize, labelSpacing, Gray)

    endDrawing()
    # ------------------------------------------------------------------------------------

  closeWindow()

main()
