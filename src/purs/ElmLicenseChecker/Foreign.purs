module ElmLicenseChecker.Foreign
  ( License
  , init
  ) where

import Prelude
import ElmLicenseChecker.Internal as Internal
import Control.Monad.ST as ST
import Data.Maybe(maybe)
import Data.Tuple (Tuple (Tuple))
import Effect (Effect)
import Foreign.Object (Object)
import Foreign.Object as Object
import Foreign.Object.ST (new, poke) as STObject
import Foreign.Object.ST.Unsafe (unsafeFreeze) as STObject
import Node.Path (FilePath)

type License
  = Object String

init :: FilePath -> Effect (Object License)
init = map toForeignLicenses <<< Internal.init

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
