# Elm License Checker

[![NPM][npm-badge]][npm] [![Pursuit][pursuit-badge]][pursuit]

[npm]: https://www.npmjs.com/package/elm-license-checker
[npm-badge]: https://img.shields.io/npm/v/elm-license-checker
[pursuit]: https://pursuit.purescript.org/packages/purescript-elm-license-checker/
[pursuit-badge]: https://img.shields.io/badge/pursuit-v2.2.0-%231d222d

Treats the licenses of the dependencies of a package.

This is inspired by [NPM License Checker](https://github.com/davglass/license-checker).

## Library Interface

The following is how to use this as a module.

The JavaScript interface is compatible with NPM License Checker, but is actually a subset.

```javascript
const elc = require('elm-license-checker');

elc.init(
  { start: '/path/to/elm-application' },
  function (err, packages) {
    if (err) {
      // handle the error
    } else {
      // use the packages
    }
  }
);
```

The PureScript interface is also available.

```purescript
import Prelude
import Effect (Effect)
import ElmLicenseChecker (init)

main :: Effect Unit
main = do
  packages <- init "/path/to/elm-application"
  -- use the packages
```

## CLI interface

The CLI interface is not yet provided.
