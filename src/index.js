const lib = require('../output/lib.js');
const debug = require('debug');

// Set up debug logging
// https://www.npmjs.com/package/debug#stderr-vs-stdout
const logDebug = debug('elm-license-checker:log');
logDebug.log = console.log.bind(console);
const logWarning = debug('elm-license-checker:warning');

function init(option, callback) {
  logDebug('scanning %s', option.start);

  const unimplemented = getUnimplemented(option);
  if (0 < unimplemented.length) logWarning('unimplemented options given: %o', unimplemented);

  try {
    const licenses = lib.init(option.start)();
    const result = {}
    for (let [name, license] of Object.entries(licenses)) {
      result[name + '@' + license.version] = convert(name, license);
    }
    callback(null, result);
  }
  catch (e) {
    callback(e, null);
  }
}

// @pure
function convert(name, license) {
  const result = { name: name, version: license.version };
  for (let [key, value] of Object.entries(license)) {
    if (!value) continue;
    result[key] = value;
  }
  return result;
}

// @pure
function getUnimplemented(option) {
  const implemented = ['start'];
  const given = Object.keys(option);
  return given.filter((e) => !implemented.includes(e));
}

module.exports = {
  init: init
};
