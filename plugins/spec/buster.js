var config = module.exports;

config["node-specs"] = {
  rootPath: '../',
  environment: "node",
  extensions: [require("buster-coffee")],
  specs: [
    "spec/scaleApp.i18n.spec.coffee",
    "spec/scaleApp.util.spec.coffee",
    "spec/scaleApp.mvc.spec.coffee",
    "spec/scaleApp.permission.spec.coffee",
    "spec/scaleApp.state.spec.coffee",
    "spec/scaleApp.submodule.spec.coffee",
    "spec/scaleApp.ls.spec.coffee"
    ]
};

config["browser-core"] = {
  rootPath: '../',
  environment: "browser",
  specHelpers: ["spec/browserSetup.coffee"],
  sources: ["dist/scaleApp.js"],
  extensions: [require("buster-coffee")]
};

config["browser-i18n-plugin"] = {
  extends: "browser-core",
  specs: ["spec/scaleApp.i18n.spec.coffee"],
  sources: ["dist/plugins/scaleApp.i18n.js"]
};

config["browser-util-plugin"] = {
  extends: "browser-core",
  specs: ["spec/scaleApp.util.spec.coffee"],
  sources: ["dist/plugins/scaleApp.util.js"]
};

config["browser-mvc-plugin"] = {
  extends: "browser-core",
  specs: ["spec/scaleApp.mvc.spec.coffee"],
  sources: ["dist/plugins/scaleApp.mvc.js"]
};

config["browser-permission-plugin"] = {
  environment: "browser",
  rootPath: '../',
  specs: ["spec/scaleApp.permission.spec.coffee"],
  specHelpers: ["spec/browserSetup.coffee"],
  sources: ["dist/scaleApp.js", "dist/plugins/scaleApp.permission.js"],
  extensions: [require("buster-coffee")],
};

config["browser-dom-plugin"] = {
  extends: "browser-core",
  specs: ["spec/scaleApp.dom.spec.coffee"],
  sources: ["dist/plugins/scaleApp.dom.js"]
};
