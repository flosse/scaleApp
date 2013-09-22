/*!
scaleapp - v0.4.0 - 2013-09-22
This program is distributed under the terms of the MIT license.
Copyright (c) 2011-2013 Markus Kohlhase <mail@markus-kohlhase.de>
*/
(function() {
  var Core, Mediator, api, checkType, doForAll, getArgumentNames, runParallel, runSeries, runWaterfall, util,
    __slice = [].slice;

  getArgumentNames = function(fn) {
    var a, args, _i, _len, _results;
    if (fn == null) {
      fn = function() {};
    }
    args = fn.toString().match(/function[^(]*\(([^)]*)\)/);
    if ((args == null) || (args.length < 2)) {
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
        var e, next;
        next = function() {
          var e, err, res;
          err = arguments[0], res = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
          if (err) {
            errors[i] = err;
            if (!force) {
              return cb(errors, results);
            }
          } else {
            results[i] = res.length < 2 ? res[0] : res;
          }
          if (--count <= 0) {
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
        } catch (_error) {
          e = _error;
          return next(e);
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
      if (err) {
        errors[i] = err;
        if (!force) {
          return cb(errors, results);
        }
      } else {
        if (i > -1) {
          results[i] = res.length < 2 ? res[0] : res;
        }
      }
      if (++i >= count) {
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
        } catch (_error) {
          e = _error;
          return next(e);
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
      if (++i >= tasks.length) {
        return cb.apply(null, [null].concat(__slice.call(res)));
      } else {
        return tasks[i].apply(tasks, __slice.call(res).concat([next]));
      }
    };
    return next();
  };

  doForAll = function(args, fn, cb, force) {
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
    return util.runParallel(tasks, cb, force);
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
      if (obj instanceof Object) {
        this.installTo(obj);
      } else if (obj === true) {
        this.cascadeChannels = true;
      }
    }

    Mediator.prototype.on = function(channel, fn, context) {
      var id, k, subscription, that, v, _base, _i, _len, _results, _results1;
      if (context == null) {
        context = this;
      }
      if ((_base = this.channels)[channel] == null) {
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
              var e;
              try {
                if (util.hasArgument(sub.callback, 3)) {
                  return sub.callback.apply(sub.context, [data, channel, next]);
                } else {
                  return next(null, sub.callback.apply(sub.context, [data, channel]));
                }
              } catch (_error) {
                e = _error;
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
          if (obj[k] == null) {
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
      return "" + name + " has to be a " + type;
    }
  };

  Core = (function() {
    function Core(Sandbox) {
      this.Sandbox = Sandbox;
      this._modules = {};
      this._plugins = [];
      this._instances = {};
      this._sandboxes = {};
      this._mediator = new Mediator;
      this.Mediator = Mediator;
      if (this.Sandbox == null) {
        this.Sandbox = function(core, instanceId, options) {
          this.instanceId = instanceId;
          this.options = options != null ? options : {};
          core._mediator.installTo(this);
          return this;
        };
      }
    }

    Core.prototype.log = {
      error: function() {},
      log: function() {},
      info: function() {},
      warn: function() {},
      enable: function() {}
    };

    Core.prototype.register = function(moduleId, creator, opt) {
      var err;
      if (opt == null) {
        opt = {};
      }
      err = checkType("string", moduleId, "module ID") || checkType("function", creator, "creator") || checkType("object", opt, "option parameter");
      if (err) {
        this.log.error("could not register module '" + moduleId + "': " + err);
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

    Core.prototype.start = function(moduleId, opt, cb) {
      var e, id, initInst, _ref,
        _this = this;
      if (opt == null) {
        opt = {};
      }
      if (cb == null) {
        cb = function() {};
      }
      if (arguments.length === 0) {
        return this._startAll();
      }
      if (moduleId instanceof Array) {
        return this._startAll(moduleId, opt);
      }
      if (typeof moduleId === "function") {
        return this._startAll(null, moduleId);
      }
      if (typeof opt === "function") {
        cb = opt;
        opt = {};
      }
      e = checkType("string", moduleId, "module ID") || checkType("object", opt, "second parameter") || (!this._modules[moduleId] ? "module doesn't exist" : void 0);
      if (e) {
        return this._startFail(e, cb);
      }
      id = opt.instanceId || moduleId;
      if (((_ref = this._instances[id]) != null ? _ref.running : void 0) === true) {
        return this._startFail(new Error("module was already started"), cb);
      }
      initInst = function(err, instance) {
        if (err) {
          return _this._startFail(err, cb);
        }
        try {
          if (util.hasArgument(instance.init, 2)) {
            return instance.init(instance.options, function(err) {
              if (!err) {
                instance.running = true;
              }
              return cb(err);
            });
          } else {
            instance.init(instance.options);
            instance.running = true;
            return cb();
          }
        } catch (_error) {
          e = _error;
          return _this._startFail(e, cb);
        }
      };
      return this.boot(function(err) {
        if (err) {
          return _this._startFail(err, cb);
        }
        return _this._createInstance(moduleId, opt.instanceId, opt.options, initInst);
      });
    };

    Core.prototype._startFail = function(e, cb) {
      this.log.error(e);
      cb(new Error("could not start module: " + e.message));
      return this;
    };

    Core.prototype._createInstance = function(moduleId, instanceId, opt, cb) {
      var iOpts, key, module, o, sb, val, _i, _len, _ref,
        _this = this;
      if (instanceId == null) {
        instanceId = moduleId;
      }
      module = this._modules[moduleId];
      if (this._instances[instanceId]) {
        return cb(this._instances[instanceId]);
      }
      iOpts = {};
      _ref = [module.options, opt];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        o = _ref[_i];
        if (o) {
          for (key in o) {
            val = o[key];
            if (iOpts[key] == null) {
              iOpts[key] = val;
            }
          }
        }
      }
      sb = new this.Sandbox(this, instanceId, iOpts);
      sb.moduleId = moduleId;
      return this._runSandboxPlugins('init', sb, function(err) {
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

    Core.prototype._runSandboxPlugins = function(ev, sb, cb) {
      var p, tasks;
      tasks = (function() {
        var _i, _len, _ref, _ref1, _results;
        _ref = this._plugins;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          p = _ref[_i];
          if (typeof ((_ref1 = p.plugin) != null ? _ref1[ev] : void 0) === "function") {
            _results.push((function(p) {
              var fn;
              fn = p.plugin[ev];
              return function(next) {
                if (util.hasArgument(fn, 3)) {
                  return fn(sb, p.options, next);
                } else {
                  fn(sb, p.options);
                  return next();
                }
              };
            })(p));
          }
        }
        return _results;
      }).call(this);
      return util.runSeries(tasks, cb, true);
    };

    Core.prototype._startAll = function(mods, cb) {
      var done, m, startAction,
        _this = this;
      if (mods == null) {
        mods = (function() {
          var _results;
          _results = [];
          for (m in this._modules) {
            _results.push(m);
          }
          return _results;
        }).call(this);
      }
      startAction = function(m, next) {
        return _this.start(m, _this._modules[m].options, next);
      };
      done = function(err) {
        var e, i, mdls, x;
        if ((err != null ? err.length : void 0) > 0) {
          mdls = (function() {
            var _i, _len, _results;
            _results = [];
            for (i = _i = 0, _len = err.length; _i < _len; i = ++_i) {
              x = err[i];
              if (x != null) {
                _results.push("'" + mods[i] + "'");
              }
            }
            return _results;
          })();
          e = new Error("errors occoured in the following modules: " + mdls);
        }
        return typeof cb === "function" ? cb(e) : void 0;
      };
      util.doForAll(mods, startAction, done, true);
      return this;
    };

    Core.prototype.stop = function(id, cb) {
      var instance, x,
        _this = this;
      if (cb == null) {
        cb = function() {};
      }
      if (arguments.length === 0 || typeof id === "function") {
        util.doForAll((function() {
          var _results;
          _results = [];
          for (x in this._instances) {
            _results.push(x);
          }
          return _results;
        }).call(this), (function() {
          return _this.stop.apply(_this, arguments);
        }), id, true);
      } else if (instance = this._instances[id]) {
        delete this._instances[id];
        this._mediator.off(instance);
        this._runSandboxPlugins('destroy', this._sandboxes[id], function(err) {
          if (util.hasArgument(instance.destroy)) {
            return instance.destroy(function(err) {
              if (err) {
                this._instances[id] = instance;
              }
              return cb(err);
            });
          } else {
            if (typeof instance.destroy === "function") {
              instance.destroy();
            }
            return cb();
          }
        });
      }
      return this;
    };

    Core.prototype.use = function(plugin, opt) {
      var p, _i, _len;
      if (plugin instanceof Array) {
        for (_i = 0, _len = plugin.length; _i < _len; _i++) {
          p = plugin[_i];
          switch (typeof p) {
            case "function":
              this.use(p);
              break;
            case "object":
              this.use(p.plugin, p.options);
          }
        }
      } else {
        if (typeof plugin !== "function") {
          return this;
        }
        this._plugins.push({
          creator: plugin,
          options: opt
        });
      }
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
    if (window.scaleApp == null) {
      window.scaleApp = api;
    }
  } else if ((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) {
    module.exports = api;
  }

}).call(this);
