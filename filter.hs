import Text.Pandoc
import Data.List (isInfixOf)
import Text.Regex.Posix
import Web.Encodings (encodeHtml)

main = toJsonFilter processBlock

processBlock :: Block -> IO Block
processBlock (cb@(CodeBlock (i,cs,kvs) body)) =
  case lookup "include" kvs of
    Just f -> readFile f >>= return . CodeBlock (i,cs,kvs) . rewrite kvs
    Nothing ->
      case lookup "prompt" kvs of
        Just regex -> return $ RawBlock "html" $ "<pre class=\"sourceCode\">" ++ (asLines (map $ highlightCmd regex) (encodeHtml body)) ++ "</pre>\n"
        Nothing -> return cb
processBlock b = return b

asLines :: ([String] -> [String]) -> String -> String
asLines f = unlines . f . lines

rewrite :: [(String,String)] -> String -> String
rewrite kvs = chop . asLines (doMarkers . doFirst . doLast)
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
    (Just b, Nothing) -> tail $ dropWhile (not . isInfixOf b) xs
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

highlightCmd :: String -> String -> String
highlightCmd regex s =
  case s =~ regex of
    (before, "", "") -> before
    (before, match, "") ->
      before ++ "<span class=\"prompt\">" ++ match ++ "</span>"
    (before, match, after) ->
      before ++ "<span class=\"prompt\">" ++ match ++ "</span>" ++
        "<span class=\"cmd\">" ++ after ++ "</span>"
