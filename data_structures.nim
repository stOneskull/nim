import tables, sets, strutils, sequtils

echo "=== Nim Data Structures Tutorial ==="
echo ""

# ====== ARRAYS ======
echo "1. ARRAYS - Fixed size, known at compile time"
echo "-------------------------------------------"

# Arrays have fixed size and are allocated on the stack
var numbers: array[5, int] = [1, 2, 3, 4, 5]
echo "Fixed array: ", numbers

# You can also declare arrays with ranges
var grades: array[1..3, float] = [85.5, 92.0, 78.5]
echo "Array with range indices: ", grades

# Accessing array elements
echo "First number: ", numbers[0]
echo "Last grade: ", grades[3]

# Modifying array elements
numbers[2] = 10
echo "After modification: ", numbers

# Array length
echo "Array length: ", numbers.len
echo ""

# ====== SEQUENCES ======
echo "2. SEQUENCES - Dynamic arrays, can grow/shrink"
echo "----------------------------------------------"

# Sequences are like dynamic arrays (similar to vectors in C++ or lists in Python)
var fruits = @["apple", "banana", "cherry"]
echo "Initial fruits: ", fruits

# Adding elements
fruits.add("date")
fruits.add("elderberry")
echo "After adding: ", fruits

# Inserting at specific position
fruits.insert("apricot", 1)
echo "After inserting apricot at position 1: ", fruits

# Removing elements
let removed = fruits.pop()  # removes and returns last element
echo "Removed: ", removed
echo "After pop: ", fruits

# Delete by index
fruits.delete(0)  # removes first element
echo "After deleting first element: ", fruits

# Sequence operations
echo "Length: ", fruits.len
echo "Is empty?: ", fruits.len == 0

# Creating sequences with @[] or newSeq
var numbers_seq = @[1, 2, 3, 4, 5]
var empty_seq: seq[int] = @[]
var sized_seq = newSeq[string](3)  # Creates sequence with 3 empty strings

echo "Numbers sequence: ", numbers_seq
echo "Empty sequence: ", empty_seq
echo "Sized sequence: ", sized_seq
echo ""

# ====== SETS ======
echo "3. SETS - Unique elements, fast membership testing"
echo "-------------------------------------------------"

# Sets contain unique elements
var colors = initHashSet[string]()
colors.incl("red")
colors.incl("green")
colors.incl("blue")
echo "Initial colors: ", colors

# Adding to set
colors.incl("yellow")
colors.incl("red")  # won't add duplicate
echo "After adding yellow and red again: ", colors

# Checking membership
echo "Contains 'red'?: ", "red" in colors
echo "Contains 'purple'?: ", "purple" in colors

# Set operations
var primary_colors = initHashSet[string]()
primary_colors.incl("red")
primary_colors.incl("green")
primary_colors.incl("blue")

var warm_colors = initHashSet[string]()
warm_colors.incl("red")
warm_colors.incl("orange")
warm_colors.incl("yellow")

echo "Primary colors: ", primary_colors
echo "Warm colors: ", warm_colors

# Union (combines sets)
var all_colors = primary_colors + warm_colors
echo "Union of primary and warm: ", all_colors

# Intersection (common elements)
var common_colors = primary_colors * warm_colors
echo "Intersection: ", common_colors

# Difference (elements in first but not second)
var cool_primaries = primary_colors - warm_colors
echo "Cool primaries (primary - warm): ", cool_primaries

# Set size
echo "Number of all colors: ", all_colors.len
echo ""

# ====== TABLES (Hash Maps/Dictionaries) ======
echo "4. TABLES - Key-value pairs, like dictionaries"
echo "---------------------------------------------"

# Creating a table (hash map/dictionary)
var student_grades = initTable[string, float]()

# Adding key-value pairs
student_grades["Alice"] = 95.5
student_grades["Bob"] = 87.2
student_grades["Charlie"] = 92.8

echo "Student grades: ", student_grades

# Accessing values
echo "Alice's grade: ", student_grades["Alice"]

# Checking if key exists
if "Bob" in student_grades:
  echo "Bob's grade: ", student_grades["Bob"]
else:
  echo "Bob not found"

# Using get with default value
echo "David's grade (default 0.0): ", student_grades.getOrDefault("David", 0.0)

# Iterating over table
echo "All students and grades:"
for name, grade in student_grades:
  echo "  ", name, ": ", grade

# Table operations
echo "Number of students: ", student_grades.len

# Removing from table
student_grades.del("Bob")
echo "After removing Bob: ", student_grades

# Getting all keys or values
echo "All student names: ", toSeq(student_grades.keys)
echo "All grades: ", toSeq(student_grades.values)
echo ""

# ====== PRACTICAL EXAMPLE ======
echo "5. PRACTICAL EXAMPLE - Word Frequency Counter"
echo "---------------------------------------------"

let text = "the quick brown fox jumps over the lazy dog the fox is quick"
var word_count = initTable[string, int]()

# Split text into words and count frequency
for word in text.split():
  if word in word_count:
    word_count[word] += 1
  else:
    word_count[word] = 1

echo "Word frequencies:"
for word, count in word_count:
  echo "  '", word, "': ", count

# Find most common word
var most_common = ""
var max_count = 0
for word, count in word_count:
  if count > max_count:
    max_count = count
    most_common = word

echo "Most common word: '", most_common, "' appears ", max_count, " times"
echo ""

# ====== NESTED DATA STRUCTURES ======
echo "6. NESTED DATA STRUCTURES"
echo "-------------------------"

# Table with sequence values
var shopping_lists = initTable[string, seq[string]]()
shopping_lists["groceries"] = @["milk", "bread", "eggs"]
shopping_lists["hardware"] = @["screws", "hammer", "nails"]

echo "Shopping lists:"
for category, items in shopping_lists:
  echo "  ", category, ": ", items

# Sequence of tables
type
  Product = object
    name: string
    price: float
    in_stock: bool

var inventory = @[
  Product(name: "Laptop", price: 999.99, in_stock: true),
  Product(name: "Mouse", price: 25.50, in_stock: false),
  Product(name: "Keyboard", price: 75.00, in_stock: true)
]

echo "Inventory:"
for item in inventory:
  let status = if item.in_stock: "In Stock" else: "Out of Stock"
  echo "  ", item.name, ": $", item.price, " - ", status

echo ""
echo "=== Tutorial Complete! ==="
echo "Try modifying this code and experiment with different data structures!"