# ****************************************************************************************
#
#   raylib [vectors] lesson 7 - Graphing Quadratic Functions
#
#   This lesson demonstrates:
#   - The difference between a quadratic FUNCTION and a quadratic EQUATION.
#   - How to plot a mathematical function on the screen.
#   - Mapping coordinates from a "graph space" to "screen space".
#   - Calculating and visualizing the roots (solutions) of a quadratic equation.
#
# ****************************************************************************************

import raylib
import raymath
import math
import strformat

const
  screenWidth = 800
  screenHeight = 600 # A bit taller for the graph.

# --- Graphing Helper Types and Procs ---
type
  GraphSpace = object
    origin: Vector2   # Screen coordinates of the graph's (0,0) point
    scale: Vector2    # Pixels per unit for x and y

# Function to convert a point from graph space to screen space
proc toScreenSpace(p: Vector2, graph: GraphSpace): Vector2 =
  # X: Start at the origin's screen X and add the scaled graph X.
  result.x = graph.origin.x + p.x * graph.scale.x 
  # Y: Start at the origin's screen Y and SUBTRACT the scaled graph Y.
  # This is because in math, positive Y goes up, but in screen coordinates, positive Y goes down.
  result.y = graph.origin.y - p.y * graph.scale.y

# The quadratic function itself: y = ax² + bx + c
proc quadraticFunc(x: float32, a, b, c: float32): float32 =
  return a * x * x + b * x + c

