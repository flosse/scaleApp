(function() {
  var Mediator, Sandbox, VERSION, addModule, clone, core, coreKeywords, createInstance, doForAll, error, getArgumentNames, getInstanceOptions, instanceOpts, instances, lsInstances, lsModules, mediator, modules, onInstantiate, onInstantiateFunctions, plugins, register, registerPlugin, runSeries, sandboxKeywords, setInstanceOptions, start, startAll, stop, stopAll, uniqueId, unregister, unregisterAll, util,
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

  getArgumentNames = function(fn) {
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

  runSeries = function(tasks, cb) {
    var checkEnd, count, errors, i, results, t, _i, _len, _results;
    if (cb == null) {
      cb = function() {};
    }
    count = tasks.length;
    results = [];
    if (count === 0) {
      return typeof cb === "function" ? cb(null, results) : void 0;
    }
    errors = [];
    checkEnd = function() {
      var e;
      count--;
      if (count === 0) {
        if (((function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = errors.length; _i < _len; _i++) {
            e = errors[_i];
            if (e != null) {
              _results.push(e);
            }
          }
          return _results;
        })()).length > 0) {
          return cb(errors, results);
        } else {
          return cb(null, results);
        }
      }
    };
    _results = [];
    for (i = _i = 0, _len = tasks.length; _i < _len; i = ++_i) {
      t = tasks[i];
      _results.push((function(t, i) {
        var next;
        next = function(err, result) {
          if (err != null) {
            errors[i] = err;
            results[i] = void 0;
          } else {
            results[i] = result;
          }
          return checkEnd();
        };
        try {
          return t(next);
        } catch (e) {
          return next(e);
        }
      })(t, i));
    }
    return _results;
  };

  doForAll = function(args, fn, cb) {
    var a, tasks;
    tasks = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = args.length; _i < _len; _i++) {
        a = args[_i];
        _results.push((function(a) {
          return function(next) {
            return fn(a, next);
          };
        })(a));
      }
      return _results;
    })();
    return util.runSeries(tasks, cb);
  };

  util = {
    doForAll: doForAll,
    runSeries: runSeries,
    clone: clone,
    getArgumentNames: getArgumentNames,
    uniqueId: uniqueId
  };

  if ((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) {
    module.exports = util;
  }

  if (((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) && typeof require === "function") {
    util = require("./Util");
  }

  Mediator = (function() {

    function Mediator(obj, cascadeChannels) {
      this.cascadeChannels = cascadeChannels != null ? cascadeChannels : false;
      this.channels = {};
      if (obj) {
        this.installTo(obj);
      }
    }

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
      var chnls, copy, sub, subscribers, tasks;
      if (opt == null) {
        opt = {};
      }
      if (typeof data === "function") {
        opt = data;
        data = void 0;
      }
      if (typeof channel !== "string") {
        return false;
      }
      subscribers = this.channels[channel] || [];
      if (opt.publishReference !== true && typeof data === "object") {
        copy = util.clone(data);
      }
      tasks = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = subscribers.length; _i < _len; _i++) {
          sub = subscribers[_i];
          _results.push((function(sub) {
            return function(next) {
              try {
                if ((util.getArgumentNames(sub.callback)).length >= 3) {
                  return sub.callback.apply(sub.context, [copy || data, channel, next]);
                } else {
                  return next(null, sub.callback.apply(sub.context, [copy || data, channel]));
                }
              } catch (e) {
                return next(e);
              }
            };
          })(sub));
        }
        return _results;
      })();
      util.runSeries(tasks, function(errors, results) {
        var e, x;
        if (errors && errors.length > (0 != null)) {
          e = new Error(((function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = errors.length; _i < _len; _i++) {
              x = errors[_i];
              if (x != null) {
                _results.push(x.message);
              }
            }
            return _results;
          })()).join('; '));
        }
        return typeof opt === "function" ? opt(e) : void 0;
      });
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
    util = require("./Util");
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
      if ((util.getArgumentNames(instance.init)).length >= 2) {
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
      if ((util.getArgumentNames(instance.destroy)).length >= 1) {
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
        return next(err);
      };
      return start(m, o);
    };
    util.doForAll(valid, startAction, function(err) {
      var e, i, x;
      if ((err != null ? err.length : void 0) > 0) {
        e = new Error("errors occoured in the following modules: " + ((function() {
          var _i, _len, _results;
          _results = [];
          for (i = _i = 0, _len = err.length; _i < _len; i = ++_i) {
            x = err[i];
            if (x != null) {
              _results.push("'" + valid[i] + "'");
            }
          }
          return _results;
        })()));
      }
      return typeof cb === "function" ? cb(e || invalidErr) : void 0;
    });
    return !(invalidErr != null);
  };

  stopAll = function(cb) {
    var id;
    return util.doForAll((function() {
      var _results;
      _results = [];
      for (id in instances) {
        _results.push(id);
      }
      return _results;
    })(), stop, cb);
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
    uniqueId: util.uniqueId,
    lsInstances: lsInstances,
    lsModules: lsModules,
    util: util,
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
(function() {
  var Mediator, SBPlugin, addPermission, grantAction, hasPermission, permissions, plugin, removePermission, tweakSandboxMethod, _ref;

  Mediator = (typeof window !== "undefined" && window !== null ? (_ref = window.scaleApp) != null ? _ref.Mediator : void 0 : void 0) || (typeof require === "function" ? require("../Mediator") : void 0);

  permissions = {};

  addPermission = function(id, action) {
    var p, _ref1;
    p = (_ref1 = permissions[id]) != null ? _ref1 : permissions[id] = {};
    return p[action] = true;
  };

  removePermission = function(id, action) {
    var p;
    p = permissions[id];
    if (!(p != null)) {
      return false;
    } else {
      delete p[action];
      return true;
    }
  };

  hasPermission = function(id, action) {
    var p, _ref1;
    p = (_ref1 = permissions[id]) != null ? _ref1[action] : void 0;
    if (p != null) {
      return true;
    } else {
      console.warn("" + id + " has no permissions for '" + action + "'");
      return false;
    }
  };

  grantAction = function(sb, action, method, args) {
    var p;
    p = hasPermission(sb.instanceId, action);
    if (p === true) {
      return method.apply(sb, args);
    } else {
      return false;
    }
  };

  tweakSandboxMethod = function(sb, methodName) {
    var originalMethod;
    originalMethod = sb[methodName];
    if (typeof originalMethod === "function") {
      return sb[methodName] = function() {
        return grantAction(sb, methodName, originalMethod, arguments);
      };
    }
  };

  SBPlugin = (function() {

    function SBPlugin(sb) {
      tweakSandboxMethod(sb, "subscribe");
      tweakSandboxMethod(sb, "publish");
      tweakSandboxMethod(sb, "unsubscribe");
    }

    return SBPlugin;

  })();

  plugin = {
    id: "permission",
    sandbox: SBPlugin,
    core: {
      permission: {
        add: addPermission,
        remove: removePermission
      }
    }
  };

  if ((typeof window !== "undefined" && window !== null ? window.scaleApp : void 0) != null) {
    window.scaleApp.registerPlugin(plugin);
  }

  if ((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) {
    module.exports = plugin;
  }

  if ((typeof define !== "undefined" && define !== null ? define.amd : void 0) != null) {
    define(function() {
      return plugin;
    });
  }

}).call(this);

(function() {
  var DOMPlugin, plugin,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

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

  if (window.scaleApp != null) {
    window.scaleApp.registerPlugin(plugin);
  }

  if ((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) {
    module.exports = plugin;
  }

  if ((typeof define !== "undefined" && define !== null ? define.amd : void 0) != null) {
    define(function() {
      return plugin;
    });
  }

}).call(this);

(function() {
  var Controller, Model, View, plugin, scaleApp,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  scaleApp = (typeof window !== "undefined" && window !== null ? window.scaleApp : void 0) || (typeof require === "function" ? require("../scaleApp") : void 0);

  Model = (function(_super) {

    __extends(Model, _super);

    function Model(obj) {
      var k, v;
      Model.__super__.constructor.call(this);
      this.id = (obj != null ? obj.id : void 0) || scaleApp.uniqueId();
      for (k in obj) {
        v = obj[k];
        if (!(this[k] != null)) {
          this[k] = v;
        }
      }
    }

    Model.prototype.set = function(key, val, silent) {
      var k, v;
      if (silent == null) {
        silent = false;
      }
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
            if (!silent) {
              this.publish(Model.CHANGED, [key]);
            }
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
      if (model) {
        this.setModel(model);
      }
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

  if ((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) {
    module.exports = plugin;
  }

  if ((typeof define !== "undefined" && define !== null ? define.amd : void 0) != null) {
    define(function() {
      return plugin;
    });
  }

}).call(this);

(function() {
  var Mediator, SBPlugin, baseLanguage, channelName, get, getBrowserLanguage, getLanguage, getText, global, lang, mediator, plugin, setGlobal, setLanguage, subscribe, unsubscribe, _ref,
    __slice = [].slice;

  Mediator = (typeof window !== "undefined" && window !== null ? (_ref = window.scaleApp) != null ? _ref.Mediator : void 0 : void 0) || (typeof require === "function" ? require("../Mediator") : void 0);

  baseLanguage = "en";

  getBrowserLanguage = function() {
    return ((typeof navigator !== "undefined" && navigator !== null ? navigator.language : void 0) || (typeof navigator !== "undefined" && navigator !== null ? navigator.browserLanguage : void 0) || baseLanguage).split("-")[0];
  };

  lang = getBrowserLanguage();

  mediator = new Mediator;

  channelName = "i18n";

  global = {};

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

  setGlobal = function(obj) {
    if (typeof obj === "object") {
      global = obj;
      return true;
    } else {
      return false;
    }
  };

  getText = function(key, x, l) {
    var _ref1, _ref2;
    return ((_ref1 = x[l]) != null ? _ref1[key] : void 0) || ((_ref2 = global[l]) != null ? _ref2[key] : void 0);
  };

  get = function(key, x) {
    if (x == null) {
      x = {};
    }
    return getText(key, x, lang) || getText(key, x, lang.substring(0, 2)) || getText(key, x, baseLanguage) || key;
  };

  SBPlugin = (function() {

    function SBPlugin(sb) {
      this.sb = sb;
    }

    SBPlugin.prototype.i18n = {
      subscribe: subscribe,
      on: subscribe,
      unsubscribe: unsubscribe
    };

    SBPlugin.prototype._ = function(text) {
      return get(text, this.sb.options.i18n);
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
        on: subscribe,
        unsubscribe: unsubscribe,
        setGlobal: setGlobal
      }
    }
  };

  if ((typeof window !== "undefined" && window !== null ? window.scaleApp : void 0) != null) {
    if (typeof window !== "undefined" && window !== null) {
      window.scaleApp.registerPlugin(plugin);
    }
  }

  if ((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) {
    module.exports = plugin;
  }

  if ((typeof define !== "undefined" && define !== null ? define.amd : void 0) != null) {
    define(function() {
      return plugin;
    });
  }

}).call(this);

(function() {
  var StateMachine, plugin, scaleApp,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  scaleApp = (typeof window !== "undefined" && window !== null ? window.scaleApp : void 0) || (typeof require === "function" ? require("../scaleApp") : void 0);

  StateMachine = (function(_super) {

    __extends(StateMachine, _super);

    function StateMachine(opts) {
      var id, s, t, _i, _j, _len, _len1, _ref, _ref1;
      if (opts == null) {
        opts = {};
      }
      this.fire = __bind(this.fire, this);

      StateMachine.__super__.constructor.call(this);
      this.states = [];
      this.transitions = {};
      if (opts.start != null) {
        this.addState(opts.start);
        this.start = opts.start;
        this.current = opts.start;
      }
      if (opts.states != null) {
        _ref = opts.states;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          s = _ref[_i];
          this.addState(s);
        }
      }
      if (opts.transitions != null) {
        _ref1 = opts.transitions;
        for (t = _j = 0, _len1 = _ref1.length; _j < _len1; t = ++_j) {
          id = _ref1[t];
          this.addTransition(id, t);
        }
      }
    }

    StateMachine.prototype.start = null;

    StateMachine.prototype.current = null;

    StateMachine.prototype.exit = null;

    StateMachine.prototype.addState = function(id, opt) {
      var k, s, success, v;
      if (opt == null) {
        opt = {};
      }
      if (id instanceof Array) {
        return !(__indexOf.call((function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = id.length; _i < _len; _i++) {
            s = id[_i];
            _results.push(this.addState(s));
          }
          return _results;
        }).call(this), false) >= 0);
      } else if (typeof id === "object") {
        return !(__indexOf.call((function() {
          var _results;
          _results = [];
          for (k in id) {
            v = id[k];
            _results.push(this.addState(k, v));
          }
          return _results;
        }).call(this), false) >= 0);
      } else {
        if (typeof id !== "string") {
          return false;
        }
        if (__indexOf.call(this.states, id) >= 0) {
          return false;
        }
        this.states.push(id);
        success = [];
        if (opt.enter != null) {
          success.push(this.on("" + id + "/enter", opt.enter));
        }
        if (opt.leave != null) {
          success.push(this.on("" + id + "/leave", opt.leave));
        }
        return !(__indexOf.call(success, false) >= 0);
      }
    };

    StateMachine.prototype.addTransition = function(id, edge) {
      var err, i, _ref;
      if (!((typeof id === "string") && (typeof edge.to === "string") && (!(this.transitions[id] != null)) && (_ref = edge.to, __indexOf.call(this.states, _ref) >= 0))) {
        return false;
      }
      if (edge.from instanceof Array) {
        err = __indexOf.call((function() {
          var _i, _len, _ref1, _results;
          _ref1 = edge.from;
          _results = [];
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            i = _ref1[_i];
            _results.push(__indexOf.call(this.states, i) >= 0);
          }
          return _results;
        }).call(this), false) >= 0;
        if (err !== false) {
          return false;
        }
      } else if (typeof edge.from !== "string") {
        return false;
      }
      this.transitions[id] = {
        from: edge.from,
        to: edge.to
      };
      return true;
    };

    StateMachine.prototype.onEnter = function(state, cb) {
      var _ref;
      if (_ref = !state, __indexOf.call(this.states, _ref) >= 0) {
        return false;
      }
      console.log("subsribing to " + state + "/enter");
      return this.on("" + state + "/enter", cb);
    };

    StateMachine.prototype.onLeave = function(state, cb) {
      var _ref;
      if (_ref = !state, __indexOf.call(this.states, _ref) >= 0) {
        return false;
      }
      console.log("subsribing to " + state + "/leave");
      return this.on("" + state + "/leave", cb);
    };

    StateMachine.prototype.fire = function(id, cb) {
      var t,
        _this = this;
      t = this.transitions[id];
      if (!((t != null) && this.can(id))) {
        return false;
      }
      this.emit("" + t.from + "/leave", t, function(err) {
        if (err != null) {
          return typeof cb === "function" ? cb(err) : void 0;
        } else {
          console.log("emmiiting to " + t.to + "/enter");
          return _this.emit("" + t.to + "/enter", t, function(err) {
            if (!(err != null)) {
              _this.current = t.to;
            }
            return typeof cb === "function" ? cb(err) : void 0;
          });
        }
      });
      return true;
    };

    StateMachine.prototype.can = function(id) {
      var t, _ref;
      t = this.transitions[id];
      return (t != null ? t.from : void 0) === this.current || (_ref = this.current, __indexOf.call(t, _ref) >= 0) || t.from === "*";
    };

    return StateMachine;

  })(scaleApp.Mediator);

  plugin = {
    id: "state",
    core: {
      StateMachine: StateMachine
    }
  };

  if ((typeof window !== "undefined" && window !== null ? window.scaleApp : void 0) != null) {
    scaleApp.registerPlugin(plugin);
  }

  if ((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) {
    module.exports = plugin;
  }

  if ((typeof define !== "undefined" && define !== null ? define.amd : void 0) != null) {
    define(function() {
      return plugin;
    });
  }

}).call(this);

(function() {
  var UtilPlugin, mix, plugin;

  mix = function(giv, rec, override) {
    var k, v, _results, _results1;
    if (override === true) {
      _results = [];
      for (k in giv) {
        v = giv[k];
        _results.push(rec[k] = v);
      }
      return _results;
    } else {
      _results1 = [];
      for (k in giv) {
        v = giv[k];
        if (!rec.hasOwnProperty(k)) {
          _results1.push(rec[k] = v);
        }
      }
      return _results1;
    }
  };

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
      if (override == null) {
        override = false;
      }
      switch ("" + (typeof givingClass) + "-" + (typeof receivingClass)) {
        case "function-function":
          return mix(givingClass.prototype, receivingClass.prototype, override);
        case "function-object":
          return mix(givingClass.prototype, receivingClass, override);
        case "object-object":
          return mix(givingClass, receivingClass, override);
        case "object-function":
          return mix(givingClass, receivingClass.prototype, override);
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

  if ((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) {
    module.exports = plugin;
  }

  if ((typeof define !== "undefined" && define !== null ? define.amd : void 0) != null) {
    define(function() {
      return plugin;
    });
  }

}).call(this);
