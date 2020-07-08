"use strict";

const lib = require('../../output/bundle');
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
    callback(null, lib.init(option.start)(option)());
  }
  catch (e) {
    callback(e, null);
  }
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
