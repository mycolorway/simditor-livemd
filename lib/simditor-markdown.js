(function() {
  var SimditorMarkdown,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  SimditorMarkdown = (function(_super) {
    __extends(SimditorMarkdown, _super);

    SimditorMarkdown.prototype.opts = {
      markdown: false
    };

    function SimditorMarkdown() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      SimditorMarkdown.__super__.constructor.apply(this, args);
      this.editor = this.widget;
    }

    SimditorMarkdown.prototype._init = function() {
      var toolbar;
      this.opts.markdown = this.opts.markdown || this.editor.textarea.data("markdown");
      if (!this.opts.markdown) {
        return;
      }
      this.editor.body.on("keypress", $.proxy(this._onKeyPress, this));
      toolbar = this.editor.toolbar.list;
      this.addInputHook({
        key: {
          42: "*",
          43: "+",
          45: "-"
        },
        cmd: /^\*{1}$|^\+{1}$|^\-{1}$/,
        block: true,
        callback: (function(_this) {
          return function() {
            var container;
            container = $(_this.editor.selection.getRange().commonAncestorContainer.parentNode);
            container.text("");
            return toolbar.find(".toolbar-item-ul").mousedown();
          };
        })(this)
      });
      this.addInputHook({
        key: {
          46: ".",
          48: "0",
          49: "1",
          50: "2",
          51: "3",
          52: "4",
          53: "5",
          54: "6",
          55: "7",
          56: "8",
          57: "9"
        },
        cmd: /^[0-9]\.{1}$/,
        block: true,
        callback: (function(_this) {
          return function() {
            var container;
            container = $(_this.editor.selection.getRange().commonAncestorContainer.parentNode);
            container.text("");
            return toolbar.find(".toolbar-item-ol").mousedown();
          };
        })(this)
      });
      this.addInputHook({
        key: {
          35: "#"
        },
        cmd: /^#+/,
        block: true,
        callback: (function(_this) {
          return function(e, hook, cmd) {
            var container, level;
            level = cmd.length > 3 ? 3 : cmd.length;
            toolbar.find(".toolbar-menu-title .menu-item-h" + level).click();
            container = $(_this.editor.selection.getRange().commonAncestorContainer.parentNode);
            if (/^#+$/.test(cmd)) {
              container.html(cmd.replace(hook.cmd, "&nbsp;"));
              return _this.editor.selection.setRangeAtStartOf(container);
            } else {
              container.text(cmd.replace(hook.cmd, ""));
              return _this.editor.selection.setRangeAtEndOf(container);
            }
          };
        })(this)
      });
      this.addInputHook({
        key: {
          62: ">"
        },
        cmd: /^>{1}$/,
        block: true,
        callback: (function(_this) {
          return function(e, hook, cmd) {
            var container;
            container = $(_this.editor.selection.getRange().commonAncestorContainer.parentNode);
            container.html(cmd.replace(hook.cmd, "<br/>"));
            toolbar.find(".toolbar-item-blockquote").mousedown();
            return _this.editor.selection.setRangeAtStartOf(container);
          };
        })(this)
      });
      this.addInputHook({
        key: {
          96: "`"
        },
        cmd: /^`{3}$/,
        block: true,
        callback: (function(_this) {
          return function(e, hook, cmd) {
            var container;
            container = $(_this.editor.selection.getRange().commonAncestorContainer.parentNode);
            container.text("");
            return toolbar.find(".toolbar-item-code").mousedown();
          };
        })(this)
      });
      return this.addInputHook({
        key: {
          96: "`"
        },
        cmd: /^\*{3,}$|^\-{3,}$/,
        block: true,
        callback: (function(_this) {
          return function(e, hook, cmd) {
            var container;
            container = $(_this.editor.selection.getRange().commonAncestorContainer.parentNode);
            container.html(cmd.replace(hook.cmd, "<br/>"));
            return toolbar.find(".toolbar-item-hr").mousedown();
          };
        })(this)
      });
    };

    SimditorMarkdown.prototype._onKeyPress = function(e) {
      var cmd, container, hook, _i, _len, _ref, _results;
      if (this.editor.triggerHandler(e) === false) {
        return false;
      }
      if (e.which === 13) {
        this._hookStack.length = 0;
      }
      if (e.which === 32) {
        cmd = this._hookStack.join("");
        this._hookStack.length = 0;
        _ref = this._inputHooks;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          hook = _ref[_i];
          if ((hook.cmd instanceof RegExp && hook.cmd.test(cmd)) || hook.cmd === cmd) {
            container = this.editor.selection.getRange().commonAncestorContainer;
            if (hook.block && (!$(container.parentNode).is("p, div") || !hook.cmd.test(container.textContent))) {
              break;
            }
            hook.callback(e, hook, cmd);
            e.preventDefault();
            break;
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      } else if (this._hookKeyMap[e.which]) {
        this._hookStack.push(this._hookKeyMap[e.which]);
        if (this._hookStack.length > 10) {
          return this._hookStack.shift();
        }
      }
    };

    SimditorMarkdown.prototype._inputHooks = [];

    SimditorMarkdown.prototype._hookKeyMap = {};

    SimditorMarkdown.prototype._hookStack = [];

    SimditorMarkdown.prototype.addInputHook = function(hookOpt) {
      $.extend(this._hookKeyMap, hookOpt.key);
      return this._inputHooks.push(hookOpt);
    };

    return SimditorMarkdown;

  })(Plugin);

  Simditor.connect(SimditorMarkdown);

}).call(this);
