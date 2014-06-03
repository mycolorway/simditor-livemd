class Markdown extends Plugin

  opts:
    markdown: false


  constructor: (args...) ->
    super args...
    @editor = @widget


  _init: ->
    return unless @opts.markdown

    $.extend(@hooks, @opts.markdown) if typeof @opts.markdown is "object"

    @editor.on "keypress", (e) =>
      return unless e.which is 32 or e.which is 13

      range     = @editor.selection.getRange()
      container = range?.commonAncestorContainer
      return unless range and range.collapsed and container and container.nodeType is 3 \
        and not $(container).parent("pre").length

      content = container.textContent
      for name, hook of @hooks
        continue unless hook and hook.cmd instanceof RegExp
        match = content.match hook.cmd
        continue unless match

        if hook.block
          $blockEl  = @editor.util.closestBlockEl container
          testRange = document.createRange()
          testRange.setStart container, 0
          testRange.collapse true
          continue unless @editor.selection.rangeAtStartOf($blockEl, testRange)

        e.preventDefault() if e.which is 32 or name is "code"

        cmdStart = match.index
        cmdEnd   = match[0].length + match.index
        range.setStart container, cmdStart
        range.setEnd   container, cmdEnd

        if hook.block
          range.deleteContents()
          $blockEl.append(@editor.util.phBr) if @editor.util.isEmptyNode($blockEl)
          @editor.selection.setRangeAtEndOf $blockEl
        else
          @editor.selection.selectRange range

        hook.callback.call(@, hook, range, match, $blockEl)
        break


  hooks:
    # Header
    title:
      cmd: /^#+/
      block: true
      callback: (hook, range, match, $blockEl) ->
        button = @editor.toolbar.findButton "title"
        return if button is null or button.disabled
        level = Math.min match[0].length, 3
        button.command "h#{level}"


    # Blockquote
    blockquote:
      cmd: /^>{1}/
      block: true
      callback: (hook, range, match, $blockEl) ->
        button = @editor.toolbar.findButton "blockquote"
        return if button is null or button.disabled
        button.command()


    # Code
    code:
      cmd: /^`{3}/
      block: true
      callback: (hook, range, match, $blockEl) ->
        button = @editor.toolbar.findButton "code"
        return if button is null or button.disabled
        button.command()


    # Horizontal rule
    hr:
      cmd: /^\*{3,}$|^\-{3,}$/
      block: true
      callback: (hook, range, match, $blockEl) ->
        button = @editor.toolbar.findButton "hr"
        return if button is null or button.disabled
        button.command()


    # Emphasis: bold
    bold:
      cmd: /\*{2}([^\*]+)\*{2}$|_{2}([^_]+)_{2}$/
      block: false
      callback: (hook, range, match) ->
        button = @editor.toolbar.findButton "bold"
        return if button is null or button.disabled

        text = match[1] or match[2]
        textNode = document.createTextNode text
        range.deleteContents()
        range.insertNode textNode
        range.selectNode textNode
        @editor.selection.selectRange range
        document.execCommand "bold"
        @editor.selection.setRangeAfter textNode
        document.execCommand "bold"
        @editor.trigger "valuechanged"
        @editor.trigger "selectionchanged"


    # Emphasis: italic
    # italic:
    #   cmd: /\*([^\*]+)\*|_([^_]+)_/
    #   block: false
    #   callback: (hook, range, match) ->
    #     button = @editor.toolbar.findButton "italic"
    #     return if button is null or button.disabled

    #     text = match[1] or match[2]
    #     textNode = document.createTextNode text
    #     range.deleteContents()
    #     range.insertNode textNode
    #     range.selectNode textNode
    #     @editor.selection.selectRange range
    #     document.execCommand "italic"
    #     @editor.selection.setRangeAfter textNode
    #     document.execCommand "italic"
    #     @editor.trigger "valuechanged"
    #     @editor.trigger "selectionchanged"


    # Unordered list
    ul:
      cmd: /^\*{1}|^\+{1}|^\-{1}/
      block: true
      callback: (hook, range, match, $blockEl) ->
        button = @editor.toolbar.findButton "ul"
        return if button is null or button.disabled
        button.command()


    # Ordered list
    ol:
      cmd: /^[0-9][\.\u3002]{1}/
      block: true
      callback: (hook, range, match, $blockEl) ->
        button = @editor.toolbar.findButton "ol"
        return if button is null or button.disabled
        button.command()


    # Image
    image:
      cmd: /!\[(.+)\]\((.+)\)/
      block: true
      callback: (hook, range, match) ->
        button = @editor.toolbar.findButton "image"
        return if button is null or button.disabled
        button.command match[2]


    # Link
    link:
      cmd: /\[(.+)\]\((.+)\)|\<((.[^\[\]\(\)]+))\>/
      block: false
      callback: (hook, range, match) ->
        button = @editor.toolbar.findButton "link"
        return if button is null or button.disabled

        $link = $("<a/>", {
          text: match[1] or match[3]
          href: match[2] or match[4]
          target: "_blank"
        })
        range.deleteContents()
        range.insertNode $link[0]
        @editor.selection.setRangeAfter $link
        @editor.trigger "valuechanged"
        @editor.trigger "selectionchanged"


Simditor.connect Markdown
