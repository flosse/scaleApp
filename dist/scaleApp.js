
/*
scaleapp - v0.4.0 - 2013-05-22
This program is distributed under the terms of the MIT license.
Copyright (c) 2011-2013  Markus Kohlhase <mail@markus-kohlhase.de>
*/


(function() {
  var Core, Mediator, api, checkType, createInstance, doForAll, getArgumentNames, runParallel, runSandboxPlugins, runSeries, runWaterfall, util, _ref,
    __slice = [].slice,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

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

  runParallel = function(tasks, cb, force) {
    var count, errors, i, results, t, _i, _len, _results;
    if (tasks == null) {
      tasks = [];
    }
    if (cb == null) {
      cb = (function() {});
    }
    count = tasks.length;
    results = [];
    if (count === 0) {
      return cb(null, results);
    }
    errors = [];
    _results = [];
    for (i = _i = 0, _len = tasks.length; _i < _len; i = ++_i) {
      t = tasks[i];
      _results.push((function(t, i) {
        var next;
        next = function() {
          var e, err, res;
          err = arguments[0], res = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
          if (err != null) {
            errors[i] = err;
          } else {
            results[i] = res.length < 2 ? res[0] : res;
          }
          if (--count === 0) {
            if (((function() {
              var _j, _len1, _results1;
              _results1 = [];
              for (_j = 0, _len1 = errors.length; _j < _len1; _j++) {
                e = errors[_j];
                if (e != null) {
                  _results1.push(e);
                }
              }
              return _results1;
            })()).length > 0) {
              return cb(errors, results);
            } else {
              return cb(null, results);
            }
          }
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

  runSeries = function(tasks, cb, force) {
    var count, errors, i, next, results;
    if (tasks == null) {
      tasks = [];
    }
    if (cb == null) {
      cb = (function() {});
    }
    i = -1;
    count = tasks.length;
    results = [];
    if (count === 0) {
      return cb(null, results);
    }
    errors = [];
    next = function() {
      var e, err, res;
      err = arguments[0], res = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      if (err != null) {
        errors[i] = err;
      } else {
        results[i] = res.length < 2 ? res[0] : res;
      }
      if (++i === count) {
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
      } else {
        try {
          return tasks[i](next);
        } catch (e) {
          if (force) {
            return next(e);
          }
        }
      }
    };
    return next();
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
    return util.runParallel(tasks, cb);
  };

  util = {
    doForAll: doForAll,
    runParallel: runParallel,
    runSeries: runSeries,
    runWaterfall: runWaterfall,
    getArgumentNames: getArgumentNames,
    hasArgument: function(fn, idx) {
      if (idx == null) {
        idx = 1;
      }
      return util.getArgumentNames(fn).length >= idx;
    }
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
                if (util.hasArgument(sub.callback, 3)) {
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
      var k, v, _ref;
      if (typeof obj === "object") {
        for (k in this) {
          v = this[k];
          if ((_ref = obj[k]) == null) {
            obj[k] = v;
          }
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

  checkType = function(type, val, name) {
    if (typeof val !== type) {
      throw new TypeError("" + name + " has to be a " + type);
    }
  };

  runSandboxPlugins = function(ev, sb, cb) {
    var p, tasks;
    tasks = (function() {
      var _i, _len, _ref, _ref1, _results;
      _ref = this._plugins;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        p = _ref[_i];
        if (typeof ((_ref1 = p.plugin) != null ? _ref1[ev] : void 0) === "function") {
          _results.push((function(p) {
            var x;
            x = p.plugin[ev];
            if (util.hasArgument(x, 3)) {
              return function(next) {
                return x(sb, p.options, next);
              };
            } else {
              return function(next) {
                x(sb, p.options);
                return next();
              };
            }
          })(p));
        }
      }
      return _results;
    }).call(this);
    return util.runSeries(tasks, cb, true);
  };

  createInstance = function(moduleId, instanceId, opt, cb) {
    var iOpts, key, module, o, sb, val, _i, _len, _ref, _ref1,
      _this = this;
    if (instanceId == null) {
      instanceId = moduleId;
    }
    module = this._modules[moduleId];
    if (this._instances[instanceId] != null) {
      return cb(this._instances[instanceId]);
    }
    iOpts = {};
    _ref = [module.options, opt];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      o = _ref[_i];
      if (o) {
        for (key in o) {
          val = o[key];
          iOpts[key] = val;
        }
      }
    }
    sb = new this.Sandbox(this, instanceId, iOpts);
    if ((_ref1 = sb.moduleId) == null) {
      sb.moduleId = moduleId;
    }
    this._mediator.installTo(sb);
    return runSandboxPlugins.call(this, 'init', sb, function(err) {
      var instance;
      instance = new module.creator(sb);
      if (typeof instance.init !== "function") {
        return cb(new Error("module has no 'init' method"));
      }
      instance.options = iOpts;
      instance.id = instanceId;
      _this._instances[instanceId] = instance;
      _this._sandboxes[instanceId] = sb;
      return cb(null, instance);
    });
  };

  Core = (function() {

    function Core() {
      this._modules = {};
      this._plugins = [];
      this._instances = {};
      this._sandboxes = {};
      this._mediator = new Mediator;
      this.Sandbox = function(core, instanceId, options) {
        this.core = core;
        this.instanceId = instanceId;
        this.options = options != null ? options : {};
      };
      this.Mediator = Mediator;
    }

    Core.prototype.log = {
      error: function() {},
      log: function() {},
      info: function() {},
      warn: function() {},
      enable: function() {}
    };

    Core.prototype.register = function(moduleId, creator, opt) {
      if (opt == null) {
        opt = {};
      }
      try {
        checkType("string", moduleId, "module ID");
        checkType("function", creator, "creator");
        checkType("object", opt, "option parameter");
      } catch (e) {
        this.log.error("could not register module '" + moduleId + "': " + e.message);
        return this;
      }
      if (this._modules[moduleId] != null) {
        this.log.warn("module " + moduleId + " was already registered");
        return this;
      }
      this._modules[moduleId] = {
        creator: creator,
        options: opt,
        id: moduleId
      };
      return this;
    };

    Core.prototype.start = function(moduleId, opt, done) {
      var callback, cb, id, _ref,
        _this = this;
      if (opt == null) {
        opt = {};
      }
      if (done == null) {
        done = function() {};
      }
      if (typeof opt === "function") {
        callback = opt;
        opt = {
          callback: callback
        };
      }
      cb = function(err) {
        if (typeof opt.callback === "function") {
          opt.callback(err);
        }
        return done(err);
      };
      try {
        checkType("string", moduleId, "module ID");
        checkType("object", opt, "second parameter");
        if (this._modules[moduleId] == null) {
          throw new Error("module doesn't exist");
        }
        id = opt.instanceId || moduleId;
        if (((_ref = this._instances[id]) != null ? _ref.running : void 0) === true) {
          throw new Error("module was already started");
        }
        this.boot(function() {
          return createInstance.call(_this, moduleId, opt.instanceId, opt.options, function(err, instance) {
            if (err) {
              _this.log.error(err);
              return cb(err);
            }
            if (util.hasArgument(instance.init, 2)) {
              return instance.init(instance.options, function(err) {
                instance.running = true;
                return cb(err);
              });
            } else {
              instance.init(instance.options);
              cb(null);
              return instance.running = true;
            }
          });
        });
        return true;
      } catch (e) {
        this.log.error(e);
        cb(new Error("could not start module: " + e.message));
        return this;
      }
    };

    Core.prototype.startAll = function(cb, opt) {
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
            if (this._modules[id] != null) {
              _results.push(id);
            }
          }
          return _results;
        }).call(this);
      } else {
        mods = valid = (function() {
          var _results;
          _results = [];
          for (id in this._modules) {
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
        return _this.start(m, _this._modules[m].options, function(err) {
          return next(err);
        });
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

    Core.prototype.stop = function(id, cb) {
      var instance,
        _this = this;
      if (instance = this._instances[id]) {
        this._mediator.off(instance);
        runSandboxPlugins.call(this, 'destroy', this._sandboxes[id], function(err) {
          if (util.hasArgument(instance.destroy)) {
            instance.destroy(function(err) {
              return typeof cb === "function" ? cb(err) : void 0;
            });
          } else {
            instance.destroy();
            if (typeof cb === "function") {
              cb(null);
            }
          }
          return delete _this._instances[id];
        });
      }
      return this;
    };

    Core.prototype.stopAll = function(cb) {
      var id,
        _this = this;
      util.doForAll((function() {
        var _results;
        _results = [];
        for (id in this._instances) {
          _results.push(id);
        }
        return _results;
      }).call(this), (function() {
        return _this.stop.apply(_this, arguments);
      }), cb);
      return this;
    };

    Core.prototype.use = function(plugin, opt) {
      if (typeof plugin !== "function") {
        return this;
      }
      this._plugins.push({
        creator: plugin,
        options: opt
      });
      return this;
    };

    Core.prototype.boot = function(cb) {
      var core, p, tasks;
      core = this;
      tasks = (function() {
        var _i, _len, _ref, _results;
        _ref = this._plugins;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          p = _ref[_i];
          if (p.booted !== true) {
            _results.push((function(p) {
              if (util.hasArgument(p.creator, 3)) {
                return function(next) {
                  var plugin;
                  return plugin = p.creator(core, p.options, function(err) {
                    if (!err) {
                      p.booted = true;
                      p.plugin = plugin;
                    }
                    return next();
                  });
                };
              } else {
                return function(next) {
                  p.plugin = p.creator(core, p.options);
                  p.booted = true;
                  return next();
                };
              }
            })(p));
          }
        }
        return _results;
      }).call(this);
      util.runSeries(tasks, cb, true);
      return this;
    };

    Core.prototype.on = function() {
      return this._mediator.on.apply(this._mediator, arguments);
    };

    Core.prototype.off = function() {
      return this._mediator.off.apply(this._mediator, arguments);
    };

    Core.prototype.emit = function() {
      return this._mediator.emit.apply(this._mediator, arguments);
    };

    return Core;

  })();

  api = {
    VERSION: "0.4.0",
    util: util,
    Mediator: Mediator,
    Core: Core,
    plugins: {},
    modules: {}
  };

  if ((typeof define !== "undefined" && define !== null ? define.amd : void 0) != null) {
    define(function() {
      return api;
    });
  } else if (typeof window !== "undefined" && window !== null) {
    if ((_ref = window.scaleApp) == null) {
      window.scaleApp = api;
    }
  } else if ((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) {
    module.exports = api;
  }

}).call(this);
