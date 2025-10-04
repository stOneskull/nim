# godofoz (c) stOneskull 
# with assistance from Gemini
# prototype v.0.0.3

import strutils, tables, random, terminal

const
  BoardSize = 40
  WeekLength = 8
  DayNames = ["Moonday", "Marsday", "Mercuryday", "Jupiterday", "Venusday",
      "Saturnday", "Uranusday", "Sunday"]
  PyramidRotationPerDay = 5 # 45 degrees is 1/8th of the board, so 40/8 = 5

type
  SquareKind = enum
    skNormal, skHotel, skAir, skEarth, skFire, skWater, skDoorway

type
  Player = object
    name: string
    health, maxHealth: int
    strength, intelligence: int
    money: int
    position: int # The player's current square (0-39)
    bag: seq[string]

  GameState = object
    player: Player
    totalDays: int # Total days passed since the start
    board: Table[int, SquareKind]

proc initBoard(): Table[int, SquareKind] =
  ## Creates the game board with special squares.
  result = initTable[int, SquareKind]()
  result[1] = skHotel
  result[0] = skAir
  result[5] = skDoorway
  result[10] = skEarth
  result[15] = skDoorway
  result[20] = skFire
  result[25] = skDoorway
  result[30] = skWater
  result[35] = skDoorway

proc displayStatus(state: GameState) =
  ## Prints the current status of the player and the world.
  let dayOfWeek = state.totalDays mod WeekLength
  let currentMonth = (state.totalDays div BoardSize) + 1
  echo "---"
  echo "It is ", DayNames[dayOfWeek], " of Month ", currentMonth, "."
  let p = state.player
  echo p.name, " is at square ", p.position, "."
  echo "Health: ", p.health, "/", p.maxHealth, " | Str: ", p.strength,
      " | Int: ", p.intelligence, " | Money: $", p.money
  echo "Bag: ", p.bag.join(", ")

proc describeCurrentSquare(state: GameState) =
  ## Describes the square the player is on, including effects from the pyramid.
  let basePos = state.player.position
  let baseKind = state.board.getOrDefault(basePos, skNormal)

  # Calculate pyramid's rotation and what's above the player
  let pyramidOffset = (state.totalDays * PyramidRotationPerDay) mod BoardSize
  let pyramidPos = (basePos + pyramidOffset) mod BoardSize
  let pyramidKind = state.board.getOrDefault(pyramidPos, skNormal)

  # Check for elemental combinations first, as they are highest priority.
  # The set membership check `{skAir..skWater}` is a concise way to see if a
  # kind is one of the four elements.
  if baseKind in {skAir..skWater} and pyramidKind in {skAir..skWater}:
    if baseKind == pyramidKind:
      case baseKind:
      of skAir: echo "The very essence of Air concentrates here, making you feel light and clear-headed."
      of skEarth: echo "You feel an overwhelming connection to the stable ground, solid and unmoving."
      of skFire: echo "A pure, intense heat radiates from the ground, shimmering in the air."
      of skWater: echo "The air is saturated with the feeling of deep, flowing water, calm and powerful."
      else: discard # Should not happen
    else: # A combination of two different elements
      let combination = {baseKind, pyramidKind}
      if combination == {skFire, skWater}:
        echo "Billowing clouds of hot steam erupt from the ground around you."
      elif combination == {skAir, skEarth}:
        echo "The air is thick with swirling dust, making it hard to see and breathe."
      elif combination == {skAir, skFire}:
        echo "A blast of superheated air washes over you, scorching and dry."
      elif combination == {skAir, skWater}:
        echo "A thick, cool mist surrounds you, dampening all sound."
      elif combination == {skEarth, skFire}:
        echo "The ground beneath you feels hot and soft, like cooling magma."
      elif combination == {skEarth, skWater}:
        echo "The ground has turned into a soggy, sucking mud pit."
    return # We've described the square, so we can exit the procedure.

  # If no elemental combination, describe the base square.
  case baseKind:
  of skNormal:
    let encounters = ["You see a traveling merchant waving at you.",
                      "A strange, colorful bird lands on a nearby branch.",
                      "The path ahead seems quiet and uneventful.",
                      "You hear a distant rumble, but the sky is clear."]
    echo encounters[rand(encounters.low..encounters.high)]
  of skHotel:
    echo "You are standing in front of a large hotel. A sign reads 'The Weary Traveler'. You can hear music from the bar inside."
  of skAir: echo "You are on an Air element square. The air hums with a gentle energy."
  of skEarth: echo "You are on an Earth element square. You feel a deep connection to the ground."
  of skFire: echo "You are on a Fire element square. The air is warm and flickers with unseen heat."
  of skWater: echo "You are on a Water element square. A sense of flowing power is in the air."
  of skDoorway: echo "A large, ornate door is set into the inner wall. It is firmly locked."

