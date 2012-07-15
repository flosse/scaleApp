var config = module.exports;

config["node-core"] = {
  environment: "node",
  specs: ["spec/*.spec.coffee"],
  extensions: [require("buster-coffee")]
};

config["node-i18n-plugin"] = {
  environment: "node",
  specs: ["spec/plugins/scaleApp.i18n.spec.coffee"],
  extensions: [require("buster-coffee")]
};

config["node-util-plugin"] = {
  environment: "node",
  specs: ["spec/plugins/scaleApp.util.spec.coffee"],
  extensions: [require("buster-coffee")]
};

config["node-mvc-plugin"] = {
  environment: "node",
  specs: ["spec/plugins/scaleApp.mvc.spec.coffee"],
  extensions: [require("buster-coffee")]
};

config["node-permission-plugin"] = {
  environment: "node",
  specs: ["spec/plugins/scaleApp.permission.spec.coffee"],
  extensions: [require("buster-coffee")]
};

config["browser-core"] = {
  environment: "browser",
  specs: ["spec/*.spec.coffee"],
  specHelpers: ["spec/browserSetup.coffee"],
  sources: ["bundles/scaleApp.min.js"],
  extensions: [require("buster-coffee")],
};

config["browser-i18n-plugin"] = {
  extends: "browser-core",
  specs: ["spec/plugins/scaleApp.i18n.spec.coffee"],
  sources: ["lib/plugins/scaleApp.i18n.js"]
};

config["browser-util-plugin"] = {
  extends: "browser-core",
  specs: ["spec/plugins/scaleApp.util.spec.coffee"],
  sources: ["lib/plugins/scaleApp.util.js"]
};

config["browser-mvc-plugin"] = {
  extends: "browser-core",
  specs: ["spec/plugins/scaleApp.mvc.spec.coffee"],
  sources: ["lib/plugins/scaleApp.mvc.js"]
};

config["browser-permission-plugin"] = {
  environment: "browser",
  specs: ["spec/plugins/scaleApp.permission.spec.coffee"],
  specHelpers: ["spec/browserSetup.coffee"],
  sources: ["bundles/scaleApp.min.js", "lib/plugins/scaleApp.permission.js"],
  extensions: [require("buster-coffee")],
};

config["browser-dom-plugin"] = {
  extends: "browser-core",
  specs: ["spec/plugins/scaleApp.dom.spec.coffee"],
  sources: ["lib/plugins/scaleApp.dom.js"]
};
