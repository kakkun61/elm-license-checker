module ElmLicenseChecker.CLI
  ( cli
  ) where

import Prelude
import ElmLicenseChecker.Foreign (init)
import Effect (Effect)
import Effect.Console as Console
import Foreign.Object (Object)
import Node.Process (cwd)

foreign import treeify :: Object (Object String) -> String

cli :: Effect Unit
cli = do
  workDir <- cwd
  licenses <- init workDir
  Console.log (treeify (licenses))
