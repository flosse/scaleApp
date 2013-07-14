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
