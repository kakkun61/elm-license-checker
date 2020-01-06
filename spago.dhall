{ name = "elm-license-checker"
, dependencies =
    [ "prelude"
    , "psci-support"
    , "effect"
    , "node-fs"
    , "node-path"
    , "node-process"
    , "parsing"
    , "read"
    , "simple-json"
    ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
, license = "BSD-3-Clause"
, repository = "git://github.com/kakkun61/elm-license-checker.git"
}
