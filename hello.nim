echo "Hello, world!"

echo "This is a simple Nim program."
echo "It demonstrates basic syntax and output."
echo "Nim is a statically typed compiled systems programming language."
echo "You can run this program using the Nim compiler."
echo "To compile, use the command: nim c -r hello.nim"
echo "Enjoy coding in Nim!"

var name: string = "Nim"
let age: int = 10
echo "Welcome to the world of ", name, " programming!"
echo "Nim has been around for ", age, " years."

for i in 1..5:
  echo "This is line number ", i

# types are usually inferred but use them in procedure parameters..

proc greet(user: string) =
  echo "Hello, ", user, "! Welcome to Nim programming."
greet("Developer")

# A comment

let pi = 3.1416 # pi is approximately 3.1416

var count = 0
for i in 1..10:
  count += i
echo "The sum of numbers from 1 to 10 is ", count

import strutils
let message = "Nim is fun!"
echo message.toUpper()

echo "hello world".toUpper()         # "HELLO WORLD"
echo "a,b,c".split(",")              # @["a", "b", "c"]
echo "  Nim  ".strip()               # "Nim"
echo "42".parseInt()                 # 42

import math

echo pi.round(2)  # Rounds pi to 2 decimal places
