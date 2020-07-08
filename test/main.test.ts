import { init } from '../src/js/index';

describe('init', () => {
  test('just run', done => {
    init({ start: "./test-asset" }, (error, _licenses) => {
      if (error) {
        done(error);
      }
      done();
    });
  });
});

describe('init with customPath', () => {
  test('just run', done => {
    init({ start: "./test-asset", customPath: "./test-asset/format.json" }, (error, _licenses) => {
      if (error) {
        done(error);
      }
      done();
    });
  });
});
