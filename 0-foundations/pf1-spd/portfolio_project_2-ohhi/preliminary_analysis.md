# Preliminary Analysis

## Data and Structure Definitions

### `block` (`x` and `o`)

A `block` is one of:

- `x`,
- `o`, and
- `n`.

They are the block elements of the game, where

- `x` - represents the blue blocks,
- `o` - represents the yellow blocks, and
- `n` - represents a null block.

### `side-length`

A `side-length` is an integer greater than or equal to 2, which represents the side length of the board.

### `position`

A `position` is a 0-index position of a block in the board.

Given a board of side length `s`, the `position` ranges from $0$ to $s^2 - 1$.

### `positions`

A `positions` is the list of positions of a given board.

Given a board of side length `s`, the `positions` is $[0, \ldots , s^2 - 1]$.

### `board`

An `board` is the list of blocks of a given board.

## Proof for `next-boards`

1. Find the first N and return its Position. ✔️
2. Using `map`, produce list of at most two boards where the first N is replaced by B and Y. ✔️
3. Filter out invalid resulting boards. (filter-boards)

### Proof for `filter-boards`

1. Get the board side length (using `get-side-length`).
2. From the side length, return the list of PosLists with the same row/column. Call them units. Call the function `get-units`.
    - Example 1 (4X4): In (list 0 1 2 3) would be a unit because the positions are in the same first row.
    - Example 2 (5X5): (list 1 6 11 16 21) would be a unit because the positions are in the same second column.

```
(list B B Y Y
      B Y B Y
      Y B Y B
      N N Y B)


(list 0  1  2  3
      4  5  6  7
      8  9  10 11
      12 13 14 15)

<!-- get size, which is 4 -->

rows:
[0, 1, 2, 3]
```

3. From the units, return a list of
   (list Block), let's call them BlockList for now, from those units. ✔️
4. Filter 1: Filter out boards where _there are three consecutive blue blocks or three consecutive yellow blocks_. If there are any consecutive null blocks, don't filter them out. ✔️
5. Filter 2: Filter out boards where the number of blocks of a certain color exceed the maximum. For example, A 4x4 board can't have any row or column that has three blue blocks or three yellow blocks, since the maximum for each row and column for both color is 2. ✔️
6. **Filter 3**: Filter out boards that have either at least two rows or two columns that are identical. ✔️

### Proof for `get-side-length`

First implement a function that gets the number of Positions in a PosList, called `get-size`. ✔️

1. If empty, return 0.
2. Else, add 1 and recurse.

Now that you have `get-size`, get the number of positions from a given board. Assume you have a valid board, and thus it must return a valid square.

`get-side-length` returns the square root from the given number from `get-size`.

### Proof for `get-first-null` ✔️

This is a tail-recursive function with an accumulator called i.

1. If empty, return #f.
2. Else, if null, return i.
3. Else, if not null, recurse while i = i + 1.
