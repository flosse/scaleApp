(function() {
  var Mediator, Sandbox, VERSION, addModule, checkEnd, clone, core, coreKeywords, createInstance, doForAll, error, getInstanceOptions, instanceOpts, instances, lsInstances, lsModules, mediator, modules, onInstantiate, onInstantiateFunctions, plugins, register, registerPlugin, sandboxKeywords, setInstanceOptions, start, startAll, stop, stopAll, uniqueId, unregister, unregisterAll,
    __hasProp = {}.hasOwnProperty,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  clone = function(data) {
    var copy, k, v;
    if (data instanceof Array) {
      copy = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          v = data[_i];
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
    return copy;
  };

  Mediator = (function() {

    function Mediator(obj, cascadeChannels) {
      this.cascadeChannels = cascadeChannels != null ? cascadeChannels : false;
      this.channels = {};
      if (obj) {
        this.installTo(obj);
      }
    }

    Mediator.getArgumentNames = function(fn) {
      var a, args, _i, _len, _results;
      args = fn.toString().match(/function[^(]*\(([^)]*)\)/);
      if (!(args != null) || (args.length < 2)) {
        return [];
      }
      args = args[1];
      args = args.split(/\s*,\s*/);
      _results = [];
      for (_i = 0, _len = args.length; _i < _len; _i++) {
        a = args[_i];
        if (a.trim() !== '') {
          _results.push(a);
        }
      }
      return _results;
    };

    Mediator.prototype.subscribe = function(channel, fn, context) {
      var id, k, subscription, that, v, _base, _i, _len, _ref, _results, _results1;
      if (context == null) {
        context = this;
      }
      if ((_ref = (_base = this.channels)[channel]) == null) {
        _base[channel] = [];
      }
      that = this;
      if (channel instanceof Array) {
        _results = [];
        for (_i = 0, _len = channel.length; _i < _len; _i++) {
          id = channel[_i];
          _results.push(this.subscribe(id, fn, context));
        }
        return _results;
      } else if (typeof channel === "object") {
        _results1 = [];
        for (k in channel) {
          v = channel[k];
          _results1.push(this.subscribe(k, v, fn));
        }
        return _results1;
      } else {
        if (typeof fn !== "function") {
          return false;
        }
        if (typeof channel !== "string") {
          return false;
        }
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

    Mediator.prototype.on = Mediator.prototype.subscribe;

    Mediator.prototype.unsubscribe = function(ch, cb) {
      var id;
      switch (typeof ch) {
        case "string":
          if (typeof cb === "function") {
            Mediator._rm(this, ch, cb);
          }
          if (typeof cb === "undefined") {
            Mediator._rm(this, ch);
          }
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

    Mediator.prototype.publish = function(channel, data, opt) {
      var callbacks, cb, chnls, copy, counter, errors, finish, result, sub, _i, _len, _ref;
      if (opt == null) {
        opt = {};
      }
      if (this.channels[channel] != null) {
        callbacks = [];
        errors = [];
        counter = this.channels[channel].length;
        finish = function(err) {
          var e, x;
          if (err != null) {
            errors.push(err);
          }
          if (counter === 0) {
            e = null;
            if (errors.length > 0) {
              e = new Error(((function() {
                var _i, _len, _results;
                _results = [];
                for (_i = 0, _len = errors.length; _i < _len; _i++) {
                  x = errors[_i];
                  _results.push(x.message);
                }
                return _results;
              })()).join('; '));
            }
            return typeof opt === "function" ? opt(e) : void 0;
          }
        };
        _ref = this.channels[channel];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          sub = _ref[_i];
          if (opt.publishReference !== true && typeof data === "object") {
            copy = clone(data);
          }
          cb = void 0;
          if ((Mediator.getArgumentNames(sub.callback)).length >= 3) {
            cb = function(err) {
              counter--;
              return finish(err);
            };
            callbacks.push(cb);
          } else {
            counter--;
          }
          try {
            result = sub.callback.apply(sub.context, [copy || data, channel, cb]);
            if (result === false || result instanceof Error) {
              errors.push(result);
            }
          } catch (e) {
            e;

          }
          finish();
        }
      }
      if (this.cascadeChannels && (chnls = channel.split('/')).length > 1) {
        this.publish(chnls.slice(0, -1).join('/'), data, opt);
      }
      return this;
    };

    Mediator.prototype.emit = Mediator.prototype.publish;

    Mediator.prototype.installTo = function(obj) {
      var k, v;
      if (typeof obj === "object") {
        for (k in this) {
          v = this[k];
          obj[k] = v;
        }
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

  if ((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) {
    module.exports = Mediator;
  }

  Sandbox = (function() {

    function Sandbox(core, instanceId, options) {
      this.core = core;
      this.instanceId = instanceId;
      this.options = options != null ? options : {};
      if (this.core == null) {
        throw new TypeError("core was not defined");
      }
      if (instanceId == null) {
        throw new TypeError("no id was specified");
      }
      if (typeof instanceId !== "string") {
        throw new TypeError("id is not a string");
      }
    }

    return Sandbox;

  })();

  if ((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) {
    module.exports = Sandbox;
  }

  /*
  This program is distributed under the terms of the MIT license.
  Copyright (c) 2011-2012 Markus Kohlhase (mail@markus-kohlhase.de)
  */


  if (((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) && typeof require === "function") {
    Mediator = require("./Mediator");
    Sandbox = require("./Sandbox");
  }

  VERSION = "0.3.8";

  modules = {};

  instances = {};

  instanceOpts = {};

  mediator = new Mediator;

  plugins = {};

  error = function(e) {
    return typeof console !== "undefined" && console !== null ? typeof console.error === "function" ? console.error(e.message) : void 0 : void 0;
  };

  uniqueId = function(length) {
    var id;
    if (length == null) {
      length = 8;
    }
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

  getInstanceOptions = function(instanceId, module, opt) {
    var io, key, o, val, _ref;
    o = {};
    _ref = module.options;
    for (key in _ref) {
      val = _ref[key];
      o[key] = val;
    }
    io = instanceOpts[instanceId];
    if (io) {
      for (key in io) {
        val = io[key];
        o[key] = val;
      }
    }
    if (opt) {
      for (key in opt) {
        val = opt[key];
        o[key] = val;
      }
    }
    return o;
  };

  createInstance = function(moduleId, instanceId, opt) {
    var entry, i, iOpts, instance, k, module, n, p, plugin, sb, v, _i, _j, _len, _len1, _ref, _ref1;
    if (instanceId == null) {
      instanceId = moduleId;
    }
    module = modules[moduleId];
    if (instances[instanceId] != null) {
      return instances[instanceId];
    }
    iOpts = getInstanceOptions(instanceId, module, opt);
    sb = new Sandbox(core, instanceId, iOpts);
    mediator.installTo(sb);
    for (i in plugins) {
      p = plugins[i];
      if (!(p.sandbox != null)) {
        continue;
      }
      plugin = new p.sandbox(sb);
      for (k in plugin) {
        if (!__hasProp.call(plugin, k)) continue;
        v = plugin[k];
        sb[k] = v;
      }
    }
    instance = new module.creator(sb);
    instance.options = iOpts;
    instance.id = instanceId;
    instances[instanceId] = instance;
    _ref = [instanceId, '_always'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      n = _ref[_i];
      if (onInstantiateFunctions[n] != null) {
        _ref1 = onInstantiateFunctions[n];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          entry = _ref1[_j];
          entry.callback.apply(entry.context);
        }
      }
    }
    return instance;
  };

  addModule = function(moduleId, creator, opt) {
    var modObj;
    if (typeof moduleId !== "string") {
      throw new TypeError("module ID has to be a string");
    }
    if (typeof creator !== "function") {
      throw new TypeError("creator has to be a constructor function");
    }
    if (typeof opt !== "object") {
      throw new TypeError("option parameter has to be an object");
    }
    modObj = new creator();
    if (typeof modObj !== "object") {
      throw new TypeError("creator has to return an object");
    }
    if (typeof modObj.init !== "function") {
      throw new TypeError("module has to have an init function");
    }
    if (typeof modObj.destroy !== "function") {
      throw new TypeError("module has to have a destroy function");
    }
    if (modules[moduleId] != null) {
      throw new TypeError("module " + moduleId + " was already registered");
    }
    modules[moduleId] = {
      creator: creator,
      options: opt,
      id: moduleId
    };
    return true;
  };

  register = function(moduleId, creator, opt) {
    if (opt == null) {
      opt = {};
    }
    try {
      return addModule(moduleId, creator, opt);
    } catch (e) {
      error(new Error("could not register module '" + moduleId + "': " + e.message));
      return false;
    }
  };

  setInstanceOptions = function(instanceId, opt) {
    var k, v, _ref, _results;
    if (typeof instanceId !== "string") {
      throw new TypeError("instance ID has to be a string");
    }
    if (typeof opt !== "object") {
      throw new TypeError("option parameter has to be an object");
    }
    if ((_ref = instanceOpts[instanceId]) == null) {
      instanceOpts[instanceId] = {};
    }
    _results = [];
    for (k in opt) {
      v = opt[k];
      _results.push(instanceOpts[instanceId][k] = v);
    }
    return _results;
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
    if (opt == null) {
      opt = {};
    }
    try {
      if (typeof moduleId !== "string") {
        throw new Error("module ID has to be a string");
      }
      if (typeof opt !== "object") {
        throw new Error("second parameter has to be an object");
      }
      if (modules[moduleId] == null) {
        throw new Error("module does not exist");
      }
      instance = createInstance(moduleId, opt.instanceId, opt.options);
      if (instance.running === true) {
        throw new Error("module was already started");
      }
      if ((Mediator.getArgumentNames(instance.init)).length >= 2) {
        instance.init(instance.options, function(err) {
          return typeof opt.callback === "function" ? opt.callback(err) : void 0;
        });
      } else {
        instance.init(instance.options);
        if (typeof opt.callback === "function") {
          opt.callback(null);
        }
      }
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
      if ((Mediator.getArgumentNames(instance.destroy)).length >= 1) {
        instance.destroy(function(err) {
          return typeof cb === "function" ? cb(err) : void 0;
        });
      } else {
        instance.destroy();
        if (typeof cb === "function") {
          cb(null);
        }
      }
      delete instances[id];
      return true;
    } else {
      return false;
    }
  };

  doForAll = function(modules, action, cb) {
    var actionCB, count, errors, m, _i, _len;
    count = modules.length;
    if (count === 0) {
      if (typeof cb === "function") {
        cb(null);
      }
      return true;
    } else {
      errors = [];
      actionCB = function() {
        count--;
        return checkEnd(count, errors, cb);
      };
      for (_i = 0, _len = modules.length; _i < _len; _i++) {
        m = modules[_i];
        if (!action(m, actionCB)) {
          errors.push("'" + m + "'");
        }
      }
      return errors.length === 0;
    }
  };

  checkEnd = function(count, errors, cb) {
    if (count === 0) {
      if (errors.length > 0) {
        return typeof cb === "function" ? cb(new Error("errors occoured in the following modules: " + errors)) : void 0;
      } else {
        return typeof cb === "function" ? cb(null) : void 0;
      }
    }
  };

  startAll = function(cb, opt) {
    var aCB, id, invalid, invalidErr, mods, startAction, valid, _ref;
    if (cb instanceof Array) {
      mods = cb;
      cb = opt;
      opt = null;
      valid = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = mods.length; _i < _len; _i++) {
          id = mods[_i];
          if (modules[id] != null) {
            _results.push(id);
          }
        }
        return _results;
      })();
    } else {
      mods = valid = (function() {
        var _results;
        _results = [];
        for (id in modules) {
          _results.push(id);
        }
        return _results;
      })();
    }
    if ((valid.length === (_ref = mods.length) && _ref === 0)) {
      if (typeof cb === "function") {
        cb(null);
      }
      return true;
    } else if (valid.length !== mods.length) {
      invalid = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = mods.length; _i < _len; _i++) {
          id = mods[_i];
          if (!(__indexOf.call(valid, id) >= 0)) {
            _results.push("'" + id + "'");
          }
        }
        return _results;
      })();
      invalidErr = new Error("these modules don't exist: " + invalid);
    }
    startAction = function(m, next) {
      var k, modOpts, o, v;
      o = {};
      modOpts = modules[m].options;
      for (k in modOpts) {
        if (!__hasProp.call(modOpts, k)) continue;
        v = modOpts[k];
        if (v) {
          o[k] = v;
        }
      }
      o.callback = function(err) {
        if (typeof modOpts.callback === "function") {
          modOpts.callback(err);
        }
        return typeof next === "function" ? next() : void 0;
      };
      return start(m, o);
    };
    aCB = function(err) {
      return typeof cb === "function" ? cb(err || invalidErr) : void 0;
    };
    return (doForAll(valid, startAction, aCB)) && !(invalidErr != null);
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

  coreKeywords = ["VERSION", "register", "unregister", "registerPlugin", "start", "stop", "startAll", "stopAll", "publish", "subscribe", "unsubscribe", "on", "emit", "setInstanceOptions", "Mediator", "Sandbox", "unregisterAll", "uniqueId", "lsModules", "lsInstances"];

  sandboxKeywords = ["core", "instanceId", "options", "publish", "emit", "on", "subscribe", "unsubscribe"];

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
    var k, v, _ref, _ref1;
    try {
      if (typeof plugin !== "object") {
        throw new Error("plugin has to be an object");
      }
      if (typeof plugin.id !== "string") {
        throw new Error("plugin has no id");
      }
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
        _ref1 = plugin.core;
        for (k in _ref1) {
          v = _ref1[k];
          core[k] = v;
          if (typeof exports !== "undefined" && exports !== null) {
            exports[k] = v;
          }
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
    setInstanceOptions: setInstanceOptions,
    start: start,
    stop: stop,
    startAll: startAll,
    stopAll: stopAll,
    uniqueId: uniqueId,
    lsInstances: lsInstances,
    lsModules: lsModules,
    Mediator: Mediator,
    Sandbox: Sandbox,
    subscribe: function() {
      return mediator.subscribe.apply(mediator, arguments);
    },
    on: function() {
      return mediator.subscribe.apply(mediator, arguments);
    },
    unsubscribe: function() {
      return mediator.unsubscribe.apply(mediator, arguments);
    },
    publish: function() {
      return mediator.publish.apply(mediator, arguments);
    },
    emit: function() {
      return mediator.publish.apply(mediator, arguments);
    }
  };

  if ((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) {
    module.exports = core;
  }

  if (typeof window !== "undefined" && window !== null) {
    window.scaleApp = core;
  }

  if ((typeof define !== "undefined" && define !== null ? define.amd : void 0) != null) {
    define(function() {
      return core;
    });
  }

}).call(this);
