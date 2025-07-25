module.exports = {
  "testMatch": [
    "**/?(*.)+(spec|test).+(ts|tsx|js)"
  ],
  "transform": {
    "^.+\\.(ts|tsx)$": ["ts-jest", { useESM: true }]
  },
  extensionsToTreatAsEsm: ['.ts'],
}
