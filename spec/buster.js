var config = module.exports;

config["node-specs"] = {
  rootPath: '../',
  environment: "node",
  extensions: [require("buster-coffee")],
  specs: [ "spec/*.spec.coffee" ]
};

config["browser-core"] = {
  rootPath: '../',
  environment: "browser",
  specs: ["spec/*.spec.coffee"],
  specHelpers: ["spec/browserSetup.coffee"],
  sources: ["dist/scaleApp.js"],
  extensions: [require("buster-coffee")]
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
