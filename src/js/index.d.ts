// Type definitions for elm-license-checker 2.3.0
// Project: https://github.com/kakkun61/elm-license-checker
// Definitions by: 岡本和樹 (Kazuki Okamoto) <https://github.com/kakkun61>,
//                 Rogier Schouten <https://github.com/rogierschouten>,
//                 Daniel Perez Alvarez <https://github.com/unindented>,
//                 Alec Custer <https://github.com/alechemy>
// Definitions: https://github.com/kakkun61/elm-license-checker

import * as lc from "license-checker";

/**
 * Run the license check
 * @param opts specifies the path to the module to check dependencies of
 */
export function init(
  opts: lc.InitOpts,
  callback: (err: Error, ret: lc.ModuleInfos) => void
): void;
