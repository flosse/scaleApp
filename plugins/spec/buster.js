var config = module.exports;

config["node-specs"] = {
  rootPath: '../..',
  environment: "node",
  extensions: [require("buster-coffee")],
  specs: [
    "plugins/spec/scaleApp.i18n.spec.coffee",
    "plugins/spec/scaleApp.util.spec.coffee",
    "plugins/spec/scaleApp.mvc.spec.coffee",
    "plugins/spec/scaleApp.permission.spec.coffee",
    "plugins/spec/scaleApp.state.spec.coffee",
    "plugins/spec/scaleApp.submodule.spec.coffee",
    "plugins/spec/scaleApp.modulestate.spec.coffee",
    "plugins/spec/scaleApp.ls.spec.coffee"
    ]
};

config["browser-core"] = {
  rootPath: '../..',
  environment: "browser",
  specHelpers: ["spec/browserSetup.coffee"],
  sources: ["dist/scaleApp.js"],
  extensions: [require("buster-coffee")]
};

config["browser-i18n-plugin"] = {
  extends: "browser-core",
  specs: ["plugins/spec/scaleApp.i18n.spec.coffee"],
  sources: ["dist/plugins/scaleApp.i18n.js"]
};

config["browser-util-plugin"] = {
  extends: "browser-core",
  specs: ["plugins/spec/scaleApp.util.spec.coffee"],
  sources: ["dist/plugins/scaleApp.util.js"]
};

config["browser-mvc-plugin"] = {
  extends: "browser-core",
  specs: ["plugins/spec/scaleApp.mvc.spec.coffee"],
  sources: ["dist/plugins/scaleApp.mvc.js"]
};

config["browser-permission-plugin"] = {
  extends: "browser-core",
  specs: ["plugins/spec/scaleApp.permission.spec.coffee"],
  sources: ["dist/scaleApp.js", "dist/plugins/scaleApp.permission.js"]
};

config["browser-dom-plugin"] = {
  extends: "browser-core",
  specs: ["plugins/spec/scaleApp.dom.spec.coffee"],
  sources: ["dist/plugins/scaleApp.dom.js"]
};

config["browser-modulestate-plugin"] = {
  extends: "browser-core",
  specs: ["plugins/spec/scaleApp.modulestate.spec.coffee"],
  sources: ["dist/plugins/scaleApp.modulestate.js"]
};
