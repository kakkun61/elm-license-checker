import * as lc from "license-checker";

/**
 * Options struct for the init() function
 */
export interface InitOpts {
  /**
   * Path to start checking dependencies from
   */
  start: string
}

/**
 * Run the license check
 * @param opts specifies the path to the module to check dependencies of
 */
export function init(
  opts: InitOpts,
  callback: (err: Error, ret: lc.ModuleInfos) => void
): void;
