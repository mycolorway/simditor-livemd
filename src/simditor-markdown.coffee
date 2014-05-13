class SimditorMarkdown extends Plugin

  opts:
    markdown: false

  constructor: (args...) ->
    super args...
    @editor = @widget

  _init: ->
    @opts.markdown = @opts.markdown || @editor.textarea.data("markdown")
    return unless @opts.markdown

    @editor.on("keypress", $.proxy(@_onKeyPress, @))

    toolbar = @editor.toolbar.list

    # Unordered list
    @addInputHook
      key:
        42: "*"
        43: "+"
        45: "-"
      cmd: /^\*{1}$|^\+{1}$|^\-{1}$/
      block: true
      callback: =>
        container = $(@editor.selection.getRange().commonAncestorContainer.parentNode)
        container.text ""
        toolbar.find(".toolbar-item-ul").mousedown()

    # Ordered list
    @addInputHook
      key:
        46: "."
        48: "0"
        49: "1"
        50: "2"
        51: "3"
        52: "4"
        53: "5"
        54: "6"
        55: "7"
        56: "8"
        57: "9"
      cmd: /^[0-9]\.{1}$/
      block: true
      callback: =>
        container = $(@editor.selection.getRange().commonAncestorContainer.parentNode)
        container.text ""
        toolbar.find(".toolbar-item-ol").mousedown()

    # Header
    @addInputHook
      key:
        35: "#"
      cmd: /^#+/
      block: true
      callback: (e, hook, cmd) =>
        level = if cmd.length > 3 then 3 else cmd.length
        toolbar.find(".toolbar-menu-title .menu-item-h#{level}").click()
        container = $(@editor.selection.getRange().commonAncestorContainer.parentNode)

        # cmd like "##"
        if /^#+$/.test cmd
          container.html cmd.replace(hook.cmd, "&nbsp;")
          @editor.selection.setRangeAtStartOf container
        # cmd like "##title"
        else
          container.text cmd.replace(hook.cmd, "")
          @editor.selection.setRangeAtEndOf container

    # Blockquote
    @addInputHook
      key:
        62: ">"
      cmd: /^>{1}$/
      block: true
      callback: (e, hook, cmd) =>
        container = $(@editor.selection.getRange().commonAncestorContainer.parentNode)
        container.html cmd.replace(hook.cmd, "<br/>")
        toolbar.find(".toolbar-item-blockquote").mousedown()
        @editor.selection.setRangeAtStartOf container

    # Code
    @addInputHook
      key:
        96: "`"
      cmd: /^`{3}$/
      block: true
      callback: (e, hook, cmd) =>
        container = $(@editor.selection.getRange().commonAncestorContainer.parentNode)
        container.text ""
        toolbar.find(".toolbar-item-code").mousedown()

    # Horizontal rule
    @addInputHook
      key:
        42: "*"
        45: "-"
      cmd: /^\*{3,}$|^\-{3,}$/
      block: true
      callback: (e, hook, cmd) =>
        container = $(@editor.selection.getRange().commonAncestorContainer.parentNode)
        container.html cmd.replace(hook.cmd, "<br/>")
        toolbar.find(".toolbar-item-hr").mousedown()


  _onKeyPress: (e) ->
    if @editor.triggerHandler(e) is false
      return false

    # input hooks are limited in a single line
    @_hookStack.length = 0 if e.which is 13

    # check the input hooks
    if e.which is 32
      cmd = @_hookStack.join ""
      @_hookStack.length = 0

      for hook in @_inputHooks
        if (hook.cmd instanceof RegExp and hook.cmd.test(cmd)) or hook.cmd is cmd
          container = @editor.selection.getRange().commonAncestorContainer
          break if hook.block and ( not $(container.parentNode).is("p, div") or not hook.cmd.test(container.textContent) )

          hook.callback(e, hook, cmd)
          e.preventDefault()
          break
    else if @_hookKeyMap[e.which]
      @_hookStack.push @_hookKeyMap[e.which]
      @_hookStack.shift() if @_hookStack.length > 10


  # a hook will be triggered when specific string typed
  _inputHooks: []

  _hookKeyMap: {}

  _hookStack: []

  addInputHook: (hookOpt) ->
    $.extend(@_hookKeyMap, hookOpt.key)
    @_inputHooks.push hookOpt

Simditor.connect SimditorMarkdown
