PWSH = pwsh
BUMP = minor

.PHONY: build
build: setup
	npx spago build

.PHONY: setup
setup: node_modules .spago

node_modules: package.json package-lock.json
	npm install

.spago: node_modules packages.dhall spago.dhall
	npx spago build --deps-only

.PHONY: repl
repl: .spago
	npx spago repl

.PHONY: bundle
bundle: output/bundle.js

output/bundle.js: build
	$(PWSH) -Command "& { npx spago bundle-module --no-build --main ElmLicenseChecker.Bundle --to .\output\bundle.js }"

.PHONY: format
format:
	$(PWSH) -Command "& { Get-ChildItem -Filter '*.hs' -Recurse src | ForEach-Object { npx purty --write $$_.FullName } }"

.PHONY: bump-version
bump-version:
	npx spago bump-version --no-dry-run $(BUMP)

.PHONY: publish-npm
publish-spago:
	npm publish

.PHONY: publish-pulp
publish-pulp:
	npx pulp publish

.PHONY: clean
clean:
	- $(PWSH) -Command "& { Remove-Item -Recurse -Force output -ErrorAction Ignore }"

.PHONY: clean-full
clean-full: clean
	- $(PWSH) -Command "& { Remove-Item -Recurse -Force .psci_modules, .pulp-cache, .spago, bower_components, node_modules -ErrorAction Ignore }"
