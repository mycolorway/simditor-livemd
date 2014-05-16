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
        callback: (hook, range, match) =>
          button    = @editor.toolbar.findButton "title"
          return if button is null or button.disabled

          offset    = range.startOffset
          container = range.commonAncestorContainer
          length    = match[0].length
          level     = if length > 3 then 3 else length
          container.textContent = container.textContent.replace(match[0], "")
          @_format container
          if offset > length
            range.setStart container, offset - length
            @editor.selection.selectRange range
          button.command "h#{level}"


      # Blockquote
      blockquote:
        cmd: /^>{1}/
        block: true
        callback: (hook, range, match) =>
          button = @editor.toolbar.findButton "blockquote"
          return if button is null or button.disabled

          offset    = range.startOffset
          container = range.commonAncestorContainer
          container.textContent = container.textContent.replace(match[0], "")
          @_format container
          if offset > 1
            range.setStart container, offset - 1
            @editor.selection.selectRange range
          button.command()


      # Code
      code:
        cmd: /^`{3}/
        block: true
        callback: (hook, range, match) =>
          button = @editor.toolbar.findButton "code"
          return if button is null or button.disabled

          offset    = range.startOffset
          container = range.commonAncestorContainer
          container.textContent = container.textContent.replace(match[0], "")
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
        callback: (hook, range, match) =>
          button    = @editor.toolbar.findButton "hr"
          return if button is null or button.disabled

          offset    = range.startOffset
          container = range.commonAncestorContainer
          container.textContent = container.textContent.replace(match[0], "")
          @_format container
          button.command()


      # Emphasis: bold
      bold:
        cmd: /\*{2}([^\*]+)\*{2}|_{2}([^_]+)_{2}/
        block: false
        callback: (hook, range, match) =>
          button    = @editor.toolbar.findButton "bold"
          return if button is null or button.disabled

          offset    = range.startOffset
          container = range.commonAncestorContainer
          length    = match.index + match[0].length
          container.textContent = container.textContent.replace(match[0], match[1] or match[2])
          range.setStart container, match.index
          range.setEnd   container, length - 4
          @editor.selection.selectRange range

          if button.status $(range.commonAncestorContainer.parentNode)
            @editor.selection.setRangeAtEndOf container
          else
            button.command()
            if offset > length
              range.setStart container, offset - length
              range.setEnd   container, offset - length
              @editor.selection.selectRange range
            else
              @editor.selection.setRangeAtEndOf container
              button.command()


      # Emphasis: italic
      italic:
        cmd: /\*([^\*]+)\*|_([^_]+)_/
        block: false
        callback: (hook, range, match) =>
          button    = @editor.toolbar.findButton "italic"
          return if button is null or button.disabled

          offset    = range.startOffset
          container = range.commonAncestorContainer
          length    = match.index + match[0].length
          container.textContent = container.textContent.replace(match[0], match[1] or match[2])
          range.setStart container, match.index
          range.setEnd   container, length - 2
          @editor.selection.selectRange range

          if button.status $(range.commonAncestorContainer.parentNode)
            @editor.selection.setRangeAtEndOf container
          else
            button.command()
            if offset > length
              range.setStart container, offset - length
              range.setEnd   container, offset - length
              @editor.selection.selectRange range
            else
              @editor.selection.setRangeAtEndOf container
              button.command()


      # Unordered list
      ul:
        cmd: /^\*{1}|^\+{1}|^\-{1}/
        block: true
        callback: (hook, range, match) =>
          button    = @editor.toolbar.findButton "ul"
          return if button is null or button.disabled

          offset    = range.startOffset
          container = range.commonAncestorContainer
          container.textContent = container.textContent.replace(match[0], "")
          @_format container
          if offset > 1
            range.setStart container, offset - 1
            @editor.selection.selectRange range
          button.command()


      # Ordered list
      ol:
        cmd: /^[0-9][\.\u3002]{1}/
        block: true
        callback: (hook, range, match) =>
          button    = @editor.toolbar.findButton "ol"
          return if button is null or button.disabled

          offset    = range.startOffset
          container = range.commonAncestorContainer
          container.textContent = container.textContent.replace(match[0], "")
          @_format container
          if offset > 2
            range.setStart container, offset - 2
            @editor.selection.selectRange range
          button.command()


      # Image
      image:
        cmd: /!\[(.+)\]\((.+)\)/
        block: false
        callback: (hook, range, match) =>
          button    = @editor.toolbar.findButton "image"
          return if button is null or button.disabled

          container = range.commonAncestorContainer
          container.textContent = container.textContent.replace(match[0], "")
          @editor.selection.setRangeAtEndOf container
          button.command match[2]


      # Link
      link:
        cmd: /\[(.+)\]\((.+)\)|\<((.[^\[\]\(\)]+))\>/
        block: false
        callback: (hook, range, match) =>
          button    = @editor.toolbar.findButton "link"
          return if button is null or button.disabled

          offset    = range.startOffset
          container = range.commonAncestorContainer
          container.textContent = container.textContent.replace(match[0], "")
          text   = match[1] or match[3]
          url    = match[2] or match[4]
          if match.index > 0
            range.setStart container, match.index
            @editor.selection.selectRange range


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
      for name, hook of @markdownConfigs
        match = content.match(hook.cmd)
        if hook.cmd instanceof RegExp and match isnt null
          newRange = document.createRange()
          newRange.setStart container, 0
          newRange.setEnd   container, 0
          continue if hook.block and not @editor.selection.rangeAtStartOf(container.parentNode, newRange)
          e.preventDefault() if e.which is 32
          hook.callback(hook, range, match)
          break


  _format: (container) =>
    $el = $(container.parentNode)
    @editor.selection.setRangeAtStartOf $("<br/>").appendTo($el) if $el.is(":empty")


Simditor.connect SimditorMarkdown
