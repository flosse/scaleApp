(function() {
  var Controller, DOMPlugin, Mediator, Model, SBPlugin, Sandbox, UtilPlugin, VERSION, View, addModule, baseLanguage, channelName, core, coreKeywords, createInstance, error, get, getBrowserLanguage, getLanguage, instances, lang, mediator, modules, onInstantiate, onInstantiateFunctions, plugin, plugins, register, registerPlugin, sandboxKeywords, scaleApp, setLanguage, start, startAll, stop, stopAll, subscribe, uniqueId, unregister, unregisterAll, unsubscribe, _ref,
    __hasProp = Object.prototype.hasOwnProperty,
    __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __slice = Array.prototype.slice,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Mediator = (function() {

    function Mediator(obj) {
      this.channels = {};
      if (obj) this.installTo(obj);
    }

    Mediator.prototype.subscribe = function(channel, fn, context) {
      var id, k, subscription, that, v, _i, _len, _results, _results2;
      if (context == null) context = this;
      if (this.channels[channel] == null) this.channels[channel] = [];
      that = this;
      if (channel instanceof Array) {
        _results = [];
        for (_i = 0, _len = channel.length; _i < _len; _i++) {
          id = channel[_i];
          _results.push(this.subscribe(id, fn, context));
        }
        return _results;
      } else if (typeof channel === "object") {
        _results2 = [];
        for (k in channel) {
          v = channel[k];
          _results2.push(this.subscribe(k, v, fn));
        }
        return _results2;
      } else {
        subscription = {
          context: context,
          callback: fn
        };
        return {
          attach: function() {
            that.channels[channel].push(subscription);
            return this;
          },
          detach: function() {
            Mediator._rm(that, channel, subscription.callback);
            return this;
          }
        }.attach();
      }
    };

    Mediator.prototype.unsubscribe = function(ch, cb) {
      var id;
      switch (typeof ch) {
        case "string":
          if (typeof cb === "function") Mediator._rm(this, ch, cb);
          if (typeof cb === "undefined") Mediator._rm(this, ch);
          break;
        case "function":
          for (id in this.channels) {
            Mediator._rm(this, id, ch);
          }
          break;
        case "undefined":
          for (id in this.channels) {
            Mediator._rm(this, id);
          }
          break;
        case "object":
          for (id in this.channels) {
            Mediator._rm(this, id, null, ch);
          }
      }
      return this;
    };

    Mediator.prototype.publish = function(channel, data, publishReference) {
      var copy, k, subscription, v, _i, _len, _ref;
      if (this.channels[channel] != null) {
        _ref = this.channels[channel];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          subscription = _ref[_i];
          if (publishReference !== true && typeof data === "object") {
            if (data instanceof Array) {
              copy = (function() {
                var _j, _len2, _results;
                _results = [];
                for (_j = 0, _len2 = data.length; _j < _len2; _j++) {
                  v = data[_j];
                  _results.push(v);
                }
                return _results;
              })();
            } else {
              copy = {};
              for (k in data) {
                v = data[k];
                copy[k] = v;
              }
            }
            subscription.callback.apply(subscription.context, [copy, channel]);
          } else {
            subscription.callback.apply(subscription.context, [data, channel]);
          }
        }
      }
      return this;
    };

    Mediator.prototype.installTo = function(obj) {
      if (typeof obj === "object") {
        obj.subscribe = this.subscribe;
        obj.unsubscribe = this.unsubscribe;
        obj.publish = this.publish;
        obj.channels = this.channels;
      }
      return this;
    };

    Mediator._rm = function(o, ch, cb, ctxt) {
      var s;
      return o.channels[ch] = (function() {
        var _i, _len, _ref, _results;
        _ref = o.channels[ch];
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          s = _ref[_i];
          if ((cb != null ? s.callback !== cb : ctxt != null ? s.context !== ctxt : s.context !== o)) {
            _results.push(s);
          }
        }
        return _results;
      })();
    };

    return Mediator;

  })();

  if (typeof exports !== "undefined" && exports !== null) {
    exports.Mediator = Mediator;
  }

  Sandbox = (function() {

    function Sandbox(core, instanceId, options) {
      this.core = core;
      this.instanceId = instanceId;
      this.options = options != null ? options : {};
      if (this.core == null) throw new Error("core was not defined");
      if (instanceId == null) throw new Error("no id was specified");
      if (typeof instanceId !== "string") throw new Error("id is not a string");
    }

    return Sandbox;

  })();

  if (typeof exports !== "undefined" && exports !== null) {
    exports.Sandbox = Sandbox;
  }

  if (typeof require === "function") {
    Mediator = require("./Mediator").Mediator;
    Sandbox = require("./Sandbox").Sandbox;
  }

  VERSION = "0.3.3";

  modules = {};

  instances = {};

  mediator = new Mediator;

  plugins = {};

  error = function(e) {
    return typeof console !== "undefined" && console !== null ? typeof console.error === "function" ? console.error(e.message) : void 0 : void 0;
  };

  uniqueId = function(length) {
    var id;
    if (length == null) length = 8;
    id = "";
    while (id.length < length) {
      id += Math.random().toString(36).substr(2);
    }
    return id.substr(0, length);
  };

  onInstantiateFunctions = {
    _always: []
  };

  onInstantiate = function(fn, moduleId) {
    var entry;
    if (typeof fn !== "function") {
      throw new Error("expect a function as parameter");
    }
    entry = {
      context: this,
      callback: fn
    };
    if (typeof moduleId === "string") {
      if (onInstantiateFunctions[moduleId] == null) {
        onInstantiateFunctions[moduleId] = [];
      }
      return onInstantiateFunctions[moduleId].push(entry);
    } else if (!(moduleId != null)) {
      return onInstantiateFunctions._always.push(entry);
    }
  };

  createInstance = function(moduleId, instanceId, opt) {
    var entry, i, instance, instanceOpts, k, key, module, n, p, plugin, sb, v, val, _i, _j, _len, _len2, _ref, _ref2, _ref3;
    if (instanceId == null) instanceId = moduleId;
    module = modules[moduleId];
    if (instances[instanceId] != null) return instances[instanceId];
    instanceOpts = {};
    _ref = module.options;
    for (key in _ref) {
      val = _ref[key];
      instanceOpts[key] = val;
    }
    if (opt) {
      for (key in opt) {
        val = opt[key];
        instanceOpts[key] = val;
      }
    }
    sb = new Sandbox(core, instanceId, instanceOpts);
    mediator.installTo(sb);
    for (i in plugins) {
      p = plugins[i];
      if (!(p.sandbox != null)) continue;
      plugin = new p.sandbox(sb);
      for (k in plugin) {
        if (!__hasProp.call(plugin, k)) continue;
        v = plugin[k];
        sb[k] = v;
      }
    }
    instance = new module.creator(sb);
    instance.options = instanceOpts;
    instance.id = instanceId;
    instances[instanceId] = instance;
    _ref2 = [instanceId, '_always'];
    for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
      n = _ref2[_i];
      if (onInstantiateFunctions[n] != null) {
        _ref3 = onInstantiateFunctions[n];
        for (_j = 0, _len2 = _ref3.length; _j < _len2; _j++) {
          entry = _ref3[_j];
          entry.callback.apply(entry.context);
        }
      }
    }
    return instance;
  };

  addModule = function(moduleId, creator, opt) {
    var modObj;
    if (typeof moduleId !== "string") {
      throw new Error("moudule ID has to be a string");
    }
    if (typeof creator !== "function") {
      throw new Error("creator has to be a constructor function");
    }
    if (typeof opt !== "object") {
      throw new Error("option parameter has to be an object");
    }
    modObj = new creator();
    if (typeof modObj !== "object") {
      throw new Error("creator has to return an object");
    }
    if (typeof modObj.init !== "function") {
      throw new Error("module has to have an init function");
    }
    if (typeof modObj.destroy !== "function") {
      throw new Error("module has to have a destroy function");
    }
    if (modules[moduleId] != null) {
      throw new Error("module " + moduleId + " was already registered");
    }
    modules[moduleId] = {
      creator: creator,
      options: opt,
      id: moduleId
    };
    return true;
  };

  register = function(moduleId, creator, opt) {
    if (opt == null) opt = {};
    try {
      return addModule(moduleId, creator, opt);
    } catch (e) {
      error(new Error("could not register module: " + e.message));
      return false;
    }
  };

  unregister = function(id) {
    if (modules[id] != null) {
      delete modules[id];
      return true;
    } else {
      return false;
    }
  };

  unregisterAll = function() {
    var id, _results;
    _results = [];
    for (id in modules) {
      _results.push(unregister(id));
    }
    return _results;
  };

  start = function(moduleId, opt) {
    var instance;
    if (opt == null) opt = {};
    try {
      if (typeof moduleId !== "string") {
        throw new Error("module ID has to be a string");
      }
      if (typeof opt !== "object") {
        throw new Error("second parameter has to be an object");
      }
      if (modules[moduleId] == null) throw new Error("module does not exist");
      instance = createInstance(moduleId, opt.instanceId, opt.options);
      if (instance.running === true) throw new Error("module was already started");
      instance.init(instance.options);
      instance.running = true;
      if (typeof opt.callback === "function") opt.callback();
      return true;
    } catch (e) {
      error(e);
      return false;
    }
  };

  stop = function(id) {
    var instance;
    if (instance = instances[id]) {
      mediator.unsubscribe(instance);
      instance.destroy();
      return delete instances[id];
    } else {
      return false;
    }
  };

  startAll = function(cb, opt) {
    var id, k, mods, o, origCB, v, _ref;
    if (cb instanceof Array) {
      mods = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = cb.length; _i < _len; _i++) {
          id = cb[_i];
          if (modules[id]) _results.push(id);
        }
        return _results;
      })();
      cb = opt;
    } else {
      switch (typeof cb) {
        case "undefined":
        case "function":
          mods = (function() {
            var _results;
            _results = [];
            for (id in modules) {
              _results.push(id);
            }
            return _results;
          })();
      }
    }
    if ((mods != null ? mods.length : void 0) >= 1) {
      o = {};
      _ref = modules[mods[0]].options;
      for (k in _ref) {
        if (!__hasProp.call(_ref, k)) continue;
        v = _ref[k];
        if (v) o[k] = v;
      }
      origCB = o.callback;
      if (mods.slice(1).length === 0) {
        o.callback = function() {
          if (typeof origCB === "function") origCB();
          return typeof cb === "function" ? cb() : void 0;
        };
      } else {
        o.callback = function() {
          if (typeof origCB === "function") origCB();
          return startAll(mods.slice(1), cb);
        };
      }
      return start(mods[0], o);
    } else {
      return false;
    }
  };

  stopAll = function() {
    var id, _results;
    _results = [];
    for (id in instances) {
      _results.push(stop(id));
    }
    return _results;
  };

  coreKeywords = ["VERSION", "register", "unregister", "registerPlugin", "start", "stop", "startAll", "stopAll", "publish", "subscribe", "unsubscribe", "Mediator", "Sandbox", "unregisterAll", "uniqueId"];

  sandboxKeywords = ["core", "instanceId", "options", "publish", "subscribe", "unsubscribe"];

  registerPlugin = function(plugin) {
    var k, v, _ref, _ref2;
    try {
      if (typeof plugin !== "object") {
        throw new Error("plugin has to be an object");
      }
      if (typeof plugin.id !== "string") throw new Error("plugin has no id");
      if (typeof plugin.sandbox === "function") {
        for (k in new plugin.sandbox(new Sandbox(core, ""))) {
          if (__indexOf.call(sandboxKeywords, k) >= 0) {
            throw new Error("plugin uses reserved keyword");
          }
        }
        _ref = plugin.sandbox.prototype;
        for (k in _ref) {
          v = _ref[k];
          Sandbox.prototype[k] = v;
        }
      }
      if (typeof plugin.core === "object") {
        for (k in plugin.core) {
          if (__indexOf.call(coreKeywords, k) >= 0) {
            throw new Error("plugin uses reserved keyword");
          }
        }
        _ref2 = plugin.core;
        for (k in _ref2) {
          v = _ref2[k];
          core[k] = v;
        }
      }
      if (typeof plugin.onInstantiate === "function") {
        onInstantiate(plugin.onInstantiate);
      }
      plugins[plugin.id] = plugin;
      return true;
    } catch (e) {
      error(e);
      return false;
    }
  };

  core = {
    VERSION: VERSION,
    register: register,
    unregister: unregister,
    unregisterAll: unregisterAll,
    registerPlugin: registerPlugin,
    start: start,
    stop: stop,
    startAll: startAll,
    stopAll: stopAll,
    uniqueId: uniqueId,
    Mediator: Mediator,
    Sandbox: Sandbox
  };

  mediator.installTo(core);

  if (typeof exports !== "undefined" && exports !== null) exports.scaleApp = core;

  if (typeof window !== "undefined" && window !== null) window.scaleApp = core;

  DOMPlugin = (function() {

    function DOMPlugin(sb) {
      this.sb = sb;
      this.getContainer = __bind(this.getContainer, this);
    }

    DOMPlugin.prototype.getContainer = function() {
      switch (typeof this.sb.options.container) {
        case "string":
          return document.getElementById(this.sb.options.container);
        case "object":
          return this.sb.options.container;
        default:
          return document.getElementById(this.sb.instanceId);
      }
    };

    return DOMPlugin;

  })();

  plugin = {
    id: "dom",
    sandbox: DOMPlugin
  };

  if (window.scaleApp != null) window.scaleApp.registerPlugin(plugin);

  if (typeof exports !== "undefined" && exports !== null) exports.Plugin = plugin;

  Mediator = (typeof window !== "undefined" && window !== null ? (_ref = window.scaleApp) != null ? _ref.Mediator : void 0 : void 0) || (typeof require === "function" ? require("../Mediator").Mediator : void 0);

  baseLanguage = "en";

  getBrowserLanguage = function() {
    return ((typeof navigator !== "undefined" && navigator !== null ? navigator.language : void 0) || (typeof navigator !== "undefined" && navigator !== null ? navigator.browserLanguage : void 0) || baseLanguage).split("-")[0];
  };

  lang = getBrowserLanguage();

  mediator = new Mediator;

  channelName = "i18n";

  subscribe = function() {
    return mediator.subscribe.apply(mediator, [channelName].concat(__slice.call(arguments)));
  };

  unsubscribe = function() {
    return mediator.unsubscribe.apply(mediator, [channelName].concat(__slice.call(arguments)));
  };

  getLanguage = function() {
    return lang;
  };

  setLanguage = function(code) {
    if (typeof code === "string") {
      lang = code;
      return mediator.publish(channelName, lang);
    }
  };

  get = function(x, text) {
    var _ref2, _ref3, _ref4, _ref5, _ref6, _ref7;
    return (_ref2 = (_ref3 = x[lang]) != null ? _ref3[text] : void 0) != null ? _ref2 : (_ref4 = (_ref5 = x[lang.substring(0, 2)]) != null ? _ref5[text] : void 0) != null ? _ref4 : (_ref6 = (_ref7 = x[baseLanguage]) != null ? _ref7[text] : void 0) != null ? _ref6 : text;
  };

  SBPlugin = (function() {

    function SBPlugin(sb) {
      this.sb = sb;
    }

    SBPlugin.prototype.i18n = {
      subscribe: subscribe,
      unsubscribe: unsubscribe
    };

    SBPlugin.prototype._ = function(text) {
      var i18n;
      i18n = this.sb.options.i18n;
      if (typeof i18n !== "object") return text;
      return get(i18n, text);
    };

    SBPlugin.prototype.getLanguage = getLanguage;

    return SBPlugin;

  })();

  plugin = {
    id: "i18n",
    sandbox: SBPlugin,
    core: {
      i18n: {
        setLanguage: setLanguage,
        getBrowserLanguage: getBrowserLanguage,
        getLanguage: getLanguage,
        baseLanguage: baseLanguage,
        get: get,
        subscribe: subscribe,
        unsubscribe: unsubscribe
      }
    }
  };

  if ((typeof window !== "undefined" && window !== null ? window.scaleApp : void 0) != null) {
    if (typeof window !== "undefined" && window !== null) {
      window.scaleApp.registerPlugin(plugin);
    }
  }

  if (typeof exports !== "undefined" && exports !== null) exports.Plugin = plugin;

  UtilPlugin = (function() {

    function UtilPlugin(sb) {}

    UtilPlugin.prototype.countObjectKeys = function(o) {
      var k, v;
      if (typeof o === "object") {
        return ((function() {
          var _results;
          _results = [];
          for (k in o) {
            v = o[k];
            _results.push(k);
          }
          return _results;
        })()).length;
      }
    };

    UtilPlugin.prototype.mixin = function(receivingClass, givingClass, override) {
      if (override == null) override = false;
      switch ("" + (typeof givingClass) + "-" + (typeof receivingClass)) {
        case "function-function":
          return this.mix(givingClass.prototype, receivingClass.prototype, override);
        case "function-object":
          return this.mix(givingClass.prototype, receivingClass, override);
        case "object-object":
          return this.mix(givingClass, receivingClass, override);
        case "object-function":
          return this.mix(givingClass, receivingClass.prototype, override);
      }
    };

    UtilPlugin.prototype.mix = function(giv, rec, override) {
      var k, v, _results, _results2;
      if (override === true) {
        _results = [];
        for (k in giv) {
          v = giv[k];
          _results.push(rec[k] = v);
        }
        return _results;
      } else {
        _results2 = [];
        for (k in giv) {
          v = giv[k];
          if (!rec.hasOwnProperty(k)) _results2.push(rec[k] = v);
        }
        return _results2;
      }
    };

    return UtilPlugin;

  })();

  plugin = {
    id: "util",
    sandbox: UtilPlugin
  };

  if (typeof scaleApp !== "undefined" && scaleApp !== null) {
    scaleApp.registerPlugin(plugin);
  }

  if (typeof exports !== "undefined" && exports !== null) exports.Plugin = plugin;

  scaleApp = (typeof window !== "undefined" && window !== null ? window.scaleApp : void 0) || (typeof require === "function" ? require("../scaleApp").scaleApp : void 0);

  Model = (function(_super) {

    __extends(Model, _super);

    function Model(obj) {
      var k, v;
      Model.__super__.constructor.call(this);
      this.id = (obj != null ? obj.id : void 0) || scaleApp.uniqueId();
      for (k in obj) {
        v = obj[k];
        if (!(this[k] != null)) this[k] = v;
      }
    }

    Model.prototype.set = function(key, val, silent) {
      var k, v;
      if (silent == null) silent = false;
      switch (typeof key) {
        case "object":
          for (k in key) {
            v = key[k];
            this.set(k, v, true);
          }
          if (!silent) {
            this.publish(Model.CHANGED, (function() {
              var _results;
              _results = [];
              for (k in key) {
                v = key[k];
                _results.push(k);
              }
              return _results;
            })());
          }
          break;
        case "string":
          if (!(key === "set" || key === "get") && this[key] !== val) {
            this[key] = val;
            if (!silent) this.publish(Model.CHANGED, [key]);
          }
          break;
        default:
          if (typeof console !== "undefined" && console !== null) {
            if (typeof console.error === "function") {
              console.error("key is not a string");
            }
          }
      }
      return this;
    };

    Model.prototype.change = function(cb, context) {
      if (typeof cb === "function") {
        return this.subscribe(Model.CHANGED, cb, context);
      } else if (arguments.length === 0) {
        return this.publish(Model.CHANGED);
      }
    };

    Model.prototype.notify = function() {
      return this.change();
    };

    Model.prototype.get = function(key) {
      return this[key];
    };

    Model.prototype.toJSON = function() {
      var json, k, v;
      json = {};
      for (k in this) {
        if (!__hasProp.call(this, k)) continue;
        v = this[k];
        json[k] = v;
      }
      return json;
    };

    Model.CHANGED = "changed";

    return Model;

  })(scaleApp.Mediator);

  View = (function() {

    function View(model) {
      if (model) this.setModel(model);
    }

    View.prototype.setModel = function(model) {
      this.model = model;
      return this.model.change((function() {
        return this.render();
      }), this);
    };

    View.prototype.render = function() {};

    return View;

  })();

  Controller = (function() {

    function Controller(model, view) {
      this.model = model;
      this.view = view;
    }

    return Controller;

  })();

  plugin = {
    id: "mvc",
    core: {
      Model: Model,
      View: View,
      Controller: Controller
    }
  };

  if ((typeof window !== "undefined" && window !== null ? window.scaleApp : void 0) != null) {
    scaleApp.registerPlugin(plugin);
  }

  if (typeof exports !== "undefined" && exports !== null) exports.Plugin = plugin;

}).call(this);
