module Foo where

import Prelude
import Control.Monad.Eff
import Control.Monad.Eff.Console

foreign import nodeUpper :: String -> String

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  let foo = "Not Upper"
  log $ "Is '" <> foo <> "' uppercase? -> " <> (nodeUpper foo)
