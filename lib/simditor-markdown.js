(function() {
  var SimditorMarkdown,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
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
      this._format = __bind(this._format, this);
      SimditorMarkdown.__super__.constructor.apply(this, args);
      this.editor = this.widget;
      this.markdownConfigs = {
        title: {
          cmd: /^#+/,
          block: true,
          callback: (function(_this) {
            return function(hook, range, offset) {
              var button, container, length, level;
              button = _this.editor.toolbar.findButton("title");
              if (button === null || button.disabled) {
                return;
              }
              container = range.commonAncestorContainer;
              length = container.textContent.match(hook.cmd)[0].length;
              level = length > 3 ? 3 : length;
              container.textContent = container.textContent.replace(hook.cmd, "");
              _this._format(container);
              if (offset > length) {
                range.setStart(container, offset - length);
                _this.editor.selection.selectRange(range);
              }
              return button.command("h" + level);
            };
          })(this)
        },
        blockquote: {
          cmd: /^>{1}/,
          block: true,
          callback: (function(_this) {
            return function(hook, range, offset) {
              var button, container;
              button = _this.editor.toolbar.findButton("blockquote");
              if (button === null || button.disabled) {
                return;
              }
              container = range.commonAncestorContainer;
              container.textContent = container.textContent.replace(hook.cmd, "");
              _this._format(container);
              if (offset > 1) {
                range.setStart(container, offset - 1);
                _this.editor.selection.selectRange(range);
              }
              return button.command();
            };
          })(this)
        },
        code: {
          cmd: /^`{3}/,
          block: true,
          callback: (function(_this) {
            return function(hook, range, offset) {
              var button, container;
              button = _this.editor.toolbar.findButton("code");
              if (button === null || button.disabled) {
                return;
              }
              container = range.commonAncestorContainer;
              container.textContent = container.textContent.replace(hook.cmd, "");
              _this._format(container);
              return setTimeout(function() {
                range.setStart(container, offset - 3);
                _this.editor.selection.selectRange(range);
                return button.command();
              }, 5);
            };
          })(this)
        },
        hr: {
          cmd: /^\*{3,}$|^\-{3,}$/,
          block: true,
          callback: (function(_this) {
            return function(hook, range, offset) {
              var button, container, content;
              button = _this.editor.toolbar.findButton("hr");
              if (button === null || button.disabled) {
                return;
              }
              container = range.commonAncestorContainer;
              content = container.textContent;
              container.textContent = container.textContent.replace(hook.cmd, "");
              _this._format(container);
              return button.command();
            };
          })(this)
        },
        bold: {
          cmd: /\*{2}([^\*]+)\*{2}$|_{2}([^_]+)_{2}$/,
          block: false,
          callback: (function(_this) {
            return function(hook, range, offset) {
              var button, container, content;
              button = _this.editor.toolbar.findButton("bold");
              if (button === null || button.disabled) {
                return;
              }
              container = range.commonAncestorContainer;
              content = container.textContent;
              container.textContent = content.replace(hook.cmd, "$1$2");
              range = document.createRange();
              range.setStart(container, content.match(hook.cmd).index);
              range.setEnd(container, content.length - 4);
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
        italic: {
          cmd: /\*([^\*]+)\*$|_([^_]+)_$/,
          block: false,
          callback: (function(_this) {
            return function(hook, range, offset) {
              var button, container, content;
              button = _this.editor.toolbar.findButton("italic");
              if (button === null || button.disabled) {
                return;
              }
              container = range.commonAncestorContainer;
              content = container.textContent;
              container.textContent = content.replace(hook.cmd, "$1$2");
              range = document.createRange();
              range.setStart(container, content.match(hook.cmd).index);
              range.setEnd(container, content.length - 2);
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
        ul: {
          cmd: /^\*{1}|^\+{1}|^\-{1}/,
          block: true,
          callback: (function(_this) {
            return function(hook, range, offset) {
              var button, container;
              button = _this.editor.toolbar.findButton("ul");
              if (button === null || button.disabled) {
                return;
              }
              container = range.commonAncestorContainer;
              container.textContent = container.textContent.replace(hook.cmd, "");
              _this._format(container);
              if (offset > 1) {
                range.setStart(container, offset - 1);
                _this.editor.selection.selectRange(range);
              }
              return button.command();
            };
          })(this)
        },
        ol: {
          cmd: /^[0-9][\.\u3002]{1}/,
          block: true,
          callback: (function(_this) {
            return function(hook, range, offset) {
              var button, container;
              button = _this.editor.toolbar.findButton("ol");
              if (button === null || button.disabled) {
                return;
              }
              container = range.commonAncestorContainer;
              container.textContent = container.textContent.replace(hook.cmd, "");
              _this._format(container);
              if (offset > 2) {
                range.setStart(container, offset - 2);
                _this.editor.selection.selectRange(range);
              }
              return button.command();
            };
          })(this)
        },
        image: {
          cmd: /!\[(.+)\]\((.+)\)$/,
          block: false,
          callback: (function(_this) {
            return function(hook, range) {
              var button, container, content, params;
              button = _this.editor.toolbar.findButton("image");
              if (button === null || button.disabled) {
                return;
              }
              container = range.commonAncestorContainer;
              content = container.textContent;
              container.textContent = container.textContent.replace(hook.cmd, "");
              _this.editor.selection.setRangeAtEndOf(container);
              params = content.match(hook.cmd);
              return button.command(params[2]);
            };
          })(this)
        },
        link: {
          cmd: /\[(.+)\]\((.+)\)$|\<((.[^\[\]\(\)]+))\>$/,
          block: false,
          callback: (function(_this) {
            return function(hook, range) {
              var button, container, content, params, text, url;
              button = _this.editor.toolbar.findButton("link");
              if (button === null || button.disabled) {
                return;
              }
              container = range.commonAncestorContainer;
              content = container.textContent;
              container.textContent = container.textContent.replace(hook.cmd, "");
              params = content.match(hook.cmd);
              text = params[1] || params[3];
              url = params[2] || params[4];
              if (params.index > 0) {
                range.setStart(container, params.index);
                _this.editor.selection.selectRange(range);
              }
              return button.command(text, url);
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
      var button, container, content, hook, newRange, range, _ref, _results;
      if (e.which === 32 || e.which === 13) {
        range = this.editor.selection.getRange();
        container = range != null ? range.commonAncestorContainer : void 0;
        if (!(range && container && container.nodeType === 3)) {
          return;
        }
        content = container.textContent;
        _ref = this.markdownConfigs;
        _results = [];
        for (button in _ref) {
          hook = _ref[button];
          if (hook.cmd instanceof RegExp && hook.cmd.test(content)) {
            newRange = document.createRange();
            newRange.setStart(container, 0);
            newRange.setEnd(container, 0);
            if (hook.block && !this.editor.selection.rangeAtStartOf(container.parentNode, newRange)) {
              continue;
            }
            if (e.which === 32) {
              e.preventDefault();
            }
            hook.callback(hook, range, range.startOffset);
            break;
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      }
    };

    SimditorMarkdown.prototype._format = function(container) {
      var $el;
      $el = $(container.parentNode);
      if ($el.is(":empty")) {
        return this.editor.selection.setRangeAtStartOf($("<br/>").appendTo($el));
      }
    };

    return SimditorMarkdown;

  })(Plugin);

  Simditor.connect(SimditorMarkdown);

}).call(this);
