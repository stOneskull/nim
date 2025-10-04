type
  Person = object
    name: string
    age: int

proc introduce(p: Person) =
  echo "Hello, my name is ", p.name, " and I am ", p.age, " years old."
  if p.age < 18:
    echo "I am a minor."
  elif p.age >= 18 and p.age < 65:
    echo "I am an adult."
  else:
    echo "I am a senior citizen."


import random

proc age(): int =
  randomize()
  return rand(2..123)

var person1 = Person(name: "Alice", age: age())
introduce(person1)
let person2 = Person(name: "Bob", age: age())
introduce(person2)
person1.age += 1
introduce(person1)
# person2.age += 1
# expression 'person2.age' is immutable, not 'var'