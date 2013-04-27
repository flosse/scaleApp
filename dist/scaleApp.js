
/*
scaleapp - v0.4.0 - 2013-04-27
This program is distributed under the terms of the MIT license.
Copyright (c) 2011-2013  Markus Kohlhase <mail@markus-kohlhase.de>
*/


(function() {
  var Core, Mediator, Sandbox, addModule, base, checkType, clone, createInstance, doForAll, getArgumentNames, getInstanceOptions, ls, onModuleState, plugins, register, registerPlugin, runSeries, runWaterfall, setInstanceOptions, start, startAll, stop, stopAll, uniqueId, unregister, unregisterAll, util,
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

    Mediator.prototype.on = function(channel, fn, context) {
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
          _results.push(this.on(id, fn, context));
        }
        return _results;
      } else if (typeof channel === "object") {
        _results1 = [];
        for (k in channel) {
          v = channel[k];
          _results1.push(this.on(k, v, fn));
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

    Mediator.prototype.off = function(ch, cb) {
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

    Mediator.prototype.emit = function(channel, data, cb) {
      var chnls, sub, subscribers, tasks;
      if (cb == null) {
        cb = function() {};
      }
      if (typeof data === "function") {
        cb = data;
        data = void 0;
      }
      if (typeof channel !== "string") {
        return false;
      }
      subscribers = this.channels[channel] || [];
      tasks = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = subscribers.length; _i < _len; _i++) {
          sub = subscribers[_i];
          _results.push((function(sub) {
            return function(next) {
              try {
                if ((util.getArgumentNames(sub.callback)).length >= 3) {
                  return sub.callback.apply(sub.context, [data, channel, next]);
                } else {
                  return next(null, sub.callback.apply(sub.context, [data, channel]));
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
        return cb(e);
      }), true);
      if (this.cascadeChannels && (chnls = channel.split('/')).length > 1) {
        this.emit(chnls.slice(0, -1).join('/'), data, cb);
      }
      return this;
    };

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
      if (o.channels[ch] == null) {
        return;
      }
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

  checkType = function(type, val, name) {
    if (typeof val !== type) {
      throw new TypeError("" + name + " has to be a " + type);
    }
  };

  plugins = {};

  onModuleState = function(state, fn, moduleId) {
    if (moduleId == null) {
      moduleId = '_always';
    }
    checkType("function", fn, "parameter");
    return this.moduleStates.on("" + state + "/" + moduleId, fn, this);
  };

  getInstanceOptions = function(instanceId, module, opt) {
    var io, key, o, val, _ref;
    o = {};
    _ref = module.options;
    for (key in _ref) {
      val = _ref[key];
      o[key] = val;
    }
    io = this.instanceOpts[instanceId];
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
    var cb, ev, i, iOpts, instance, k, module, n, p, plugin, sb, v, _i, _len, _ref, _ref1;
    if (instanceId == null) {
      instanceId = moduleId;
    }
    module = this.modules[moduleId];
    if (this.instances[instanceId] != null) {
      return this.instances[instanceId];
    }
    iOpts = getInstanceOptions.apply(this, [instanceId, module, opt]);
    sb = new Sandbox(this, instanceId, iOpts);
    this.mediator.installTo(sb);
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
      if (typeof p.on === "object") {
        _ref = p.on;
        for (ev in _ref) {
          cb = _ref[ev];
          if (typeof cb === "function") {
            this.onModuleState(ev, cb);
          }
        }
      }
    }
    instance = new module.creator(sb);
    instance.options = iOpts;
    instance.id = instanceId;
    this.instances[instanceId] = instance;
    _ref1 = [instanceId, '_always'];
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      n = _ref1[_i];
      this.moduleStates.emit("instantiate/" + n);
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
    if (this.modules[moduleId] != null) {
      throw new TypeError("module " + moduleId + " was already registered");
    }
    this.modules[moduleId] = {
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
      return addModule.apply(this, [moduleId, creator, opt]);
    } catch (e) {
      console.error("could not register module '" + moduleId + "': " + e.message);
      return false;
    }
  };

  setInstanceOptions = function(instanceId, opt) {
    var k, v, _base, _ref, _results;
    checkType("string", instanceId, "instance ID");
    checkType("object", opt, "option parameter");
    if ((_ref = (_base = this.instanceOpts)[instanceId]) == null) {
      _base[instanceId] = {};
    }
    _results = [];
    for (k in opt) {
      v = opt[k];
      _results.push(this.instanceOpts[instanceId][k] = v);
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
    var cb, instance;
    if (opt == null) {
      opt = {};
    }
    if (typeof opt === "function") {
      cb = opt;
      opt = {
        callback: cb
      };
    }
    try {
      checkType("string", moduleId, "module ID");
      checkType("object", opt, "second parameter");
      if (this.modules[moduleId] == null) {
        throw new Error("module doesn't exist");
      }
      instance = createInstance.apply(this, [moduleId, opt.instanceId, opt.options]);
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
      console.error(e);
      if (typeof opt.callback === "function") {
        opt.callback(new Error("could not start module: " + e.message));
      }
      return false;
    }
  };

  stop = function(id, cb) {
    var instance, n, _i, _len, _ref;
    if (instance = this.instances[id]) {
      this.mediator.off(instance);
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
      _ref = [id, '_always'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        n = _ref[_i];
        this.moduleStates.off("instantiate/" + n);
        this.moduleStates.emit("destroy/" + n);
      }
      delete this.instances[id];
      return true;
    } else {
      return false;
    }
  };

  startAll = function(cb, opt) {
    var id, invalid, invalidErr, mods, startAction, valid, _ref,
      _this = this;
    if (cb instanceof Array) {
      mods = cb;
      cb = opt;
      opt = null;
      valid = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = mods.length; _i < _len; _i++) {
          id = mods[_i];
          if (this.modules[id] != null) {
            _results.push(id);
          }
        }
        return _results;
      }).call(this);
    } else {
      mods = valid = (function() {
        var _results;
        _results = [];
        for (id in this.modules) {
          _results.push(id);
        }
        return _results;
      }).call(this);
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
      modOpts = _this.modules[m].options;
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
      return _this.start(m, o);
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
    var id,
      _this = this;
    return util.doForAll((function() {
      var _results;
      _results = [];
      for (id in this.instances) {
        _results.push(id);
      }
      return _results;
    }).call(this), (function() {
      return stop.apply(_this, arguments);
    }), cb);
  };

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
    var k, v, _base, _base1, _base2, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7;
    try {
      checkType("object", plugin, "plugin");
      checkType("string", plugin.id, "'id' of plugin");
      if (typeof plugin.sandbox === "function") {
        _ref = plugin.sandbox.prototype;
        for (k in _ref) {
          v = _ref[k];
          if ((_ref1 = (_base = Sandbox.prototype)[k]) == null) {
            _base[k] = v;
          }
        }
      }
      if (typeof plugin.core === "function") {
        _ref2 = plugin.core.prototype;
        for (k in _ref2) {
          v = _ref2[k];
          if ((_ref3 = (_base1 = Core.prototype)[k]) == null) {
            _base1[k] = v;
          }
        }
      }
      if (typeof plugin.core === "object") {
        _ref4 = plugin.core;
        for (k in _ref4) {
          v = _ref4[k];
          if ((_ref5 = (_base2 = Core.prototype)[k]) == null) {
            _base2[k] = v;
          }
        }
      }
      if (typeof plugin.base === "object") {
        _ref6 = plugin.base;
        for (k in _ref6) {
          v = _ref6[k];
          if ((_ref7 = base[k]) == null) {
            base[k] = v;
          }
        }
      }
      plugins[plugin.id] = plugin;
      return true;
    } catch (e) {
      console.error(e);
      return false;
    }
  };

  Core = (function() {

    function Core() {
      var core, id, k, p, v, _ref;
      this.modules = {};
      this.instances = {};
      this.instanceOpts = {};
      this.mediator = new Mediator;
      this.moduleStates = new Mediator;
      for (id in plugins) {
        p = plugins[id];
        if (p.core) {
          if (typeof p.core === "function") {
            core = new p.core();
            for (k in core) {
              if (!__hasProp.call(core, k)) continue;
              v = core[k];
              if ((_ref = this[k]) == null) {
                this[k] = v;
              }
            }
          }
        }
      }
    }

    Core.prototype.register = function() {
      return register.apply(this, arguments);
    };

    Core.prototype.lsInstances = function() {
      return ls(this.instances);
    };

    Core.prototype.lsModules = function() {
      return ls(this.modules);
    };

    Core.prototype.start = function() {
      return start.apply(this, arguments);
    };

    Core.prototype.startAll = function() {
      return startAll.apply(this, arguments);
    };

    Core.prototype.stop = function() {
      return stop.apply(this, arguments);
    };

    Core.prototype.stopAll = function() {
      return stopAll.apply(this, arguments);
    };

    Core.prototype.on = function() {
      return this.mediator.on.apply(this.mediator, arguments);
    };

    Core.prototype.off = function() {
      return this.mediator.off.apply(this.mediator, arguments);
    };

    Core.prototype.emit = function() {
      return this.mediator.emit.apply(this.mediator, arguments);
    };

    Core.prototype.unregisterAll = function() {
      return unregisterAll(this.modules);
    };

    Core.prototype.unregister = function(id) {
      return unregister(id, this.modules);
    };

    Core.prototype.onModuleState = function() {
      return onModuleState.apply(this, arguments);
    };

    Core.prototype.setInstanceOptions = function() {
      return setInstanceOptions.apply(this, arguments);
    };

    return Core;

  })();

  base = {
    VERSION: "0.4.0",
    plugin: {
      register: registerPlugin,
      ls: function() {
        return ls(plugins);
      }
    },
    util: util,
    Mediator: Mediator,
    Sandbox: Sandbox,
    Core: Core
  };

  if ((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) {
    module.exports = base;
  }

  if ((typeof define !== "undefined" && define !== null ? define.amd : void 0) != null) {
    if ((typeof define !== "undefined" && define !== null ? define.amd : void 0) != null) {
      define(function() {
        return base;
      });
    }
  } else if (typeof window !== "undefined" && window !== null) {
    window.scaleApp = base;
  }

}).call(this);
