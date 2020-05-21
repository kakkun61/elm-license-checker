module ElmLicenseChecker.Bundle
  ( init
  , cli
  ) where

-- The combination of re-exporting modules and bundling is something bad.
import Prelude
import ElmLicenseChecker.Foreign (License, init) as Foreign
import ElmLicenseChecker.CLI (cli) as CLI
import Effect (Effect)
import Foreign.Object (Object)
import Node.Path (FilePath)

init :: FilePath -> Effect (Object Foreign.License)
init = Foreign.init

cli :: Effect Unit
cli = CLI.cli
