var config = module.exports;

config["browser-modules"] = {
  environment: "browser",
  rootPath: '../../',
  specs: ["modules/spec/*.spec.coffee"],
  specHelpers: ["spec/browserSetup.coffee"],
  sources: ["modules/*.coffee"],
  libs: ["dist/scaleApp.min.js", "dist/plugins/scaleApp.dom.js"],
  extensions: [require("buster-coffee")],
};
