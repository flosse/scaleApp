(function() {
  var Mediator, Sandbox, VERSION, addModule, checkEnd, core, coreKeywords, createInstance, doForAll, error, instances, k, lsInstances, lsModules, mediator, modules, onInstantiate, onInstantiateFunctions, plugins, register, registerPlugin, sandboxKeywords, start, startAll, stop, stopAll, uniqueId, unregister, unregisterAll, v,
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
            try {
              subscription.callback.apply(subscription.context, [copy, channel]);
            } catch (e) {
              if (typeof console !== "undefined" && console !== null) {
                if (typeof console.error === "function") console.error(e);
              }
            }
          } else {
            try {
              subscription.callback.apply(subscription.context, [data, channel]);
            } catch (e) {
              if (typeof console !== "undefined" && console !== null) {
                if (typeof console.error === "function") console.error(e);
              }
            }
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

  VERSION = "0.3.4";

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
      instance.init(instance.options, function(err) {
        return typeof opt.callback === "function" ? opt.callback(err) : void 0;
      });
      instance.running = true;
      return true;
    } catch (e) {
      error(e);
      if (typeof opt.callback === "function") {
        opt.callback(new Error("could not start module: " + e.message));
      }
      return false;
    }
  };

  stop = function(id, cb) {
    var instance;
    if (instance = instances[id]) {
      mediator.unsubscribe(instance);
      instance.destroy(cb);
      delete instances[id];
      return true;
    } else {
      return false;
    }
  };

  doForAll = function(modules, action, cb) {
    var actionCB, count, errors, m, _i, _len;
    count = modules.length;
    errors = [];
    actionCB = function() {
      count--;
      return checkEnd(count, errors, cb);
    };
    for (_i = 0, _len = modules.length; _i < _len; _i++) {
      m = modules[_i];
      if (!(!action(m, actionCB))) continue;
      errors.push("'" + m + "'");
      actionCB();
    }
    return errors.length === 0;
  };

  checkEnd = function(count, errors, cb) {
    if (count === 0) {
      if (errors.length > 0) {
        return typeof cb === "function" ? cb(new Error("errors occoured in the following modules: " + errors)) : void 0;
      } else {
        return typeof cb === "function" ? cb() : void 0;
      }
    }
  };

  startAll = function(cb, opt) {
    var id, invalid, invalidErr, mods, startAction, valid, _ref;
    if (cb instanceof Array) {
      mods = cb;
      cb = opt;
      opt = null;
      valid = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = mods.length; _i < _len; _i++) {
          id = mods[_i];
          if (modules[id] != null) _results.push(id);
        }
        return _results;
      })();
      if (valid.length !== mods.length) {
        invalid = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = mods.length; _i < _len; _i++) {
            id = mods[_i];
            if (!(__indexOf.call(valid, id) >= 0)) _results.push("'" + id + "'");
          }
          return _results;
        })();
        invalidErr = new Error("these modules don't exist: " + invalid);
      }
    } else {
      switch (typeof cb) {
        case "undefined":
        case "function":
          mods = valid = (function() {
            var _results;
            _results = [];
            for (id in modules) {
              _results.push(id);
            }
            return _results;
          })();
          break;
        default:
          mods = valid = [];
      }
    }
    if ((valid.length === (_ref = mods.length) && _ref === 0)) {
      if (typeof cb === "function") cb(null);
      return true;
    }
    startAction = function(m, next) {
      var k, modOpts, o, v;
      o = {};
      modOpts = modules[m].options;
      for (k in modOpts) {
        if (!__hasProp.call(modOpts, k)) continue;
        v = modOpts[k];
        if (v) o[k] = v;
      }
      o.callback = function(err) {
        if (typeof modOpts.callback === "function") modOpts.callback(err);
        return next();
      };
      return start(m, o);
    };
    return (doForAll(valid, startAction, function(err) {
      return cb(err || invalidErr);
    })) && !(invalidErr != null);
  };

  stopAll = function(cb) {
    var id;
    return doForAll((function() {
      var _results;
      _results = [];
      for (id in instances) {
        _results.push(id);
      }
      return _results;
    })(), (function(m, next) {
      return stop(m, next);
    }), cb);
  };

  coreKeywords = ["VERSION", "register", "unregister", "registerPlugin", "start", "stop", "startAll", "stopAll", "publish", "subscribe", "unsubscribe", "Mediator", "Sandbox", "unregisterAll", "uniqueId", "lsModules", "lsInstances"];

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
          if (typeof exports !== "undefined" && exports !== null) exports[k] = v;
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

  if ((typeof exports !== "undefined" && exports !== null) && (typeof module !== "undefined" && module !== null)) {
    for (k in core) {
      v = core[k];
      exports[k] = v;
    }
  }

  if (typeof window !== "undefined" && window !== null) window.scaleApp = core;

}).call(this);
