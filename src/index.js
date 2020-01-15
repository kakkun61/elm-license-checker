const lib = require('../output/lib.js');
const debug = require('debug');

// Set up debug logging
// https://www.npmjs.com/package/debug#stderr-vs-stdout
const debugLog = debug('elm-license-checker:log');
debugLog.log = console.log.bind(console);

function init(option, callback) {
  debugLog('scanning %s', option.start);

  try {
    const licenses = lib.init(option.start)();
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
  const result = { name: name, version: license.version };
  for (let [key, value] of Object.entries(license)) {
    if (!value) continue;
    result[key] = value;
  }
  return result;
}

module.exports = {
  init: init
};
