const LicenseChecker_Internal = require('../output/LicenseChecker.Internal/index.js');
const Data_Maybe = require('../output/Data.Maybe/index.js');
const debug = require('debug');

// Set up debug logging
// https://www.npmjs.com/package/debug#stderr-vs-stdout
const debugLog = debug('elm-license-checker:log');
debugLog.log = console.log.bind(console);

function init(option, callback) {
  debugLog('scanning %s', option.start);

  try {
    const licenses = LicenseChecker_Internal.init(option.start)();
    const result = {}
    for (let [name, license] of Object.entries(licenses)) {
      result[name] = {
        licenses: fromJust("", license.license),
        licenseFile: fromJust("", license.licenseFile),
        licenseText: fromJust("", license.licenseText)
      }
    }
    callback(null, result);
  }
  catch (e) {
    callback(e, null);
  }
}

function fromJust(value, nothing) {
  return value instanceof Data_Maybe.Just ? value.value0 : nothing;
}

module.exports = {
  init: init
};
