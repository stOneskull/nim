# ****************************************************************************************
#
#   raylib [graphics] lesson 2 - Drawing Polygons
#
#   This lesson demonstrates how to generate and draw regular polygons.
#
#   We will build on the previous lesson by:
#   - Creating a procedure to generate vertices for any regular polygon.
#   - Storing these vertices in a sequence.
#   - Using a loop to draw the polygon from its vertices.
#   - Cycling through different polygon types with user input.
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

type
  Polygon = object
    name: string
    vertices: seq[Vector2]

# LESSON 1: GENERATING POLYGON VERTICES
# This procedure creates the vertices for a regular polygon with a given
# number of sides and radius. The vertices are calculated by finding points
# on a circle.
proc generateRegularPolygon(sides: int, radius: float32): seq[Vector2] =
  var vertices: seq[Vector2] = @[]
  # We add an angle offset of -PI/2 to ensure the first vertex is at the top,
  # which often looks better for shapes like triangles.
  let angleStep = TAU / sides.float # TAU is 2*PI
  let angleOffset = -PI / 2.0

  for i in 0 ..< sides:
    let angle = i.float * angleStep + angleOffset
    vertices.add(Vector2(x: cos(angle) * radius, y: sin(angle) * radius))
  
  return vertices

proc main =
  initWindow(screenWidth, screenHeight, "raylib [graphics] lesson 2 - Polygons")
  setTargetFPS(60)

  # LESSON 2: DEFINING OUR POLYGONS
  # We create a list of polygons to cycle through.
  let polygons = [
    Polygon(name: "Triangle", vertices: generateRegularPolygon(3, 50)),
    Polygon(name: "Square", vertices: generateRegularPolygon(4, 50)),
    Polygon(name: "Pentagon", vertices: generateRegularPolygon(5, 50)),
    Polygon(name: "Hexagon", vertices: generateRegularPolygon(6, 50))
  ]
  var currentPolygonIndex = 0

  var rotation: float32 = 0.0
  let font = getFontDefault()

  # Main game loop
  # --------------------------------------------------------------------------------------
  while not windowShouldClose():
    # Update
    # ----------------------------------------------------------------------------------
    rotation += 0.5 # Increase rotation angle every frame

    if isKeyPressed(Space):
      currentPolygonIndex = (currentPolygonIndex + 1) mod polygons.len

    let currentPolygon = polygons[currentPolygonIndex]

    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)

    # Use the same transformation stack as the previous lesson.
    pushMatrix()
    translatef(screenWidth / 2, screenHeight / 2, 0)
    rotatef(rotation, 0, 0, 1)

    # LESSON 3: DRAWING THE POLYGON
    # Instead of a specific `drawTriangle` function, we can loop through the
    # vertices and draw lines between them. This works for any polygon!
    for i in 0 ..< currentPolygon.vertices.len:
      let v1 = currentPolygon.vertices[i]
      # The modulo operator (%) makes the index wrap around, so the last
      # vertex connects back to the first one.
      let v2 = currentPolygon.vertices[(i + 1) mod currentPolygon.vertices.len]
      drawLine(v1, v2, 2.0, DarkGray)
    
    # We can also use raylib's `drawPolygonLinesEx` for a simpler approach.
    # drawPolygonLinesEx(currentPolygon.vertices[0].addr, currentPolygon.vertices.len, 2.0, DarkGray)

    popMatrix()

    # --- Draw UI and Explanations ---
    drawText(font, "Drawing Polygons", 
        Vector2(x: 20, y: 20), 30.0, 1.0, DarkGray)
    drawText(font, "We generate vertices by finding points on a circle.", 
        Vector2(x: 20, y: 70), 20.0, 1.0, Gray)
    drawText(font, "This allows us to create any regular polygon.", 
        Vector2(x: 20, y: 100), 20.0, 1.0, Gray)

    let currentName = currentPolygon.name
    drawText(font, fmt"Current Shape: {currentName}", 
        Vector2(x: 20, y: 150), 20.0, 1.0, Maroon)
    drawText(font, "Press [Space] to cycle shapes.", 
        Vector2(x: 20, y: screenHeight - 40), 20.0, 1.0, LightGray)

    endDrawing()
    # ------------------------------------------------------------------------------------

  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow()
  # --------------------------------------------------------------------------------------

main()