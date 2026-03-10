import globals from "globals";

export default [
  {
    files: ["assets/js/**/*.js"],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "script",
      globals: {
        ...globals.browser,
        ...globals.es2021
      }
    },
    rules: {
      "no-undef": "error",
      "no-redeclare": "error",
      "no-unreachable": "error",
      "no-unused-vars": ["error", { "argsIgnorePattern": "^_", "caughtErrors": "none" }]
    }
  }
];
