# Elm License Checker

[![Join the chat at https://gitter.im/elm-license-checker/community](https://badges.gitter.im/elm-license-checker/community.svg)](https://gitter.im/elm-license-checker/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![NPM][npm-badge]][npm] [![Pursuit][pursuit-badge]][pursuit] ![test](https://github.com/kakkun61/elm-license-checker/workflows/test/badge.svg)

[npm]: https://www.npmjs.com/package/elm-license-checker
[npm-badge]: https://img.shields.io/npm/v/elm-license-checker
[pursuit]: https://pursuit.purescript.org/packages/purescript-elm-license-checker/
[pursuit-badge]: https://img.shields.io/badge/pursuit-v2.3.0-%231d222d

Treats the licenses of the dependent packages.

This is inspired by [NPM License Checker](https://github.com/davglass/license-checker).

## CLI Interface

You can show the package information with the selected fields.

```
> elm-license-checker --customPath format.json
├─ elm/json@1.1.3
│  ├─ name: elm/json
│  ├─ version: 1.1.3
│  ├─ summary: Encode and decode JSON values
│  ├─ license: BSD-3-Clause
│  └─ licenseFile: C:\Users\kazuki\AppData\Roaming\elm\0.19.1\packages\elm\json\1.1.3\LICENSE
├─ elm/time@1.0.0
│  ├─ name: elm/time
│  ├─ version: 1.0.0
│  ├─ summary: Work with POSIX times, time zones, years, months, days, hours, seconds, etc.
│  ├─ license: BSD-3-Clause
│  └─ licenseFile: C:\Users\kazuki\AppData\Roaming\elm\0.19.1\packages\elm\time\1.0.0\LICENSE
：
```

### Options

- `--customPath` add a custom format file in JSON

See the section “Compatibility with NPM License Checker”.

### Custom Format

Fields that a format file contains are outputted. Values of fields that licenses do not have are given as ones of fields in a format file.

There are an example file in _test-asset/format.json_.

## Library Interface

The following is how to use this as a module.

The JavaScript interface is compatible with NPM License Checker, but is actually a subset.

See the section “Compatibility with NPM License Checker”.

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

## Compatibility with NPM License Checker

Statuses are:

- ⭕ implemented
- ❌ decided not to be implemented
- 📄 decided to be implemented but not yet done
- ⌛ not decided whether implemented or not

### CLI Options

- ⌛ `--production` only show production dependencies
- ⌛ `--development` only show development dependencies
- 📄 `--start PATH` give where elm.json is
- ⌛ `--unknown` report guessed licenses as unknown licenses
- ⌛ `--onlyunknown` only list packages with unknown or guessed licenses
- ⌛ `--json` output in json format
- ⌛ `--csv` output in csv format
- ⌛ `--csvComponentPrefix` prefix column for component in csv format
- ⌛ `--out PATH` write the data to a specific file
- ⭕ `--customPath` add a custom format file in JSON
- ⌛ `--exclude LICENSES` exclude modules which licenses are in the comma-separated list from the output
- ⌛ `--relativeLicensePath` output the location of the license files as relative paths
- ⌛ `--summary` output a summary of the license usage
- ⌛ `--failOn LICENSES` fail (exit with code 1) on the first occurrence of the licenses of the semicolon-separated list
- ⌛ `--onlyAllow LICENSES` fail (exit with code 1) on the first occurrence of the licenses not in the semicolon-seperated list
- ⌛ `--packages PACKAGES` restrict output to the packages (package@version) in the semicolon-seperated list
- ⌛ `--excludePackages PACKAGES` restrict output to the packages (package@version) not in the semicolon-seperated list
- ⌛ `--excludePrivatePackages` restrict output to not include any package marked as private
- ⌛ `--direct` look for direct dependencies only

### Custom Format

There are compatible fields:

- ⭕ `name`
- ⭕ `version`
- ⭕ `description` the same as `summary`
- ⭕ `copyright` always empty
- ⭕ `licenses` the same as `license`
- ⭕ `licenseFile`
- ⭕ `licenseText`
- ⭕ `licenseModified` always empty

There are added fields:

- ⭕ `summary`
- ⭕ `license`
