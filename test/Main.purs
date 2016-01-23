module Test.Main where

import Prelude
import Control.Monad.Eff
import Control.Monad.Eff.Console
import Main as MainMain

main :: forall e. Eff (console :: CONSOLE | e) Unit
main = do
  MainMain.main
  log "You should add some tests."
