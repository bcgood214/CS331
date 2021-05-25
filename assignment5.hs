collatz :: Int -> Int
collatz 0 = 0
collatz 1 = 1
collatz n = 
	if (even n)
		then (n 'div' n)
		else (3 * n + 1)

collatzSequence :: Int -> [Int]
collatzSequence n =
	if n == 1
		then [1]
		else [n] ++ collatzSequence (collatz n)
		
getCollatzCount n = length collatzSequence n

collatzCounts = [getCollatzCount i+1 | i <- [0..]]