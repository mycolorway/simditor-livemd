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
      return this.addInputHook({
        key: {
          42: "*"
        },
        cmd: /^\*/,
        block: true,
        callback: (function(_this) {
          return function() {
            var container;
            toolbar.find(".toolbar-item-ul").mousedown();
            container = $(_this.editor.selection.getRange().commonAncestorContainer.parentNode);
            container.text("");
            return _this.editor.selection.setRangeAtStartOf(container);
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
