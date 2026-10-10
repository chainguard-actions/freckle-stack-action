module Main where

import Hello (hello)

main :: IO ()
main = do
  if hello == "Hello, World!"
    then putStrLn "Tests passed!"
    else error "Test failed: unexpected value"
