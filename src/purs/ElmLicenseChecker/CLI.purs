module ElmLicenseChecker.CLI
  ( cli
  ) where

import Prelude
import ElmLicenseChecker.Foreign (init, Config)
import Control.Monad.ST as ST
import Data.Maybe (maybe, optional)
import Effect (Effect)
import Effect.Console as Console
import Foreign.Object (Object)
import Foreign.Object.ST (new, poke) as STObject
import Foreign.Object.ST.Unsafe (unsafeFreeze) as STObject
import Node.Process (cwd)
import Options.Applicative as Opt

foreign import treeify :: Object (Object String) -> String

cli :: Effect Unit
cli = do
  config <- Opt.execParser $ Opt.info (parser Opt.<**> Opt.helper) Opt.fullDesc
  workDir <- cwd
  licenses <- init workDir config
  Console.log $ treeify $ licenses

parser :: Opt.Parser Config
parser = ado
  formatFile <-
    optional
      $ Opt.strOption
          (Opt.long "customPath" <> Opt.metavar "PATH" <> Opt.help "Add a custom format file in JSON")
  in ST.run do
    obj <- STObject.new
    maybe (pure unit) (\v -> void $ STObject.poke "customPath" v obj) formatFile
    STObject.unsafeFreeze obj
