import random, strutils, terminal

proc main() =
  # Initialize the random number generator
  randomize()

  let secretNumber = rand(1..100)
  var guessCount = 0

  echo "I'm thinking of a number between 1 and 100."
  echo "Can you guess what it is?"

  while true:
    stdout.write "Your guess: "
    stdout.flushFile() # Make sure "Your guess: " is printed before reading input

    let input = stdin.readLine()
    guessCount += 1

    try:
      let guess = parseInt(input)
      if guess < secretNumber:
        echo "Too low!"
      elif guess > secretNumber:
        echo "Too high!"
      else:
        setForegroundColor(fgGreen)
        echo "You got it! The number was ", secretNumber, "."
        echo "It took you ", guessCount, " guesses."
        resetAttributes() # Reset the terminal color back to default
        break 
    except ValueError:
      setForegroundColor(fgRed)
      echo "That's not a valid number. Please try again."
      resetAttributes()

main()
