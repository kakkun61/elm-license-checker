module ElmLicenseChecker.Foreign
  ( License
  , Config
  , init
  ) where

import Prelude
import ElmLicenseChecker.Internal as Internal
import Control.Monad.ST (ST)
import Control.Monad.ST as ST
import Data.Either (Either(Left, Right))
import Data.Maybe (Maybe(Just, Nothing), maybe)
import Data.Traversable (for)
import Data.Tuple (Tuple(Tuple))
import Effect (Effect)
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
import Simple.JSON (readJSON)

type License
  = Object String

type Config
  = Object String

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

init :: FilePath -> Config -> Effect (Object License)
init path config = do
  format <- for (Object.lookup "customPath" config) readFormat
  map (map $ maybe identity filterFields format)
    $ map toForeignLicenses
    $ Internal.init path

toForeignLicenses :: Object Internal.License -> Object License
toForeignLicenses =
  Object.fromFoldable
    <<< map (\(Tuple name license) -> Tuple (name <> "@" <> show license.version) $ toForeignLicense license)
    <<< (Object.toUnfoldable :: Object Internal.License -> Array (Tuple String Internal.License))

toForeignLicense :: Internal.License -> License
toForeignLicense l =
  ST.run do
    obj <- STObject.new
    void $ STObject.poke "name" l.name obj
    void $ STObject.poke "version" (show l.version) obj
    maybe (pure unit) (void <<< (\v -> STObject.poke "summary" v obj)) l.summary
    maybe (pure unit) (void <<< (\v -> STObject.poke "license" v obj)) l.license
    maybe (pure unit) (void <<< (\v -> STObject.poke "licenseText" v obj)) l.licenseText
    maybe (pure unit) (void <<< (\v -> STObject.poke "licenseFile" v obj)) l.licenseFile
    STObject.unsafeFreeze obj

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
