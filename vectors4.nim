# ****************************************************************************************
#
#   raylib [vectors] lesson 4 - The Essence of Matrices (Linearity)
#
#   This lesson demonstrates the core principle of linear algebra:
#   - A matrix represents a "linear transformation".
#   - A linear transformation is defined by where the basis vectors land.
#   - We can predict the transformation of any vector by breaking it down into
#     its basis components, transforming them, and adding the results.
#     T(v) = T(x*i + y*j) = x*T(i) + y*T(j)
#
# ****************************************************************************************


#[ A Brief History of Matrices

The concept of a matrix—a rectangular array of numbers—has roots going back to ancient China, but its modern development began in the mid-19th century. The English mathematician Arthur Cayley is credited with introducing the matrix as a distinct object in 1858. He developed matrix algebra, including addition, subtraction, multiplication, and inversion. Initially, it was a niche mathematical curiosity. It wasn't until the 1920s, with the advent of quantum mechanics, that matrices became an essential tool for physicists. In the 1960s and 70s, as computer graphics emerged, pioneers realized that matrix multiplication was the perfect, efficient way to perform the geometric transformations (rotate, scale, translate) needed to render 2D and 3D scenes. ]#


#[ This lesson will demonstrate the two fundamental properties of a linear transformation:

Additivity: T(v + w) = T(v) + T(w)
Homogeneity: T(c * v) = c * T(v)

We will show that if you know where the basis vectors (i-hat = (1,0) and j-hat = (0,1)) land 
after a transformation, you can determine where any other vector will land. This is the "mini arithmetic" ]#


import raylib
import raymath
import math

const
  screenWidth = 800
  screenHeight = 450
  GRID_SIZE = 50

