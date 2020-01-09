const ElmLicenseChecker_Internal = require('../output/ElmLicenseChecker.Internal/index.js');
const Data_Maybe = require('../output/Data.Maybe/index.js');
const Data_Show = require('../output/Data.Show/index.js');
const debug = require('debug');

// Set up debug logging
// https://www.npmjs.com/package/debug#stderr-vs-stdout
const debugLog = debug('elm-license-checker:log');
debugLog.log = console.log.bind(console);

function init(option, callback) {
  debugLog('scanning %s', option.start);

  try {
    const licenses = ElmLicenseChecker_Internal.init(option.start)();
    const result = {}
    for (let [name, license] of Object.entries(licenses)) {
      result[name] = convert(name, license);
    }
    callback(null, result);
  }
  catch (e) {
    callback(e, null);
  }
}

function convert(name, license) {
  return {
    name: name,
    version: showVersion(license.version),
    description: fromJust(null, license.summary),
    repository: null,
    publisher: null,
    email: null,
    url: null,
    licenses: fromJust(null, license.license),
    licenseFile: fromJust(null, license.licenseFile),
    licenseText: fromJust(null, license.licenseText),
    licenseModified: null
  };
}

const showVersion = Data_Show.show(ElmLicenseChecker_Internal.showVersion);

function fromJust(nothing, value) {
  return value instanceof Data_Maybe.Just ? value.value0 : nothing;
}

module.exports = {
  init: init
};
