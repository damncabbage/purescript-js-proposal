module Bar where

import Prelude
import Control.Monad.Eff
import Control.Monad.Eff.Console

foreign import nodeLower :: String -> String

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  let bar = "all lower"
  log $ "Is '" <> bar <> "' lowercase? -> " <> (nodeLower bar)