proc main =
  initWindow(screenWidth, screenHeight, "raylib [vectors] lesson 4 - Linearity")
  setTargetFPS(60)

  # The origin of our coordinate system on the screen.
  let origin = Vector2(x: 150, y: screenHeight / 2.0)

  # LESSON 1: BASIS VECTORS
  # In 2D, any vector can be described as a combination of two basis vectors:
  # i_hat points along the x-axis, and j_hat points along the y-axis.
  let i_hat = Vector2(x: 1.0, y: 0.0)
  let j_hat = Vector2(x: 0.0, y: 1.0)

  # Let's define a point 'p' using these basis vectors.
  # p = 2*i_hat + 1*j_hat = (2, 1)
  let p = i_hat * 2.0 + j_hat * 1.0

  # LESSON 2: A LINEAR TRANSFORMATION
  # "T" is standard notation for a Transformation function.
  # T(v) means "the result of applying transformation T to vector v".
  # T(i) is the transformed i_hat vector, and T(j) is the transformed j_hat.
  # A transformation is just a function that takes a vector and returns a new one.
  # We define our transformation by saying where the basis vectors should land.
  # Let's define a "shear" transformation.
  # This shears i_hat "down" in screen coordinates (by adding a positive Y).
  let i_hat_transformed = Vector2(x: 1.0, y: 0.5)
  # This shears j_hat "right" in screen coordinates (by adding a positive X).
  let j_hat_transformed = Vector2(x: 0.5, y: 1.0)

  # The columns of a transformation matrix are simply the transformed basis vectors!
  # Our transformation matrix M would look like this:
  # | i_hat_transformed.x   j_hat_transformed.x |   | 1.0   0.5 |
  # | i_hat_transformed.y   j_hat_transformed.y | = | 0.5   1.0 |

  # Main game loop
  # --------------------------------------------------------------------------------------
  while not windowShouldClose():
    # Update
    # ----------------------------------------------------------------------------------
    # LESSON 3: "BEHIND THE SCENES" MATRIX MULTIPLICATION
    # To find where our point 'p' lands, we don't need a matrix library.
    # We just apply the rule of linearity: T(2*i + 1*j) = 2*T(i) + 1*T(j)
    # This is the "mini arithmetic" you described.
    let p_transformed = i_hat_transformed * p.x + j_hat_transformed * p.y

    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)

    # --- Draw the original coordinate space ---
    let p_screen = origin + p * GRID_SIZE
    drawText("Original Space", origin.x.int32 - 50, origin.y.int32 - 150, 20, LightGray)
    # Draw original basis vectors
    let i_hat_end = origin + i_hat * GRID_SIZE
    let j_hat_end = origin + j_hat * GRID_SIZE # Add to draw downwards
    drawLine(origin, i_hat_end, 3.0, Red)   # i_hat (points right)
    drawLine(origin, j_hat_end, 3.0, Green) # j_hat
    drawText("i", i_hat_end.x.int32 + 5, i_hat_end.y.int32 + 5, 20, Red)
    drawText("j", j_hat_end.x.int32 + 5, j_hat_end.y.int32, 20, Green)
    # Draw the components of vector p
    let p_comp_end = origin + i_hat * p.x * GRID_SIZE
    drawLine(origin, p_comp_end, 2.0, fade(Red, 0.5))
    drawLine(p_comp_end, p_screen, 2.0, fade(Green, 0.5))
    # Draw the original point p
    drawCircle(p_screen, 7, DarkBlue)
    drawText("p = 2i + 1j", p_screen.x.int32 + 10, p_screen.y.int32, 20,
             DarkBlue)

    # --- Draw the transformed coordinate space ---
    let transformed_origin = Vector2(x: 500, y: screenHeight / 2.0)
    let p_transformed_screen = transformed_origin + p_transformed * GRID_SIZE
    drawText("Transformed Space", transformed_origin.x.int32 - 70,
             120, 20, Gray)
    # Draw transformed basis vectors
    let ti_hat_end = transformed_origin + i_hat_transformed * GRID_SIZE
    let tj_hat_end = transformed_origin + j_hat_transformed * GRID_SIZE
    drawLine(transformed_origin, ti_hat_end, 3.0, Red)   # T(i) (sheared down)
    drawLine(transformed_origin, tj_hat_end, 3.0, Green) # T(j)
    drawText("T(i)", ti_hat_end.x.int32 + 5, ti_hat_end.y.int32 + 5, 20, Red)
    drawText("T(j)", tj_hat_end.x.int32 + 5, tj_hat_end.y.int32, 20, Green)
    # Draw the transformed components
    let p_comp1 =
      transformed_origin + i_hat_transformed * p.x * GRID_SIZE
    drawLine(transformed_origin, p_comp1, 2.0, fade(Red, 0.5))
    drawLine(p_comp1, p_transformed_screen, 2.0, fade(Green, 0.5))
    # Draw the transformed point p
    drawCircle(p_transformed_screen, 7, Purple)
    drawText("T(p) = 2*T(i) + 1*T(j)", p_transformed_screen.x.int32 - 100,
             p_transformed_screen.y.int32 + 15, 20, Purple)

    drawText("A matrix just stores where the basis vectors land.", 20, 20, 20, DarkGray)
    drawText("The columns of the matrix ARE the transformed basis vectors.", 20, 50, 20, DarkGray)
    drawText("T(v) means 'the result of applying Transformation T to vector v'.", 20, 80, 20, DarkGray)

    # Display the matrix for this transformation
    drawText("T = ", 20, 120, 20, DarkGray)
    drawText("| 1.0  0.5 |", 70, 110, 20, DarkGray)
    drawText("| 0.5  1.0 |", 70, 130, 20, DarkGray)

    drawText("The first column is T(i), where i-hat lands.", 20, 160, 20, Red)
    drawText("The second column is T(j), where j-hat lands.", 20, 180, 20, Green)


    endDrawing()
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow()
  # --------------------------------------------------------------------------------------

main()

#[ What This Code Demonstrates
Original Space (Left Side): We draw the standard coordinate system. The red line is i-hat, the green is j-hat. We show how the point p is constructed by moving 2 units along i-hat and 1 unit along j-hat.

Transformed Space (Right Side): We first draw where our basis vectors land after our "shear" transformation. i-hat is now pointing to (1, 0.5) and j-hat is pointing to (-0.5, 1).

The Magic: To find the new position of p, we simply re-run the original instructions on the new grid. We move 2 units along the new red line and 1 unit along the new green line. The code does this with the line: let p_transformed = i_hat_transformed * p.x + j_hat_transformed * p.y

This visually proves that a matrix transformation is not some mystical black box. It's just a set of instructions for a simple, repeatable arithmetic process based on where the basis vectors end up. ]#