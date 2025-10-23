import math, sequtils, os, strutils

var limit: int

if paramCount() > 0:
  try:
    limit = parseInt(paramStr(1))
  except ValueError:
    echo "Error: Invalid number provided as command-line argument."
    quit(1)
else:
  while true:
    stdout.write "Find prime numbers up to: "
    try:
      limit = parseInt(readLine(stdin))
      break
    except ValueError:
      echo "Invalid input. Please enter an integer."

let limit_root = int(sqrt(float(limit)))

var isPrime = newSeqWith(limit + 1, true)

isPrime[0] = false
isPrime[1] = false

for p in 2..limit_root:
  if isPrime[p]:
    var i = p * p
    while i <= limit:
      isPrime[i] = false
      i += p

let primes = toSeq(2..limit).filter(proc(i: int): bool = isPrime[i])

echo "Found ", primes.len, " prime numbers up to ", limit, ":"
#echo primes

while true:
  stdout.write "Do you want to find the Nth prime? (y/n): "
  let choice = readLine(stdin).strip().toLower()

  if choice == "y":
    while true:
      stdout.write "Enter N: "
      try:
        let n_str = readLine(stdin)
        let n = parseInt(n_str)

        if n > 0 and n <= primes.len:
          echo "The ", n, "th prime is: ", primes[n-1]
          break 
        else:
          echo "N must be between 1 and ", primes.len, "."
      except ValueError:
        echo "Invalid input. Please enter an integer for N."
  elif choice == "n":
    break 
  else:
    echo "Invalid choice. Please enter 'y' or 'n'."
