import Text.Pandoc

main = toJsonFilter include

include :: Block -> IO Block
include (cb@(CodeBlock (i,cs,kvs) _)) =
  case lookup "include" kvs of
    Just f -> readFile f >>= return . CodeBlock (i,cs,kvs) . chop
    Nothing -> return cb
include b = return b

chop :: String -> String
chop s =
  case reverse s of
    '\n' : rs -> reverse rs
    _ -> s
