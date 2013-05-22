var config = module.exports;

config["node-specs"] = {
  rootPath: '../',
  environment: "node",
  extensions: [require("buster-coffee")],
  specs: [
    "spec/*.spec.coffee",
    "spec/plugins/scaleApp.i18n.spec.coffee",
    "spec/plugins/scaleApp.util.spec.coffee",
    "spec/plugins/scaleApp.mvc.spec.coffee",
    "spec/plugins/scaleApp.permission.spec.coffee",
    "spec/plugins/scaleApp.state.spec.coffee",
    "spec/plugins/scaleApp.submodule.spec.coffee",
    "spec/plugins/scaleApp.ls.spec.coffee"
    ]
};

config["browser-core"] = {
  rootPath: '../',
  environment: "browser",
  specs: ["spec/*.spec.coffee"],
  specHelpers: ["spec/browserSetup.coffee"],
  sources: ["dist/scaleApp.js"],
  extensions: [require("buster-coffee")]
};

config["browser-i18n-plugin"] = {
  extends: "browser-core",
  specs: ["spec/plugins/scaleApp.i18n.spec.coffee"],
  sources: ["dist/plugins/scaleApp.i18n.js"]
};

config["browser-util-plugin"] = {
  extends: "browser-core",
  specs: ["spec/plugins/scaleApp.util.spec.coffee"],
  sources: ["dist/plugins/scaleApp.util.js"]
};

config["browser-mvc-plugin"] = {
  extends: "browser-core",
  specs: ["spec/plugins/scaleApp.mvc.spec.coffee"],
  sources: ["dist/plugins/scaleApp.mvc.js"]
};

config["browser-permission-plugin"] = {
  environment: "browser",
  rootPath: '../',
  specs: ["spec/plugins/scaleApp.permission.spec.coffee"],
  specHelpers: ["spec/browserSetup.coffee"],
  sources: ["dist/scaleApp.js", "dist/plugins/scaleApp.permission.js"],
  extensions: [require("buster-coffee")],
};

config["browser-dom-plugin"] = {
  extends: "browser-core",
  specs: ["spec/plugins/scaleApp.dom.spec.coffee"],
  sources: ["dist/plugins/scaleApp.dom.js"]
};

config["browser-modules"] = {
  environment: "browser",
  rootPath: '../',
  specs: ["spec/modules/*.spec.coffee"],
  specHelpers: ["spec/browserSetup.coffee"],
  sources: ["src/modules/*.coffee"],
  libs: ["dist/scaleApp.min.js", "dist/plugins/scaleApp.dom.js"],
  extensions: [require("buster-coffee")],
};
