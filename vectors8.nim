# ****************************************************************************************
#
#   raylib [vectors] lesson 8 - Graphing Trigonometric Functions
#
#   This lesson demonstrates:
#   - How to plot sine and cosine functions.
#   - The relationship between sin(x) and cos(x).
#   - Refactoring drawing code into reusable procedures.
#   - Using a generic procedure to plot any mathematical function.
#
# ****************************************************************************************

import raylib
import raymath
import math
import strformat

const
  screenWidth = 800
  screenHeight = 600

# --- Graphing Helper Types and Procs ---
type
  GraphSpace = object
    origin: Vector2   # Screen coordinates of the graph's (0,0) point
    scale: Vector2    # Pixels per unit for x and y
  
  DisplayMode = enum
    ShowSin, ShowCos, ShowBoth


# Function to convert a point from graph space to screen space
proc toScreenSpace(p: Vector2, graph: GraphSpace): Vector2 =
  result.x = graph.origin.x + p.x * graph.scale.x
  result.y = graph.origin.y - p.y * graph.scale.y # Y is inverted in screen space

# --- Drawing Procedures ---

proc drawGrid(graph: GraphSpace, font: Font) =
  # Draw X and Y axes
  let xAxisStart = toScreenSpace(Vector2(x: -20, y: 0), graph)
  let xAxisEnd = toScreenSpace(Vector2(x: 20, y: 0), graph)
  drawLine(xAxisStart, xAxisEnd, 2.0, LightGray)

  let yAxisStart = toScreenSpace(Vector2(x: 0, y: -20), graph)
  let yAxisEnd = toScreenSpace(Vector2(x: 0, y: 20), graph)
  drawLine(yAxisStart, yAxisEnd, 2.0, LightGray)

  # Draw unit markers on the axes
  for i in -10..10:
    if i == 0: continue
    # X-axis markers (at PI intervals)
    let xMarkerGraph = Vector2(x: i.float * PI, y: 0.1)
    let xMarkerScreen = toScreenSpace(xMarkerGraph, graph)
    let xMarkerScreenEnd = toScreenSpace(Vector2(x: xMarkerGraph.x, y: -0.1), graph)
    drawLine(xMarkerScreen, xMarkerScreenEnd, 2.0, LightGray)
    if i mod 2 == 0: # Label every 2*PI
      drawText(font, fmt"{i}pi", Vector2(x: xMarkerScreen.x - 10, y: xMarkerScreen.y + 5), 10.0, 1.0, Gray)

    # Y-axis markers
    let yMarkerGraph = Vector2(x: 0.1, y: i.float)
    let yMarkerScreen = toScreenSpace(yMarkerGraph, graph)
    let yMarkerScreenEnd = toScreenSpace(Vector2(x: -0.1, y: yMarkerGraph.y), graph)
    drawLine(yMarkerScreen, yMarkerScreenEnd, 2.0, LightGray)
    if i != 0:
      drawText(font, fmt"{i}", Vector2(x: yMarkerScreen.x + 5, y: yMarkerScreen.y - 5), 10.0, 1.0, Gray)


proc drawFunction(graph: GraphSpace, color: Color, funcToPlot: proc(x: float32): float32) =
  let steps = 400 # More steps for a smoother curve
  let graphWidth = screenWidth.float / graph.scale.x
  let startX = -graphWidth / 2.0

  for i in 0 ..< steps:
    let x1_graph = startX + (i.float / steps.float) * graphWidth
    let y1_graph = funcToPlot(x1_graph)
    let p1_screen = toScreenSpace(Vector2(x: x1_graph, y: y1_graph), graph)

    let x2_graph = startX + ((i+1).float / steps.float) * graphWidth
    let y2_graph = funcToPlot(x2_graph)
    let p2_screen = toScreenSpace(Vector2(x: x2_graph, y: y2_graph), graph)

    drawLine(p1_screen, p2_screen, 2.0, color)

proc drawUI(mode: DisplayMode, font: Font) =
  drawText(font, "Trigonometric Visualizer", Vector2(x: 20, y: 20), 40.0, 1.0, DarkGray)

  if mode == ShowSin or mode == ShowBoth:
    drawText(font, "Function: y = sin(x)", Vector2(x: 20, y: 80), 20.0, 1.0, Red)
  if mode == ShowCos or mode == ShowBoth:
    drawText(font, "Function: y = cos(x)", Vector2(x: 20, y: 110), 20.0, 1.0, Blue)

  drawText(font, "These functions describe wave-like patterns.", Vector2(x: 20, y: 150), 20.0, 1.0, Gray)
  drawText(font, "They are fundamental in describing rotation and oscillation.", Vector2(x: 20, y: 170), 20.0, 1.0, Gray)
  if mode == ShowBoth:
    drawText(font, "Notice that cos(x) is the same as sin(x), but shifted to the left by pi/2.", Vector2(x: 20, y: 200), 20.0, 1.0, Gray)
  
  drawText(font, "The x-axis markers are placed at intervals of pi.", Vector2(x: 20, y: 230), 20.0, 1.0, Gray)
  drawText(font, "Press [Space] to cycle through views.", Vector2(x: 20, y: screenHeight - 40), 20.0, 1.0, LightGray)


proc main =
  initWindow(screenWidth, screenHeight, "raylib [vectors] lesson 8 - Trigonometric Functions")
  setTargetFPS(60)

  # Define the graph space.
  # We want to see the waves, so we scale Y more than X.
  # X scale is set so we can see a few cycles (e.g., -2π to 2π).
  let graph = GraphSpace(
    origin: Vector2(x: screenWidth / 2.0, y: screenHeight / 2.0),
    scale: Vector2(x: 50.0, y: 150.0) # 50 pixels per 1 unit on X, 150 on Y
  )

  # Load a font explicitly to ensure all characters render correctly.
  let font = getFontDefault()

  var currentMode = ShowSin

  # Main game loop
  # --------------------------------------------------------------------------------------
  while not windowShouldClose():
    # Update
    # ----------------------------------------------------------------------------------
    if isKeyPressed(Space):
      # Cycle through the display modes: ShowSin -> ShowCos -> ShowBoth -> ShowSin
      currentMode = cast[DisplayMode]((currentMode.ord + 1) mod (DisplayMode.high.ord + 1))

    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)

    drawGrid(graph, font)

    # Draw the functions
    if currentMode == ShowSin or currentMode == ShowBoth:
      drawFunction(graph, Red, sin)
    if currentMode == ShowCos or currentMode == ShowBoth:
      drawFunction(graph, Blue, cos)
    
    # Pass the loaded font to the UI drawing procedure
    drawUI(currentMode, font)

    endDrawing()
    # ------------------------------------------------------------------------------------

  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow()
  # --------------------------------------------------------------------------------------

main()

#[
This lesson shows how to plot continuous functions like sin and cos.

Key takeaways:
- A generic `drawFunction` procedure can plot any `proc(x: float32): float32`,
  making it highly reusable.
- Adjusting the `graph.scale` is crucial for getting a good view of the function.
  Here, the Y-axis is "stretched" to make the -1 to 1 range of sin/cos clearly visible.
- The relationship between sin and cos (a phase shift of π/2) becomes visually obvious.
]#