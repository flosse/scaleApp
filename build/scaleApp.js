(function() {
  var Mediator, Sandbox, VERSION, addModule, core, coreKeywords, createInstance, error, instances, lsInstances, lsModules, mediator, modules, onInstantiate, onInstantiateFunctions, plugins, register, registerPlugin, sandboxKeywords, start, startAll, stop, stopAll, uniqueId, unregister, unregisterAll,
    __hasProp = Object.prototype.hasOwnProperty,
    __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

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

  lsModules = function() {
    var id, m, _results;
    _results = [];
    for (id in modules) {
      m = modules[id];
      _results.push(id);
    }
    return _results;
  };

  lsInstances = function() {
    var id, m, _results;
    _results = [];
    for (id in instances) {
      m = instances[id];
      _results.push(id);
    }
    return _results;
  };

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
    lsInstances: lsInstances,
    lsModules: lsModules,
    Mediator: Mediator,
    Sandbox: Sandbox
  };

  mediator.installTo(core);

  if (typeof exports !== "undefined" && exports !== null) exports.scaleApp = core;

  if (typeof window !== "undefined" && window !== null) window.scaleApp = core;

}).call(this);
