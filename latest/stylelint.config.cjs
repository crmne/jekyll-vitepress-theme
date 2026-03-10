module.exports = {
  extends: ["stylelint-config-standard"],
  ignoreFiles: [
    "_site/**",
    "_site_next_test/**",
    "assets/css/vitepress-core.css",
    "assets/css/vitepress-components.css"
  ],
  rules: {
    "selector-class-pattern": null,
    "alpha-value-notation": null,
    "color-function-notation": null,
    "media-feature-range-notation": null,
    "no-descending-specificity": null,
    "property-no-vendor-prefix": null,
    "value-no-vendor-prefix": null
  }
};
