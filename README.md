A simple implementation of the Minimax Algorithm for turn-based two-player games.

Designed to be generic, making use of the Luau typing system. Only requirements are that turns must be taken in sequence - i.e. Player 2 will always move after Player 1, and Player 1 will always move after Player 2.

# Overview
Minimax is mostly used for turn-based games (things like Chess, Checkers, Connect 4, etc.). The algorithm allows you to find the optimal move that you might make at each turn, which helps to build smarter AI.

# 1. How It Works
The algorithm starts with a function that can convert a game state into a numerical value. In Chess, for example, this might be as simple as asking how many pieces you have remaining on the board.

The algorithm assumes that we'll try to optimize this value, while our opponent will try to minimize it. In the case of the number of pieces on the board, our goal will be to protect our pieces as much as we can, while our opponent's goal will be to destroy all the pieces that they can.

## 1.1. Depth
The algorithm takes in a "depth" argument which tells us how many layers deep we should go. For example, if our depth is 3, then we'll go 3 turns deep: we'll make a move, our opponent will make a move, and we'll make a move. We then provide a value to this end state - in the case of the number of pieces on the board, we would check our pieces after all three moves have been made.

## 1.2. Backtracking - MiniMax
The main logic of the algorithm takes place after we've reached our target depth on the board. From here, at each level, we can calculate the "best" move to make: when its our turn, we want to maximize the numerical state values; on an opponent's turn, we minimize these values. Our optimal move is whichever one returns our best value.

## 1.3 Alpha-Beta Pruning
Alpha-Beta Pruning is an additional step which can be added on top of the algorithm to help reduce the number of steps that have to be taken. Because we know at each level that we're either minimizing or maximizing our target values, we can pass in our current best through each branch being checked, and exit early if we determine that we can't bypass our best so far. This can drastically reduce the amount of work that has to be done.

## 1.4 More Information

# 2. Using the Library
I designed the function with the goal of having it be as generic as possible. In that manner, all board states and transitions are provided by generic type arguments, and several functions are used to progress between the states (i.e. each move).

More analysis is provided in the script itself, which refers to each parameter that has to be passed in. The code of the algorithm is also deeply commented so that it should be easy to read through and understand what the code is doing if you're interested.

# 3. Sample
The algorithm is currently being used in my [Checkers game](https://www.roblox.com/games/13914541275/Checkers) for the AI player Pierce.

# 4. More Information
Please take a look at the [Geeksforgeeks article on Minimax](https://www.geeksforgeeks.org/minimax-algorithm-in-game-theory-set-1-introduction/), which provides a more in-depth explanation of the algorithm.