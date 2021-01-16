# 2.4.0 - 2021.01.16

- adding `--json` and `--out` command line options
- upgrading dependencies

# 2.3.0 - 2020.07.09

- releasing command line interface
  - just `--customPath` option available

# 2.2.1 - 2020.01.16

- fixing the mistake of releasing version 2.2.0

# 2.2.0 - 2020.01.16

**Don't use version 2.2.0.** There is a mistake in the procedure of releasing version 2.2.0.

- adding “@” and versions to keys (foo → foo@1.0.0)
  - for more compatibility with NPM License Checker
- bundling (NPM package unpacked size: 18MB → 180kB)
- getting more tolerant to PureScript's internal representations

# 2.1.0 - 2020.01.10

- accepting the redundant fields of the `option` record of the `init` function
- using `undefined` as the fields without data of the result instead of `null`
- putting the PureScript dependencies' LICENSEs into the CREDIT

# 2.0.0 - 2020.01.09

## Breaking Changes

- providing the compatible and subset interface with NPM License Checker
- renaming the PureScript module

## Other Changes

- adding
  - README.md
  - LICENSE
  - CREDIT
  - ChangeLog.md
  - src/index.d.ts

# 1.0.0 - 2020.01.07

- initial release
