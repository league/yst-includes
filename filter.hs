import Text.Pandoc

main = toJsonFilter f
  where f :: Block -> IO Block
        f = return
