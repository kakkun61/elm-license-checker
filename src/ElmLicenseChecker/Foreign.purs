module ElmLicenseChecker.Foreign
  ( init
  ) where

import Prelude
import ElmLicenseChecker.Internal as Internal
import Node.Path (FilePath)
import Data.Nullable (Nullable, toNullable)
import Effect (Effect)
import Foreign.Object (Object)

type License
  = { name :: String
    , version :: String
    , summary :: Nullable String
    , license :: Nullable String
    , licenseText :: Nullable String
    , licenseFile :: Nullable String
    }

init :: FilePath -> Effect (Object License)
init = ((toForeignLicense <$> _) <$> _) <<< Internal.init

toForeignLicense :: Internal.License -> License
toForeignLicense l =
  { name: l.name
  , version: show l.version
  , summary: toNullable l.summary
  , license: toNullable l.license
  , licenseText: toNullable l.licenseText
  , licenseFile: toNullable l.licenseFile
  }
