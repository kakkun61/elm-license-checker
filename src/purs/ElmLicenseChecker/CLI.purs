module ElmLicenseChecker.CLI
  ( cli
  ) where

import Prelude
import ElmLicenseChecker.Foreign (init, License)
import Control.Monad.ST (ST)
import Control.Monad.ST as ST
import Data.Either (Either(Left, Right))
import Data.Maybe (Maybe(Just, Nothing), maybe, optional)
import Data.Traversable (for)
import Effect (Effect)
import Effect.Console as Console
import Effect.Exception (throw)
import Foreign.Object (Object)
import Foreign.Object as Object
import Foreign.Object.ST (STObject)
import Foreign.Object.ST (new, poke) as STObject
import Foreign.Object.ST.Unsafe (unsafeFreeze) as STObject
import Node.Buffer as Buffer
import Node.Encoding (Encoding(UTF8))
import Node.FS.Sync (readFile)
import Node.Path (FilePath)
import Node.Process (cwd)
import Options.Applicative as Opt
import Simple.JSON (readJSON)

type Option
  = { formatFile :: Maybe String }

type Format
  = { name :: Maybe String
    , version :: Maybe String
    , summary :: Maybe String
    , license :: Maybe String
    , licenseText :: Maybe String
    , licenseFile :: Maybe String
    -- compat for license checker
    , description :: Maybe String
    , licenses :: Maybe String
    , copyright :: Maybe String
    , licenseModified :: Maybe String
    }

foreign import treeify :: Object (Object String) -> String

cli :: Effect Unit
cli = do
  option <- Opt.execParser $ Opt.info (parser Opt.<**> Opt.helper) Opt.fullDesc
  format <- for option.formatFile \path -> readFormat path
  workDir <- cwd
  licenses <- init workDir
  Console.log $ treeify $ maybe identity filterFields format <$> licenses

parser :: Opt.Parser Option
parser = ado
  formatFile <-
    optional
      $ Opt.strOption
          (Opt.long "customPath" <> Opt.metavar "PATH" <> Opt.help "to add a custom Format file in JSON")
  in { formatFile: formatFile }

readFormat :: FilePath -> Effect Format
readFormat path = do
  buf <- readFile path
  str <- Buffer.toString UTF8 buf
  case readJSON str of
    Right json -> pure json
    Left e -> throw $ "readFormat: " <> path <> ": " <> show e

filterFields :: Format -> License -> License
filterFields format license = ST.run go
  where
  go :: forall r. ST r License
  go = do
    obj <- STObject.new
    field (\f -> f.name) (Just "name") "name" obj
    field (\f -> f.version) (Just "version") "version" obj
    field (\f -> f.summary) (Just "summary") "summary" obj
    field (\f -> f.license) (Just "license") "license" obj
    field (\f -> f.licenseText) (Just "licenseText") "licenseText" obj
    field (\f -> f.licenseFile) (Just "licenseFile") "licenseFile" obj
    -- compat for license checker
    field (\f -> f.description) (Just "summary") "description" obj
    field (\f -> f.licenses) (Just "license") "licenses" obj
    field (\f -> f.copyright) Nothing "copyright" obj
    field (\f -> f.licenseModified) Nothing "licenseModified" obj
    STObject.unsafeFreeze obj

  field :: forall r. (Format -> Maybe String) -> Maybe String -> String -> STObject r String -> ST r Unit
  field f nr nw o =
    flip (maybe (pure unit)) (f format)
      $ \def ->
          void $ flip (STObject.poke nw) o
            $ maybe def identity
            $ nr
            >>= flip Object.lookup license
