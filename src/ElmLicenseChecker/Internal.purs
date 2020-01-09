module ElmLicenseChecker.Internal
  ( License
  , Version
  , init
  ) where

import Prelude
import Data.Array (some, uncons)
import Data.Char.Unicode as Char
import Data.Either (Either(Left, Right))
import Data.Maybe (Maybe(Nothing, Just))
import Data.Semigroup.First (First(First))
import Data.String.Common (split)
import Data.String.Pattern (Pattern(Pattern))
import Data.String.Read (class Read, read)
import Data.TraversableWithIndex (forWithIndex)
import Effect (Effect)
import Effect.Exception (throw)
import Foreign (ForeignError(ForeignError))
import Foreign as Foreign
import Foreign.Object (Object)
import Node.Buffer as Buffer
import Node.Encoding (Encoding(UTF8))
import Node.FS.Sync (exists, readFile)
import Node.Path (FilePath, sep)
import Node.Platform (Platform(Win32))
import Node.Process (lookupEnv, platform)
import Simple.JSON (class ReadForeign, readJSON)
import Text.Parsing.Parser (runParser)
import Text.Parsing.Parser (fail) as P
import Text.Parsing.Parser.String (char) as P
import Text.Parsing.Parser.Token (digit) as P

newtype Version
  = Version { major :: Int, minor :: Int, patch :: Int }

-- https://github.com/elm/compiler/blob/master/docs/elm.json/application.md
type ElmJsonApplication
  = { "elm-version" :: Version
    , dependencies ::
      { direct :: Object Version
      , indirect :: Object Version
      }
    , license :: Maybe String
    }

-- https://github.com/elm/compiler/blob/master/docs/elm.json/package.md
type ElmJsonPackage
  = { name :: String
    , summary :: Maybe String
    , license :: Maybe String
    , version :: Version
    , "elm-version" :: Version
    , dependencies :: Object Version
    }

type License
  = { name :: String
    , version :: Version
    , summary :: Maybe String
    , license :: Maybe String
    , licenseText :: Maybe String
    , licenseFile :: Maybe FilePath
    }

instance showVersion :: Show Version where
  show (Version v) = show v.major <> "." <> show v.minor <> "." <> show v.patch

instance readVersion :: Read Version where
  read str = e2m $ runParser str parser
    where
    e2m (Left e) = Nothing

    e2m (Right a) = Just a

    m2p Nothing = P.fail "m2p"

    m2p (Just a) = pure a

    parser = do
      maybeMajor <- da2i <$> some P.digit
      void $ P.char '.'
      maybeMinor <- da2i <$> some P.digit
      void $ P.char '.'
      maybePatch <- da2i <$> some P.digit
      m2p do
        major <- maybeMajor
        minor <- maybeMinor
        patch <- maybePatch
        pure $ Version { major, minor, patch }
      where
      da2i :: Array Char -> Maybe Int
      da2i a = go 0 a
        where
        go :: Int -> Array Char -> Maybe Int
        go acc b = case uncons b of
          Just u -> do
            i <- Char.digitToInt u.head
            go (10 * acc + i) u.tail
          Nothing -> pure acc

derive instance eqVersion :: Eq Version

derive instance ordVersion :: Ord Version

instance readForeignVersion :: ReadForeign Version where
  readImpl raw = do
    str <- Foreign.readString raw
    case read str of
      Just ver -> pure ver
      Nothing -> Foreign.fail $ ForeignError "version parsing failed"

getElmHome :: Effect FilePath
getElmHome = case platform of
  Just Win32 -> do
    maybeAppData <- lookupEnv "APPDATA"
    case maybeAppData of
      Just appData -> pure $ appData <> sep <> "elm"
      Nothing -> throw "the environment variable \"APPDATA\" not found"
  Just _ -> do
    maybeHome <- lookupEnv "HOME"
    case maybeHome of
      Just home -> pure $ home <> sep <> ".elm"
      Nothing -> throw "the environment variable \"HOME\" not found"
  Nothing -> throw "unknown platform"

getElmPackagesPath :: Version -> Effect FilePath
getElmPackagesPath version = do
  elmHome <- getElmHome
  pure $ elmHome <> sep <> show version <> sep <> "packages"

readElmJson :: forall json. ReadForeign json => FilePath -> Effect json
readElmJson dir = do
  buf <- readFile $ dir <> sep <> "elm.json"
  str <- Buffer.toString UTF8 buf
  case readJSON str of
    Right json -> pure json
    Left e -> throw $ "readElmJson: " <> dir <> ": " <> show e

readElmJsonApplication :: FilePath -> Effect ElmJsonApplication
readElmJsonApplication = readElmJson

readElmJsonPackage :: FilePath -> Effect ElmJsonPackage
readElmJsonPackage = readElmJson

init :: FilePath -> Effect (Object License)
init dir = do
  meta <- readElmJsonApplication dir
  packagesPath <- getElmPackagesPath meta."elm-version"
  let
    deps = (\(First a) -> a) <$> (First <$> meta.dependencies.direct) <> (First <$> meta.dependencies.indirect)
  forWithIndex deps \id version -> case split (Pattern "/") id of
    [ owner, name ] -> do
      let
        path = packagesPath <> sep <> owner <> sep <> name <> sep <> show version
      json <- readElmJsonPackage path
      license <- do
        let
          licensePath = path <> sep <> "LICENSE"
        ex <- exists licensePath
        if ex then do
          buf <- readFile licensePath
          (\text -> { file: Just licensePath, text: Just text }) <$> Buffer.toString UTF8 buf
        else
          pure { file: Nothing, text: Nothing }
      pure
        { name: id
        , version: json.version
        , summary: json.summary
        , license: json.license
        , licenseText: license.text
        , licenseFile: license.file
        }
    _ -> throw $ "a package name is not splitted into 2 by \"/\": " <> id
