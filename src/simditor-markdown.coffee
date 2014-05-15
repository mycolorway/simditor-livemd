class SimditorMarkdown extends Plugin

  opts:
    markdown: false


  constructor: (args...) ->
    super args...
    @editor = @widget

    @markdownConfigs =
      # Unordered list
      ul:
        cmd: /^\*{1}$|^\+{1}$|^\-{1}$/
        block: true
        callback: (hook, cmd, container, button) =>
          container.textContent = cmd.replace(hook.cmd, "")
          button.command "ol"

      # Ordered list
      ol:
        cmd: /^[0-9][\.\u3002]{1}$/
        block: true
        callback: (hook, cmd, container, button) =>
          container.textContent = cmd.replace(hook.cmd, "")
          button.command "ol"

      # Header
      title:
        cmd: /^#+$/
        block: true
        callback: (hook, cmd, container, button) =>
          level = if cmd.length > 3 then 3 else cmd.length
          $(container.parentNode).html cmd.replace(hook.cmd, "&nbsp;")
          button.command "h#{level}"

      # Blockquote
      blockquote:
        cmd: /^>{1}$/
        block: true
        callback: (hook, cmd, container, button) =>
          $(container.parentNode).html cmd.replace(hook.cmd, "&nbsp;")
          button.command()

      # Code
      code:
        cmd: /^`{3}$/
        block: true
        callback: (hook, cmd, container, button) =>
          container.textContent = ""
          button.command()

      # Horizontal rule
      hr:
        cmd: /^\*{3,}$|^\-{3,}$/
        block: true
        callback: (hook, cmd, container, button) =>
          $(container.parentNode).html cmd.replace(hook.cmd, "<br/>")
          button.command()

      # Emphasis: italic
      italic:
        cmd: /\*([^\*]+)\*$|_([^_]+)_$/
        block: false
        callback: (hook, cmd, container, button) =>
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
        cmd: /\*{2}([^\*]+)\*{2}$|_{2}([^_]+)_{2}$/
        block: false
        callback: (hook, cmd, container, button) =>
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

      # Link
      link:
        cmd: /[^\!]\[(.+)\]\((.+)\)$|^\[(.+)\]\((.+)\)$|\<((.[^\[\]\(\)]+))\>$/
        block: false
        callback: (hook, cmd, container, button) =>
          container.textContent = ""
          params = cmd.match hook.cmd
          text   = params[1] or params[3] or params[5]
          url    = params[2] or params[4] or params[6]
          button.command text, url

      # Image
      image:
        cmd: /!\[(.+)\]\((.+)\)$/
        block: false
        callback: (hook, cmd, container, button) =>
          container.textContent = ""
          params = cmd.match hook.cmd
          button.command params[2]


  _init: ->
    @opts.markdown = @opts.markdown || @editor.textarea.data("markdown")
    return unless @opts.markdown

    @editor.on("keypress", $.proxy(@_onKeyPress, @))


  _onKeyPress: (e) ->
    # check the input hooks
    if e.which is 32 or e.which is 13
      container = @editor.selection.getRange().commonAncestorContainer
      cmd       = container.textContent

      return unless container.nodeName is "#text"
      for name, hook of @markdownConfigs
        if hook.cmd instanceof RegExp and hook.cmd.test(cmd.trim())
          range = document.createRange()
          range.setStart container, 0
          range.setEnd   container, 0
          break if hook.block and not @editor.selection.rangeAtStartOf(container.parentNode, range)

          button = @editor.toolbar.findButton name
          return if button is null or button.disabled
          e.preventDefault()
          hook.callback(hook, cmd, container, button)
          break


Simditor.connect SimditorMarkdown
