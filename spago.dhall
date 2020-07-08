{ name = "elm-license-checker"
, dependencies =
    [ "prelude"
    , "psci-support"
    , "effect"
    , "maybe"
    , "node-fs"
    , "node-path"
    , "node-process"
    , "optparse"
    , "parsing"
    , "read"
    , "simple-json"
    , "spec"
    , "tuples"
    ]
, packages = ./packages.dhall
, sources = [ "src/purs/**/*.purs", "test/**/*.purs" ]
, license = "BSD-3-Clause"
, repository = "git://github.com/kakkun61/elm-license-checker.git"
}
