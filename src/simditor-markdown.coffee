class SimditorMarkdown extends Plugin

  opts:
    markdown: false


  constructor: (args...) ->
    super args...
    @editor = @widget

    @markdownConfigs =
      # Unordered list
      ul:
        key:
          42: "*"
          43: "+"
          45: "-"
        cmd: /^\*{1}$|^\+{1}$|^\-{1}$/
        block: true
        callback: (e, hook, cmd, container) =>
          button = @editor.toolbar.findButton "ul"
          return if button is null
          e.preventDefault()
          container.text ""
          button.command "ul"

      # Ordered list
      ol:
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
        callback: (e, hook, cmd, container) =>
          button = @editor.toolbar.findButton "ol"
          return if button is null
          e.preventDefault()
          container.text ""
          button.command "ol"

      # Header
      title:
        key:
          35: "#"
        cmd: /^#+/
        block: true
        callback: (e, hook, cmd, container) =>
          level = if cmd.length > 3 then 3 else cmd.length
          button = @editor.toolbar.findButton "title"
          return if button is null
          e.preventDefault()
          if /^#+$/.test cmd
            container.html cmd.replace(hook.cmd, "&nbsp;")
            @editor.selection.setRangeAtStartOf container
          else
            container.text cmd.replace(hook.cmd, "")
            @editor.selection.setRangeAtEndOf container
          button.command "h#{level}"

      # Blockquote
      blockquote:
        key:
          62: ">"
        cmd: /^>{1}$/
        block: true
        callback: (e, hook, cmd, container) =>
          button = @editor.toolbar.findButton "blockquote"
          return if button is null
          e.preventDefault()
          button.command()
          container.html cmd.replace(hook.cmd, "<br/>")
          @editor.selection.setRangeAtStartOf container

      # Code
      code:
        key:
          96: "`"
        cmd: /^`{3}$/
        block: true
        callback: (e, hook, cmd, container) =>
          button = @editor.toolbar.findButton "code"
          return if button is null
          e.preventDefault()
          container.text ""
          button.command()

      # Horizontal rule
      hr:
        key:
          42: "*"
          45: "-"
        cmd: /^\*{3,}$|^\-{3,}$/
        block: true
        callback: (e, hook, cmd, container) =>
          button = @editor.toolbar.findButton "hr"
          return if button is null
          e.preventDefault()
          container.html cmd.replace(hook.cmd, "<br/>")
          button.command()

      # Emphasis: italic
      italic:
        key:
          42: "*"
          95: "_"
        cmd: /\*([^\*]+)\*$|_([^_]+)_$/
        block: false
        callback: (e, hook, cmd, container) =>
          button = @editor.toolbar.findButton "italic"
          return if button is null
          e.preventDefault()
          container.textContent = cmd.replace(hook.cmd, "$1$2")
          range = document.createRange()
          range.setStart container, cmd.match(hook.cmd).index
          range.setEnd   container, cmd.length - 2
          @editor.selection.selectRange range

          if button.status $(range.commonAncestorContainer.parentNode)
            @editor.selection.setRangeAtEndOf container
          else
            button.command()
            @editor.selection.setRangeAtEndOf container
            button.command()

      # Emphasis: bold
      bold:
        key:
          42: "*"
          95: "_"
        cmd: /\*{2}([^\*]+)\*{2}$|_{2}([^_]+)_{2}$/
        block: false
        callback: (e, hook, cmd, container) =>
          button = @editor.toolbar.findButton "bold"
          return if button is null
          e.preventDefault()
          container.textContent = cmd.replace(hook.cmd, "$1$2")
          range = document.createRange()
          range.setStart container, cmd.match(hook.cmd).index
          range.setEnd   container, cmd.length - 4
          @editor.selection.selectRange range

          if button.status $(range.commonAncestorContainer.parentNode)
            @editor.selection.setRangeAtEndOf container
          else
            button.command()
            @editor.selection.setRangeAtEndOf container
            button.command()

  _init: ->
    @opts.markdown = @opts.markdown || @editor.textarea.data("markdown")
    return unless @opts.markdown

    @editor.on("keypress", $.proxy(@_onKeyPress, @))

    for button, config of @markdownConfigs
      @addInputHook config


  _onKeyPress: (e) ->
    # check the input hooks
    if e.which is 32
      range     = @editor.selection.getRange()
      container = range.commonAncestorContainer
      cmd       = container.textContent

      for hook in @_inputHooks
        if (hook.cmd instanceof RegExp and hook.cmd.test(cmd)) or hook.cmd is cmd
          break if hook.block and not $(container.parentNode).is("p, div")

          hook.callback(e, hook, cmd, container)
          break


  # a hook will be triggered when specific string typed
  _inputHooks: []

  _hookKeyMap: {}

  addInputHook: (hookOpt) ->
    $.extend(@_hookKeyMap, hookOpt.key)
    @_inputHooks.push hookOpt

Simditor.connect SimditorMarkdown
