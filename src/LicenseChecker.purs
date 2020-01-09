module LicenseChecker
  ( module Export
  , init
  ) where

import Prelude
import LicenseChecker.Internal (License)
import LicenseChecker.Internal (License, Version) as Export
import LicenseChecker.Internal as Internal
import Data.Set (Set)
import Data.Set as Set
import Node.Path (FilePath)
import Effect (Effect)

init :: FilePath -> Effect (Set License)
init = (Set.fromFoldable <$> _) <<< Internal.init
