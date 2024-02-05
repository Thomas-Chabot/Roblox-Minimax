--[[
	This library returns a simple method which can be called to run the Minimax algorithm.
	Minimax is useful for game AI as it allows your AI players to calculate the best move to make in a game against some determinant function.
	
	The algorithm works by trying to maximize our own value, while assuming that opponents will minimize our value.
	It works for turn-based games where each player moves in turn (player 1 -> player 2 -> player 1 -> player 2 -> ...).
	
	To call the function, you need to pass in the following arguments (in order):
		state: The starting state of the game.
		maxDepth: The number of turns deep to go (for example, if this is 3, then we'll check 3 turns: our turn, opponent, our turn).
		calculateTransitions(state, isOurTurn): Function to return all possible moves that can be made given a game state.
		applyTransition(state, transition): Makes a move, altering the state of the game in-place.
		undoTransition(state, transition): Reverses a move, setting the game state back to where it was before the move was made.
		calculateStateValue(state): Some sort of determinant function; given a game state, calculates a numerical value of that game state. Higher value is better.
		checkEndState(state): Returns a number indicating if we have reached an end state of the game (either we've won, or we've lost):
			< 0 if we have lost the game.
			= 0 if this is not an end state.
			> 0 if we have won the game.
]]

-- Internal type used for the minimax algorithm
type MinimaxResult<U> = {
	Value: number,
	Transition: U?
}

-- Constants
local MIN_VALUE = -9e9
local MAX_VALUE = 9e9

-- Runs the Minimax Algorithm, returning the best move to make at the given game state.
function Minimax<T, U>(state: T, maxDepth: number, 
	calculateTransitions: (state: T, isOurTurn: boolean) -> {U}, applyTransition: (state: T, transition: U)->nil, undoTransition: (state: T, transition: U)->nil,
	calculateStateValue: (state: T)->number, checkEndState: (state: T)->number
): U | undefined
	-- Call the minimax algorithm, passing in some default values along with the required parameters
	local result = runMinimaxAlgorithm(state, 0, maxDepth, true, MIN_VALUE, MAX_VALUE, calculateTransitions, applyTransition,
		undoTransition, calculateStateValue, checkEndState());
	
	return result.Transition
end

-- Main code to run the algorithm. Recursive; loops through every level to calculate the best move.
function runMinimaxAlgorithm<T, U>(state: T, depth: number, maxDepth: number, isOurTurn: boolean, alpha: number, beta: number,
	calculateTransitions: (state: T, isOurTurn: boolean) -> {U}, applyTransition: (state: T, transition: U)->nil, undoTransition: (state: T, transition: U)->nil,
	calculateStateValue: (state: T)->number, checkEndState: (state: T)->number): MinimaxResult
	
	-- If we've reached the target level, return the value of this state
	if depth == maxDepth then
		return {
			Value = calculateStateValue(state)
		}
	end
	
	-- If we've reached an end state, return the value based on the end state
	local isEndState = checkEndState(state)
	if isEndState < 0 then
		-- We lose the game
		-- Note: Add from the MIN_VALUE, so this doesn't run into issues with alpha/beta
		return {
			Value = MIN_VALUE + 1
		}
	elseif isEndState > 0 then
		-- We win the game
		return {
			Value = MAX_VALUE + 1
		}
	end
	
	-- Otherwise, calculate all the transitions we can make from the state and check through each path
	local transitions = calculateTransitions(state, isOurTurn)
	
	-- Error Check: If there's no transitions available, throw an error
	assert(#transitions > 0, `No transitions could be found from {state}. This is likely an error state; please check your end state function.`)
	
	-- Loop through every transition and find the best path to take
	-- Note: If it's our turn, we're maximizing the value; otherwise, we're looking for the minimum.
	local best = if isOurTurn then MIN_VALUE else MAX_VALUE
	local bestTransitions: {U} = { }
	
	for _,transition in transitions do
		-- Alpha-Beta Pruning: If our minimum exceeds our maximum, we can exit here
		if alpha > beta then
			break
		end
		
		-- Apply the transition
		applyTransition(state, transition)
		
		-- Calculate the value of this transition
		local result = runMinimaxAlgorithm(state, depth+1, maxDepth, not isOurTurn, alpha, beta, calculateTransitions,
			applyTransition, undoTransition, calculateStateValue, checkEndState)
		
		-- If this matches our best so far, add it to the list
		if best == result.Value then
			table.insert(bestTransitions, transition)
		elseif (isOurTurn and result.Value > best) or (not isOurTurn and result.Value < best) then
			-- This is our new best transition to make
			best = result.Value			
			bestTransitions = {transition}
			
			-- Update Alpha-Beta
			if isOurTurn then
				alpha = math.max(alpha, best)
			else
				beta = math.min(beta, best)
			end
		end
		
		-- Undo the change
		undoTransition(state, transition)
	end
	
	-- If we have no transitions, return blank
	if #bestTransitions == 0 then
		return {
			Value = best
		}
	end
	
	-- Otherwise, return a random transition from the list
	return {
		Value = best,
		Transition = bestTransitions[math.random(1, #bestTransitions)]
	}	
end


return Minimax