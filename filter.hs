import Text.Pandoc
import Data.List (isInfixOf)
import Text.Regex.Posix
import Web.Encodings (encodeHtml)

main = toJsonFilter processBlock

data Args =
  Args { includeFile :: Maybe String
       , firstLine   :: Maybe Int
       , lastLine    :: Maybe Int
       , beginMarker :: Maybe String
       , endMarker   :: Maybe String
       , promptRegex :: Maybe String
       }

defaultArgs :: Args
defaultArgs = Args Nothing Nothing Nothing Nothing Nothing Nothing

processArgs :: [(String,String)] -> (Args, [(String,String)])
processArgs [] = (defaultArgs, [])
processArgs ((k,v):kvs) = case k of
    "include" -> (arg {includeFile = Just v}, rest)
    "first"   -> (arg {firstLine   = Just $ read v}, rest)
    "last"    -> (arg {lastLine    = Just $ read v}, rest)
    "begin"   -> (arg {beginMarker = Just v}, rest)
    "end"     -> (arg {endMarker   = Just v}, rest)
    "prompt"  -> (arg {promptRegex = Just v}, rest)
    _         -> (arg, (k,v):rest)
  where
    (arg, rest) = processArgs kvs

processBlock :: Block -> IO Block
processBlock (cb@(CodeBlock (i,cs,kvs) body)) = do
  let (args, kvs') = processArgs kvs
  body' <- maybe (return body) readFile (includeFile args)
  let ls = rewrite args $ lines body'
  let k = chop . unlines
  case promptRegex args of
    Just regex ->
      return $ promptBlock $ k $ map (highlightCmd regex . encodeHtml) ls
    Nothing ->
      return $ CodeBlock (i,cs,kvs') $ k ls
processBlock b = return b

promptBlock :: String -> Block
promptBlock body =
  RawBlock "html" $ "<pre class=\"sourceCode\">" ++ body ++ "</pre>\n"

rewrite :: Args -> [String] -> [String]
rewrite args = doMarkers . doFirst . doLast
  where
    doLast = maybe id take $ lastLine args
    doFirst = maybe id (drop . flip (-) 1) $ firstLine args
    doMarkers = maybeMarkers (beginMarker args) (endMarker args)

maybeMarkers Nothing Nothing xs = xs
maybeMarkers (Just b) Nothing xs = tail $ dropWhile (not . isInfixOf b) xs
maybeMarkers Nothing (Just e) xs = takeWhile (not . isInfixOf e) xs
maybeMarkers (Just b) (Just e) xs = dropp xs
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
