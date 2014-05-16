class SimditorMarkdown extends Plugin

  opts:
    markdown: false


  constructor: (args...) ->
    super args...
    @editor = @widget

    @markdownConfigs =
      # Header
      title:
        cmd: /^#+/
        block: true
        callback: (hook, range, offset) =>
          button    = @editor.toolbar.findButton "title"
          return if button is null or button.disabled
          container = range.commonAncestorContainer
          length    = container.textContent.match(hook.cmd)[0].length
          level     = if length > 3 then 3 else length
          container.textContent = container.textContent.replace(hook.cmd, "")
          @_format container
          if offset > length
            range.setStart container, offset - length
            @editor.selection.selectRange range
          button.command "h#{level}"

      # Blockquote
      blockquote:
        cmd: /^>{1}/
        block: true
        callback: (hook, range, offset) =>
          button = @editor.toolbar.findButton "blockquote"
          return if button is null or button.disabled
          container = range.commonAncestorContainer
          container.textContent = container.textContent.replace(hook.cmd, "")
          @_format container
          if offset > 1
            range.setStart container, offset - 1
            @editor.selection.selectRange range
          button.command()

      # Code
      code:
        cmd: /^`{3}/
        block: true
        callback: (hook, range, offset) =>
          button = @editor.toolbar.findButton "code"
          return if button is null or button.disabled
          container = range.commonAncestorContainer
          container.textContent = container.textContent.replace(hook.cmd, "")
          @_format container
          setTimeout =>
            range.setStart container, offset - 3
            @editor.selection.selectRange range
            button.command()
          , 5

      # Horizontal rule
      hr:
        cmd: /^\*{3,}$|^\-{3,}$/
        block: true
        callback: (hook, range, offset) =>
          button    = @editor.toolbar.findButton "hr"
          return if button is null or button.disabled
          container = range.commonAncestorContainer
          content   = container.textContent
          container.textContent = container.textContent.replace(hook.cmd, "")
          @_format container
          button.command()

      # Emphasis: bold
      bold:
        cmd: /\*{2}([^\*]+)\*{2}$|_{2}([^_]+)_{2}$/
        block: false
        callback: (hook, range, offset) =>
          button    = @editor.toolbar.findButton "bold"
          return if button is null or button.disabled
          container = range.commonAncestorContainer
          content   = container.textContent
          container.textContent = content.replace(hook.cmd, "$1$2")
          range = document.createRange()
          range.setStart container, content.match(hook.cmd).index
          range.setEnd   container, content.length - 4
          @editor.selection.selectRange range

          if button.status $(range.commonAncestorContainer.parentNode)
            @editor.selection.setRangeAtEndOf container
          else
            button.command()
            @editor.selection.setRangeAtEndOf container
            button.command()

      # Emphasis: italic
      italic:
        cmd: /\*([^\*]+)\*$|_([^_]+)_$/
        block: false
        callback: (hook, range, offset) =>
          console.log 0
          button    = @editor.toolbar.findButton "italic"
          return if button is null or button.disabled
          container = range.commonAncestorContainer
          content   = container.textContent
          container.textContent = content.replace(hook.cmd, "$1$2")
          range = document.createRange()
          range.setStart container, content.match(hook.cmd).index
          range.setEnd   container, content.length - 2
          @editor.selection.selectRange range

          if button.status $(range.commonAncestorContainer.parentNode)
            @editor.selection.setRangeAtEndOf container
          else
            button.command()
            @editor.selection.setRangeAtEndOf container
            button.command()

      # Unordered list
      ul:
        cmd: /^\*{1}|^\+{1}|^\-{1}/
        block: true
        callback: (hook, range, offset) =>
          button    = @editor.toolbar.findButton "ul"
          return if button is null or button.disabled
          container = range.commonAncestorContainer
          container.textContent = container.textContent.replace(hook.cmd, "")
          @_format container
          if offset > 1
            range.setStart container, offset - 1
            @editor.selection.selectRange range
          button.command()

      # Ordered list
      ol:
        cmd: /^[0-9][\.\u3002]{1}/
        block: true
        callback: (hook, range, offset) =>
          button    = @editor.toolbar.findButton "ol"
          return if button is null or button.disabled
          container = range.commonAncestorContainer
          container.textContent = container.textContent.replace(hook.cmd, "")
          @_format container
          if offset > 2
            range.setStart container, offset - 2
            @editor.selection.selectRange range
          button.command()

      # Image
      image:
        cmd: /!\[(.+)\]\((.+)\)$/
        block: false
        callback: (hook, range) =>
          button    = @editor.toolbar.findButton "image"
          return if button is null or button.disabled
          container = range.commonAncestorContainer
          content   = container.textContent
          container.textContent = container.textContent.replace(hook.cmd, "")
          @editor.selection.setRangeAtEndOf container
          params = content.match hook.cmd
          button.command params[2]

      # Link
      link:
        cmd: /\[(.+)\]\((.+)\)$|\<((.[^\[\]\(\)]+))\>$/
        block: false
        callback: (hook, range) =>
          button    = @editor.toolbar.findButton "link"
          return if button is null or button.disabled
          container = range.commonAncestorContainer
          content   = container.textContent
          container.textContent = container.textContent.replace(hook.cmd, "")
          params = content.match hook.cmd
          text   = params[1] or params[3]
          url    = params[2] or params[4]
          if params.index > 0
            range.setStart container, params.index
            @editor.selection.selectRange range
          button.command text, url


  _init: ->
    @opts.markdown = @opts.markdown || @editor.textarea.data("markdown")
    return unless @opts.markdown

    @editor.on("keypress", $.proxy(@_onKeyPress, @))


  _onKeyPress: (e) ->
    # check the input hooks
    if e.which is 32 or e.which is 13
      range = @editor.selection.getRange()
      container = range?.commonAncestorContainer
      return unless range and container and container.nodeType == 3

      content = container.textContent
      console.log content
      for button, hook of @markdownConfigs
        if hook.cmd instanceof RegExp and hook.cmd.test(content)
          newRange = document.createRange()
          newRange.setStart container, 0
          newRange.setEnd   container, 0
          continue if hook.block and not @editor.selection.rangeAtStartOf(container.parentNode, newRange)
          e.preventDefault() if e.which is 32
          hook.callback(hook, range, range.startOffset)
          break


  _format: (container) =>
    $el = $(container.parentNode)
    @editor.selection.setRangeAtStartOf $("<br/>").appendTo($el) if $el.is(":empty")


Simditor.connect SimditorMarkdown
