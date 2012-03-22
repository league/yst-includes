import Text.Pandoc

main = toJsonFilter processBlock

processBlock :: Block -> IO Block
processBlock (cb@(CodeBlock (i,cs,kvs) _)) =
  case lookup "include" kvs of
    Just f -> readFile f >>= return . CodeBlock (i,cs,kvs) . rewrite kvs
    Nothing -> return cb
processBlock b = return b

rewrite :: [(String,String)] -> String -> String
rewrite kvs = chop . unlines . doFirst . doLast . lines
  where doFirst = maybeLinesF "first" (drop . (flip (-) 1) . read) kvs
        doLast = maybeLinesF "last" (take . read) kvs

maybeLinesF :: String -> (String -> [String] -> [String])
    -> [(String,String)] -> [String] -> [String]
maybeLinesF key f kvs xs =
  case lookup key kvs of
    Just v -> f v xs
    Nothing -> xs

chop :: String -> String
chop s =
  case reverse s of
    '\n' : rs -> reverse rs
    _ -> s
