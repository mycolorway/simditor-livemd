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
          cmd: /^\*{1}$|^\+{1}$|^\-{1}$/,
          block: true,
          callback: (function(_this) {
            return function(hook, cmd, container, button) {
              container.textContent = cmd.replace(hook.cmd, "");
              return button.command("ol");
            };
          })(this)
        },
        ol: {
          cmd: /^[0-9][\.\u3002]{1}$/,
          block: true,
          callback: (function(_this) {
            return function(hook, cmd, container, button) {
              container.textContent = cmd.replace(hook.cmd, "");
              return button.command("ol");
            };
          })(this)
        },
        title: {
          cmd: /^#+$/,
          block: true,
          callback: (function(_this) {
            return function(hook, cmd, container, button) {
              var level;
              level = cmd.length > 3 ? 3 : cmd.length;
              $(container.parentNode).html(cmd.replace(hook.cmd, "&nbsp;"));
              return button.command("h" + level);
            };
          })(this)
        },
        blockquote: {
          cmd: /^>{1}$/,
          block: true,
          callback: (function(_this) {
            return function(hook, cmd, container, button) {
              $(container.parentNode).html(cmd.replace(hook.cmd, "&nbsp;"));
              return button.command();
            };
          })(this)
        },
        code: {
          cmd: /^`{3}$/,
          block: true,
          callback: (function(_this) {
            return function(hook, cmd, container, button) {
              container.textContent = "";
              return button.command();
            };
          })(this)
        },
        hr: {
          cmd: /^\*{3,}$|^\-{3,}$/,
          block: true,
          callback: (function(_this) {
            return function(hook, cmd, container, button) {
              $(container.parentNode).html(cmd.replace(hook.cmd, "<br/>"));
              return button.command();
            };
          })(this)
        },
        italic: {
          cmd: /\*([^\*]+)\*$|_([^_]+)_$/,
          block: false,
          callback: (function(_this) {
            return function(hook, cmd, container, button) {
              var range;
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
          cmd: /\*{2}([^\*]+)\*{2}$|_{2}([^_]+)_{2}$/,
          block: false,
          callback: (function(_this) {
            return function(hook, cmd, container, button) {
              var range;
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
        },
        link: {
          cmd: /[^\!]\[(.+)\]\((.+)\)$|^\[(.+)\]\((.+)\)$|\<((.[^\[\]\(\)]+))\>$/,
          block: false,
          callback: (function(_this) {
            return function(hook, cmd, container, button) {
              var params, text, url;
              container.textContent = "";
              params = cmd.match(hook.cmd);
              text = params[1] || params[3] || params[5];
              url = params[2] || params[4] || params[6];
              return button.command(text, url);
            };
          })(this)
        },
        image: {
          cmd: /!\[(.+)\]\((.+)\)$/,
          block: false,
          callback: (function(_this) {
            return function(hook, cmd, container, button) {
              var params;
              container.textContent = "";
              params = cmd.match(hook.cmd);
              return button.command(params[2]);
            };
          })(this)
        }
      };
    }

    SimditorMarkdown.prototype._init = function() {
      this.opts.markdown = this.opts.markdown || this.editor.textarea.data("markdown");
      if (!this.opts.markdown) {
        return;
      }
      return this.editor.on("keypress", $.proxy(this._onKeyPress, this));
    };

    SimditorMarkdown.prototype._onKeyPress = function(e) {
      var button, cmd, container, hook, name, range, _ref;
      if (e.which === 32 || e.which === 13) {
        container = this.editor.selection.getRange().commonAncestorContainer;
        cmd = container.textContent;
        if (container.nodeName !== "#text") {
          return;
        }
        _ref = this.markdownConfigs;
        for (name in _ref) {
          hook = _ref[name];
          if (hook.cmd instanceof RegExp && hook.cmd.test(cmd.trim())) {
            range = document.createRange();
            range.setStart(container, 0);
            range.setEnd(container, 0);
            if (hook.block && !this.editor.selection.rangeAtStartOf(container.parentNode, range)) {
              break;
            }
            button = this.editor.toolbar.findButton(name);
            if (button === null || button.disabled) {
              return;
            }
            e.preventDefault();
            hook.callback(hook, cmd, container, button);
            break;
          }
        }
      }
    };

    return SimditorMarkdown;

  })(Plugin);

  Simditor.connect(SimditorMarkdown);

}).call(this);
