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

.PHONY: test
test: test-purs test-ts

.PHONY: test-purs
test-purs: .spago
	npx spago test

.PHONY: test-ts
test-ts: node_modules jest.config.cjs output/bundle.js
	node --experimental-vm-modules node_modules/jest/bin/jest.js

.PHONY: bundle
bundle: output/bundle.js

output/bundle.js: build
	npx spago bundle-module --platform=node --no-build --main ElmLicenseChecker.Bundle --to output/bundle.js

.PHONY: pack
pack: elm-license-checker-2.5.0.tgz

elm-license-checker-2.5.0.tgz: bin/elm-license-checker src/js/index.js src/js/index.d.ts output/bundle.js
	npm pack

.PHONY: format
format:
	$(PWSH) -Command "& { Get-ChildItem -Filter '*.purs' -Recurse src, test | ForEach-Object { npx purty --write $$_.FullName } }"

.PHONY: bump-version
bump-version:
	npx spago bump-version --no-dry-run $(BUMP)

.PHONY: publish-npm
publish-npm: output/bundle.js
	npm publish

.PHONY: publish-pulp
publish-pulp: bower_components
	npx pulp publish

bower_components: bower.json
	npx bower install

.PHONY: clean
clean:
	- $(PWSH) -Command "& { Remove-Item -Recurse -Force output -ErrorAction Ignore }"

.PHONY: clean-full
clean-full: clean
	- $(PWSH) -Command "& { Remove-Item -Recurse -Force .psci_modules, .pulp-cache, .spago, bower_components, node_modules -ErrorAction Ignore }"
