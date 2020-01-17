"use strict";

const treeify = require('treeify');

exports.treeify = (obj) => treeify.asTree(obj, true, false);
