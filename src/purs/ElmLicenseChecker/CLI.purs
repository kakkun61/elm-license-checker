module ElmLicenseChecker.CLI
  ( cli
  ) where

import Prelude
import ElmLicenseChecker.Foreign (init)
import ElmLicenseChecker.Foreign as Lib
import Control.Monad.ST as ST
import Data.Maybe (Maybe (Just, Nothing), maybe, optional)
import Effect (Effect)
import Effect.Console as Console
import Foreign.Object (Object)
import Foreign.Object.ST (new, poke) as STObject
import Foreign.Object.ST.Unsafe (unsafeFreeze) as STObject
import Node.Encoding (Encoding(UTF8))
import Node.FS.Sync (writeTextFile)
import Node.Path (FilePath)
import Node.Process (cwd)
import Options.Applicative as Opt
import Simple.JSON (writeJSON)

type Config
  = { cli ::
        { json :: Boolean
        , out :: Maybe FilePath
        }
    , lib :: Lib.Config
    }

foreign import treeify :: Object (Object String) -> String

cli :: Effect Unit
cli = do
  config <- Opt.execParser $ Opt.info (parser Opt.<**> Opt.helper) Opt.fullDesc
  workDir <- cwd
  licenses <- init workDir config.lib
  let
    format =
      if config.cli.json
        then writeJSON
        else treeify
    output =
      case config.cli.out of
        Just path -> writeTextFile UTF8 path
        Nothing -> Console.log
  output $ format licenses

parser :: Opt.Parser Config
parser = ado
  formatFile <-
    optional
      $ Opt.strOption
          (Opt.long "customPath" <> Opt.metavar "PATH" <> Opt.help "Add a custom format file in JSON")
  json <-
    Opt.switch
      (Opt.long "json" <> Opt.help "Output in JSON format")
  out <-
    optional
      $ Opt.strOption
          (Opt.long "out" <> Opt.metavar "PATH" <> Opt.help "Write the data to a specific file")
  in
    { cli:
        { json: json
        , out: out
        }
    , lib:
        ST.run do
          obj <- STObject.new
          maybe (pure unit) (\v -> void $ STObject.poke "customPath" v obj) formatFile
          STObject.unsafeFreeze obj
    }
