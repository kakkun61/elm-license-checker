module ElmLicenseChecker
  ( module Export
  , init
  ) where

import Prelude
import ElmLicenseChecker.Internal (License)
import ElmLicenseChecker.Internal (License, Version) as Export
import ElmLicenseChecker.Internal as Internal
import Data.Set (Set)
import Data.Set as Set
import Effect (Effect)
import Node.Path (FilePath)

init :: FilePath -> Effect (Set License)
init = (Set.fromFoldable <$> _) <<< Internal.init