proc move(state: var GameState) =
  ## Moves the player to the next square and advances the day.
  # Advance the player's position, wrapping around the board
  state.player.position = (state.player.position + 1) mod BoardSize

  # Advance the total day count
  state.totalDays += 1
  echo "You travel for a day..."

proc characterCreation(): Player =
  ## Guides the player through creating their character.
  echo "Welcome, traveler. What is your name?"
  var name = stdin.readLine().strip()
  if name.len == 0: name = "Dan" # Default name

  var strength = 40
  var intelligence = 40
  var pointsToAllocate = 20

  while pointsToAllocate > 0:
    echo "\nYou have ", pointsToAllocate, " points to allocate between Strength and Intelligence."
    echo "Current Stats -> Strength: ", strength, " | Intelligence: ", intelligence
    echo "How many points will you add to Strength?"
    stdout.write "Points: "
    stdout.flushFile()

    try:
      let pointsForStr = parseInt(stdin.readLine())
      if pointsForStr >= 0 and pointsForStr <= pointsToAllocate:
        strength += pointsForStr
        intelligence += (pointsToAllocate - pointsForStr)
        pointsToAllocate = 0 # Exit loop
      else:
        setForegroundColor(fgRed)
        echo "Invalid amount. Please enter a number between 0 and ",
            pointsToAllocate, "."
        resetAttributes()
    except ValueError:
      setForegroundColor(fgRed)
      echo "That's not a valid number. Please try again."
      resetAttributes()

  echo "\nCharacter creation complete!"
  return Player(
    name: name,
    health: 100, maxHealth: 100,
    strength: strength, intelligence: intelligence,
    money: 25,
    position: 0,
    bag: @["comb", "pen", "notepad"]
  )

proc main() =
  # Initialize the game state
  var state = GameState(
    player: characterCreation(),
    totalDays: 0, # Start on the first day (day 0)
    board: initBoard()
  )
  randomize() # Initialize the random number generator for encounters

  echo "Welcome to your adventure!"

  # Main game loop
  while true:
    displayStatus(state)

    # Check for win/loss conditions
    if state.player.health <= 0:
      setForegroundColor(fgRed)
      echo "\nYour health has fallen to zero. Your journey ends here."
      resetAttributes()
      break
    if state.player.strength <= 0 or state.player.intelligence <= 0:
      setForegroundColor(fgRed)
      echo "\nYour body or mind has failed. Your journey ends here."
      resetAttributes()
      break
    if state.player.strength >= 100 or state.player.intelligence >= 100:
      setForegroundColor(fgGreen)
      echo "\nYou have achieved a new state of being! You have won the game!"
      resetAttributes()
      break

    describeCurrentSquare(state)
    echo "What do you want to do? (move/quit)"
    let input = stdin.readLine().strip().toLower()

    if input == "move":
      move(state)
    elif input == "quit":
      echo "Goodbye!"
      break
    else:
      echo "Unknown command."

main()
