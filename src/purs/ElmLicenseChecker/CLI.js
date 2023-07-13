"use strict";

import { asTree } from 'treeify';

export let treeify = (obj) => asTree(obj, true, false);
