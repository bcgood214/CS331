-- Benjamin Goodbye
-- CS331
-- 3/30/2021
-- A program to calculate the median in a set of integers. This was a part of assignment 5.

module PA5 where


import Data.List

getInput [] = do
	putStrLn "Enter the first integer (blank to end): "
	userIn <- getLine
	if userIn == ""
		then return []
		else getInput [(read userIn :: Int)]
		

getInput xs = do
	putStrLn "Enter an integer (blank line to end): "
	userIn <- getLine
	if userIn == ""
		then return xs
		else getInput (xs ++ [(read userIn :: Int)])


-- this function was for a preliminary test

-- getInput str = do
	-- putStrLn str
	-- putStrLn "Enter something here: "
	-- userIn <- getLine
	-- if userIn == ""
		-- then return str
		-- else getInput userIn

main = do
	putStrLn "Enter a list of integers, one on each line."
	userList <- getInput []
	
	if null userList
		then do
			putStrLn "Empty list - no median"
		else do
			print ((sort userList)!!(div (length userList) 2))
	
	putStrLn "Compute another median? (y/n)"
	answer <- getLine
	
	if answer == "y"
		then main
		else putStrLn "Goodbye!"
	
	-- This part was for a preliminary test
	-- putStrLn "Enter something to start out: "
	-- n <- getLine
	-- finalIn <- getInput n
	-- putStrLn finalIn
	