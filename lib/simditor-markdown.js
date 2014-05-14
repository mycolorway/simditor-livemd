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
      this.markdownConfigs = {
        ul: {
          key: {
            42: "*",
            43: "+",
            45: "-"
          },
          cmd: /^\*{1}$|^\+{1}$|^\-{1}$/,
          block: true,
          callback: (function(_this) {
            return function(e, hook, cmd, container) {
              var button;
              button = _this.editor.toolbar.findButton("ul");
              if (button === null) {
                return;
              }
              e.preventDefault();
              container.text("");
              return button.command("ul");
            };
          })(this)
        },
        ol: {
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
            return function(e, hook, cmd, container) {
              var button;
              button = _this.editor.toolbar.findButton("ol");
              if (button === null) {
                return;
              }
              e.preventDefault();
              container.text("");
              return button.command("ol");
            };
          })(this)
        },
        title: {
          key: {
            35: "#"
          },
          cmd: /^#+/,
          block: true,
          callback: (function(_this) {
            return function(e, hook, cmd, container) {
              var button, level;
              level = cmd.length > 3 ? 3 : cmd.length;
              button = _this.editor.toolbar.findButton("title");
              if (button === null) {
                return;
              }
              e.preventDefault();
              if (/^#+$/.test(cmd)) {
                container.html(cmd.replace(hook.cmd, "&nbsp;"));
                _this.editor.selection.setRangeAtStartOf(container);
              } else {
                container.text(cmd.replace(hook.cmd, ""));
                _this.editor.selection.setRangeAtEndOf(container);
              }
              return button.command("h" + level);
            };
          })(this)
        },
        blockquote: {
          key: {
            62: ">"
          },
          cmd: /^>{1}$/,
          block: true,
          callback: (function(_this) {
            return function(e, hook, cmd, container) {
              var button;
              button = _this.editor.toolbar.findButton("blockquote");
              if (button === null) {
                return;
              }
              e.preventDefault();
              button.command();
              container.html(cmd.replace(hook.cmd, "<br/>"));
              return _this.editor.selection.setRangeAtStartOf(container);
            };
          })(this)
        },
        code: {
          key: {
            96: "`"
          },
          cmd: /^`{3}$/,
          block: true,
          callback: (function(_this) {
            return function(e, hook, cmd, container) {
              var button;
              button = _this.editor.toolbar.findButton("code");
              if (button === null) {
                return;
              }
              e.preventDefault();
              container.text("");
              return button.command();
            };
          })(this)
        },
        hr: {
          key: {
            42: "*",
            45: "-"
          },
          cmd: /^\*{3,}$|^\-{3,}$/,
          block: true,
          callback: (function(_this) {
            return function(e, hook, cmd, container) {
              var button;
              button = _this.editor.toolbar.findButton("hr");
              if (button === null) {
                return;
              }
              e.preventDefault();
              container.html(cmd.replace(hook.cmd, "<br/>"));
              return button.command();
            };
          })(this)
        },
        italic: {
          key: {
            42: "*",
            95: "_"
          },
          cmd: /\*([^\*]+)\*$|_([^_]+)_$/,
          block: false,
          callback: (function(_this) {
            return function(e, hook, cmd, container) {
              var button, range;
              button = _this.editor.toolbar.findButton("italic");
              if (button === null) {
                return;
              }
              e.preventDefault();
              container.textContent = cmd.replace(hook.cmd, "$1$2");
              range = document.createRange();
              range.setStart(container, cmd.match(hook.cmd).index);
              range.setEnd(container, cmd.length - 2);
              _this.editor.selection.selectRange(range);
              if (button.status($(range.commonAncestorContainer.parentNode))) {
                return _this.editor.selection.setRangeAtEndOf(container);
              } else {
                button.command();
                _this.editor.selection.setRangeAtEndOf(container);
                return button.command();
              }
            };
          })(this)
        },
        bold: {
          key: {
            42: "*",
            95: "_"
          },
          cmd: /\*{2}([^\*]+)\*{2}$|_{2}([^_]+)_{2}$/,
          block: false,
          callback: (function(_this) {
            return function(e, hook, cmd, container) {
              var button, range;
              button = _this.editor.toolbar.findButton("bold");
              if (button === null) {
                return;
              }
              e.preventDefault();
              container.textContent = cmd.replace(hook.cmd, "$1$2");
              range = document.createRange();
              range.setStart(container, cmd.match(hook.cmd).index);
              range.setEnd(container, cmd.length - 4);
              _this.editor.selection.selectRange(range);
              if (button.status($(range.commonAncestorContainer.parentNode))) {
                return _this.editor.selection.setRangeAtEndOf(container);
              } else {
                button.command();
                _this.editor.selection.setRangeAtEndOf(container);
                return button.command();
              }
            };
          })(this)
        }
      };
    }

    SimditorMarkdown.prototype._init = function() {
      var button, config, _ref, _results;
      this.opts.markdown = this.opts.markdown || this.editor.textarea.data("markdown");
      if (!this.opts.markdown) {
        return;
      }
      this.editor.on("keypress", $.proxy(this._onKeyPress, this));
      _ref = this.markdownConfigs;
      _results = [];
      for (button in _ref) {
        config = _ref[button];
        _results.push(this.addInputHook(config));
      }
      return _results;
    };

    SimditorMarkdown.prototype._onKeyPress = function(e) {
      var cmd, container, hook, range, _i, _len, _ref, _results;
      if (e.which === 32) {
        range = this.editor.selection.getRange();
        container = range.commonAncestorContainer;
        cmd = container.textContent;
        _ref = this._inputHooks;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          hook = _ref[_i];
          if ((hook.cmd instanceof RegExp && hook.cmd.test(cmd)) || hook.cmd === cmd) {
            if (hook.block && !$(container.parentNode).is("p, div")) {
              break;
            }
            hook.callback(e, hook, cmd, container);
            break;
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      }
    };

    SimditorMarkdown.prototype._inputHooks = [];

    SimditorMarkdown.prototype._hookKeyMap = {};

    SimditorMarkdown.prototype.addInputHook = function(hookOpt) {
      $.extend(this._hookKeyMap, hookOpt.key);
      return this._inputHooks.push(hookOpt);
    };

    return SimditorMarkdown;

  })(Plugin);

  Simditor.connect(SimditorMarkdown);

}).call(this);
