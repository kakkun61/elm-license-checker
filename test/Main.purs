module Test.Main where

import ElmLicenseChecker (init)

import Prelude (Unit, bind, ($))

import Data.Set (Set)
import Data.Set as Set
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Test.Spec (it)
import Test.Spec.Assertions (shouldEqual)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (runSpec)

expectedLicenseNames :: Set String
expectedLicenseNames =
  Set.fromFoldable
    [ "elm/browser"
    , "elm/core"
    , "elm/html"
    , "elm/json"
    , "elm/time"
    , "elm/url"
    , "elm/virtual-dom"
    ]

main :: Effect Unit
main = launchAff_ $ runSpec [consoleReporter] do
  it "name" do
    licenses <- liftEffect $ init "./test-asset"
    let actual = Set.map (\l -> l.name) $ licenses
    actual `shouldEqual` expectedLicenseNames
