import Text.Pandoc
import Data.List (isInfixOf)

main = toJsonFilter processBlock

processBlock :: Block -> IO Block
processBlock (cb@(CodeBlock (i,cs,kvs) _)) =
  case lookup "include" kvs of
    Just f -> readFile f >>= return . CodeBlock (i,cs,kvs) . rewrite kvs
    Nothing -> return cb
processBlock b = return b

rewrite :: [(String,String)] -> String -> String
rewrite kvs = chop . unlines . doMarkers . doFirst . doLast . lines
  where
    doMarkers = maybeMarkers kvs
    doLast = maybeLinesF "last" (take . read) kvs
    doFirst = maybeLinesF "first" (dropMinus1 . read) kvs
    dropMinus1 n = drop (n-1)

maybeLinesF :: String -> (String -> [String] -> [String])
    -> [(String,String)] -> [String] -> [String]
maybeLinesF key f kvs xs =
  case lookup key kvs of
    Just v -> f v xs
    Nothing -> xs

maybeMarkers kvs xs =
  case (lookup "begin" kvs, lookup "end" kvs) of
    (Nothing, Nothing) -> xs
    (Just b, Nothing) -> dropWhile (not . isInfixOf b) xs
    (Nothing, Just e) -> takeWhile (not . isInfixOf e) xs
    (Just b, Just e) -> dropp xs
      where dropp [] = []
            dropp (x:xs) = if isInfixOf b x then takke xs else dropp xs
            takke [] = []
            takke (x:xs) = if isInfixOf e x then dropp xs else x : takke xs

chop :: String -> String
chop s =
  case reverse s of
    '\n' : rs -> reverse rs
    _ -> s
