
/*
scaleapp - v0.3.9 - 2012-12-04
This program is distributed under the terms of the MIT license.
Copyright (c) 2011-2012  Markus Kohlhase <mail@markus-kohlhase.de>
*/


(function() {
  var Mediator, Sandbox, VERSION, addModule, checkType, clone, core, coreKeywords, createInstance, doForAll, error, getArgumentNames, getInstanceOptions, instanceOpts, instances, k, ls, mediator, modules, onInstantiate, onInstantiateFunctions, plugins, register, registerPlugin, runSeries, runWaterfall, sandboxKeywords, setInstanceOptions, start, startAll, stop, stopAll, uniqueId, unregister, unregisterAll, util, v,
    __slice = [].slice,
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

  if (!(String.prototype.trim != null)) {
    String.prototype.trim = function() {
      return this.replace(/^\s\s*/, '').replace(/\s\s*$/, '');
    };
  }

  getArgumentNames = function(fn) {
    var a, args, _i, _len, _results;
    if (fn == null) {
      fn = function() {};
    }
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

  runSeries = function(tasks, cb, force) {
    var checkEnd, count, errors, i, results, t, _i, _len, _results;
    if (tasks == null) {
      tasks = [];
    }
    if (cb == null) {
      cb = (function() {});
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
        next = function() {
          var err, res;
          err = arguments[0], res = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
          if (err != null) {
            errors[i] = err;
            results[i] = void 0;
          } else {
            results[i] = res.length < 2 ? res[0] : res;
          }
          return checkEnd();
        };
        try {
          return t(next);
        } catch (e) {
          if (force) {
            return next(e);
          }
        }
      })(t, i));
    }
    return _results;
  };

  runWaterfall = function(tasks, cb) {
    var i, next;
    i = -1;
    if (tasks.length === 0) {
      return cb();
    }
    next = function() {
      var err, res;
      err = arguments[0], res = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      if (err != null) {
        return cb(err);
      }
      if (++i === tasks.length) {
        return cb.apply(null, [null].concat(__slice.call(res)));
      } else {
        return tasks[i].apply(tasks, __slice.call(res).concat([next]));
      }
    };
    return next();
  };

  doForAll = function(args, fn, cb) {
    var a, tasks;
    if (args == null) {
      args = [];
    }
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
    runWaterfall: runWaterfall,
    clone: clone,
    getArgumentNames: getArgumentNames,
    uniqueId: uniqueId
  };

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
      if (typeof data === "object" && opt.publishReference !== true) {
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
      util.runSeries(tasks, (function(errors, results) {
        var e, x;
        if (errors) {
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
      }), true);
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

  VERSION = "0.3.9";

  checkType = function(type, val, name) {
    if (typeof val !== type) {
      throw new TypeError("" + name + " has to be a " + type);
    }
  };

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
    checkType("function", fn, "parameter");
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
    checkType("string", moduleId, "module ID");
    checkType("function", creator, "creator");
    checkType("object", opt, "option parameter");
    modObj = new creator();
    checkType("object", modObj, "the return value of the creator");
    checkType("function", modObj.init, "'init' of the module");
    checkType("function", modObj.destroy, "'destroy' of the module ");
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
    checkType("string", instanceId, "instance ID");
    checkType("object", opt, "option parameter");
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

  unregister = function(id, type) {
    if (type[id] != null) {
      delete type[id];
      return true;
    }
    return false;
  };

  unregisterAll = function(type) {
    var id, _results;
    _results = [];
    for (id in type) {
      _results.push(unregister(id, type));
    }
    return _results;
  };

  start = function(moduleId, opt) {
    var instance;
    if (opt == null) {
      opt = {};
    }
    try {
      checkType("string", moduleId, "module ID");
      checkType("object", opt, "second parameter");
      if (modules[moduleId] == null) {
        throw new Error("module doesn't exist");
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

  sandboxKeywords = ["core", "instanceId", "options", "publish", "emit", "on", "subscribe", "unsubscribe"];

  ls = function(o) {
    var id, m, _results;
    _results = [];
    for (id in o) {
      m = o[id];
      _results.push(id);
    }
    return _results;
  };

  registerPlugin = function(plugin) {
    var RESERVED_ERROR, k, v, _ref, _ref1;
    RESERVED_ERROR = new Error("plugin uses reserved keyword");
    try {
      checkType("object", plugin, "plugin");
      checkType("string", plugin.id, "'id' of plugin");
      if (typeof plugin.sandbox === "function") {
        for (k in new plugin.sandbox(new Sandbox(core, ''))) {
          if (__indexOf.call(sandboxKeywords, k) >= 0) {
            throw RESERVED_ERROR;
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
            throw RESERVED_ERROR;
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
    unregister: function(id) {
      return unregister(id, modules);
    },
    unregisterAll: function() {
      return unregisterAll(modules);
    },
    registerPlugin: registerPlugin,
    unregisterPlugin: function(id) {
      return unregister(id, plugins);
    },
    unregisterAllPlugins: function() {
      return unregisterAll(plugins);
    },
    setInstanceOptions: setInstanceOptions,
    start: start,
    stop: stop,
    startAll: startAll,
    stopAll: stopAll,
    uniqueId: util.uniqueId,
    lsInstances: function() {
      return ls(instances);
    },
    lsModules: function() {
      return ls(modules);
    },
    lsPlugins: function() {
      return ls(plugins);
    },
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

  coreKeywords = (function() {
    var _results;
    _results = [];
    for (k in core) {
      v = core[k];
      _results.push(k);
    }
    return _results;
  })();

  if ((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) {
    module.exports = core;
  }

  if ((typeof define !== "undefined" && define !== null ? define.amd : void 0) != null) {
    if ((typeof define !== "undefined" && define !== null ? define.amd : void 0) != null) {
      define(function() {
        return core;
      });
    }
  } else if (typeof window !== "undefined" && window !== null) {
    window.scaleApp = core;
  }

}).call(this);