proc main =
  initWindow(screenWidth, screenHeight, "raylib [vectors] lesson 7 - Quadratic Functions")
  setTargetFPS(60)

  # LESSON 1: DEFINING THE GRAPH SPACE
  # We need to map our mathematical coordinates to screen coordinates.
  let graph = GraphSpace(
    origin: Vector2(x: screenWidth / 2.0, y: screenHeight / 2.0 + 50),
    scale: Vector2(x: 30.0, y: 30.0) # 30 pixels per 1 unit
  )

  # LESSON 2: PRE-DEFINED FUNCTIONS
  # We'll create a list of functions to cycle through. Each is a tuple of (a, b, c).
  let functions = [
    (a: 0.5, b: -1.0, c: -4.0),   # Two real roots
    (a: 1.0, b: -6.0, c: 9.0),    # One real root
    (a: 1.0, b: 2.0, c: 5.0),     # No real roots
    (a: -0.5, b: 1.0, c: 6.0)     # Downward-facing parabola
  ]
  var currentFuncIndex = 0

  # Main game loop
  # --------------------------------------------------------------------------------------
  while not windowShouldClose():
    # Update
    # ----------------------------------------------------------------------------------
    if isKeyPressed(Space):
      # Use the modulo operator to cycle through the list of functions, wrapping
      # around to the beginning when we reach the end.
      currentFuncIndex = (currentFuncIndex + 1) mod functions.len

    # LESSON 3: THE CURRENT FUNCTION AND EQUATION
    # Get the current coefficients and calculate the roots on every frame.
    let (a, b, c) = functions[currentFuncIndex]

    # This is the implementation of the quadratic formula to find the roots:
    # x = [-b ± sqrt(b² - 4ac)] / 2a
    # The "discriminant" is the part under the square root. Its value tells us
    # how many real roots the equation has.
    let discriminant = b*b - 4*a*c
    var roots: seq[float32] = @[]
    if discriminant > 0:
      let sqrtDiscriminant = sqrt(discriminant)
      roots.add((-b + sqrtDiscriminant) / (2*a))
      roots.add((-b - sqrtDiscriminant) / (2*a))
    elif discriminant == 0:
      roots.add(-b / (2*a))

    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)

    # --- Draw Graph Axes and Grid ---
    let xAxisStart = toScreenSpace(Vector2(x: -20, y: 0), graph)
    let xAxisEnd = toScreenSpace(Vector2(x: 20, y: 0), graph)
    drawLine(xAxisStart, xAxisEnd, 2.0, LightGray)

    let yAxisStart = toScreenSpace(Vector2(x: 0, y: -20), graph)
    let yAxisEnd = toScreenSpace(Vector2(x: 0, y: 20), graph)
    drawLine(yAxisStart, yAxisEnd, 2.0, LightGray)

    # --- Draw the Parabola ---
    # We draw the function by calculating many points and connecting them with lines.
    let steps = 200 # More steps = smoother curve
    let graphWidth = screenWidth.float / graph.scale.x
    for i in 0 ..< steps:
      # Calculate the start point (p1) of a tiny line segment.
      # We map the loop counter `i` to an x-coordinate in our graph's space.
      let x1_graph = -graphWidth/2 + (i.float / steps.float) * graphWidth
      let y1_graph = quadraticFunc(x1_graph, a, b, c)
      let p1_screen = toScreenSpace(Vector2(x: x1_graph, y: y1_graph), graph)

      # Calculate the end point (p2) of the segment for the next step.
      let x2_graph = -graphWidth/2 + ((i+1).float / steps.float) * graphWidth
      let y2_graph = quadraticFunc(x2_graph, a, b, c)
      let p2_screen = toScreenSpace(Vector2(x: x2_graph, y: y2_graph), graph)

      drawLine(p1_screen, p2_screen, 2.0, Maroon)

    # --- Draw the Roots ---
    # The roots are the solutions to the equation, where y=0.
    for root in roots:
      let rootPosGraph = Vector2(x: root, y: 0)
      let rootPosScreen = toScreenSpace(rootPosGraph, graph)
      drawCircle(rootPosScreen, 8.0, colorAlpha(Blue, 0.7))
      drawCircleLines(rootPosScreen, 8.0, Blue)

      # Draw the numerical value of the root on the graph.
      let rootValueText = fmt"{root:.2f}"
      # Measure the text so we can center it under the circle.
      let textWidth = measureText(rootValueText, 15)
      let textPos = Vector2(x: rootPosScreen.x - textWidth / 2, y: rootPosScreen.y + 12)
      drawText(rootValueText, textPos.x.int32, textPos.y.int32, 15, Blue)

    # --- Draw Explanations ---
    drawText("Quadratic Visualizer", 20, 20, 40, DarkGray)

    let funcText = fmt"Function: y = {a}x² + {b}x + {c}"
    drawText(funcText, 20, 80, 20, Black)

    let eqText = fmt"Equation: {a}x² + {b}x + {c} = 0"
    drawText(eqText, 20, 110, 20, Black)

    drawText("The function (red curve) describes the relationship between x and y.",
             20, 150, 20, Gray)
    drawText("Press [Space] to cycle through different functions.",
             20, screenHeight - 40, 20, LightGray)
    drawText("The equation's solutions (blue circles) are the 'roots' -",
             20, 180, 20, Gray)
    drawText("the x-values where y is 0.", 20, 200, 20, Gray)

    var rootText = "Roots: "
    var discriminantText = fmt"Discriminant (b² - 4ac) = {discriminant:.2f}"
    var discriminantMeaning: string

    if roots.len == 0:
      rootText &= "None (parabola does not cross the x-axis)"
      discriminantMeaning = "Discriminant is negative: No real roots"
    elif roots.len == 1:
      rootText &= fmt"{roots[0]:.2f}"
      discriminantMeaning = "Discriminant is zero: One real root"
    else:
      for i, root in roots:
        rootText &= fmt"{root:.2f}"
        if i < roots.len - 1: rootText &= ", "
      discriminantMeaning = "Discriminant is positive: Two real roots"
    
    drawText(rootText, 20, 240, 20, Blue)

    drawText(discriminantText, 20, 270, 20, DarkGreen)
    drawText(discriminantMeaning, 20, 290, 20, DarkGreen)

    endDrawing()
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow()
  # --------------------------------------------------------------------------------------

main()

#[
This lesson shows the clear difference:
- The FUNCTION `y = ax² + bx + c` is the entire red curve. 
  It's a "map" of all possible points.
- The EQUATION `ax² + bx + c = 0` asks a specific question: 
  "Where does that curve cross the line y=0 (the x-axis)?".
- The blue circles are the answers to that question.
]#
