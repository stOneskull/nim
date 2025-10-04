import terminal

proc main() =
  echo "--- Terminal Formatting Demo ---"

  # --- Foreground Colors ---
  setForegroundColor(fgRed)
  echo "This text is red."
  setForegroundColor(fgYellow)
  echo "This text is yellow."
  resetAttributes() # Always reset after you're done!
  echo "This text is back to the default color."

  echo "--- Background Colors ---"
  setBackgroundColor(bgBlue)
  echo "This text has a blue background."
  resetAttributes()

  echo "--- Text Styles ---"
  setStyle({styleBright})
  echo "This text is bright (or bold)."
  resetAttributes()

  setStyle({styleUnderscore})
  echo "This text is underscored."
  resetAttributes()

  echo "--- Combining Everything ---"
  # To combine multiple styles, use a set: {style1, style2}
  setForegroundColor(fgBlue)
  setBackgroundColor(bgMagenta)
  setStyle({styleBright, styleUnderscore})
  echo "This is bright, underscored, cyan text on a magenta background!"
  resetAttributes() # Clean up everything at once.

  echo "--- End of Demo ---"

main()
