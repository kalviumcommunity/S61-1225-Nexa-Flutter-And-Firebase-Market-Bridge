module.exports = {
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
  ],
  parserOptions: {
    ecmaVersion: 2020,
  },
  rules: {
    indent: ["error", 2],
    "comma-dangle": ["error", "always-multiline"],
    "max-len": ["error", { code: 120 }],
    quotes: ["error", "double"],
    semi: ["error", "always"],
  },
};
