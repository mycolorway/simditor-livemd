class SimditorLivemd extends SimpleModule

  @pluginName: 'Livemd'

  opts:
    livemd: false

  _init: ->
    return unless @opts.livemd

    @editor = @_module
    if typeof @opts.livemd is "object"
      hooks = $.extend({}, @hooks, @opts.livemd)
    else
      hooks = $.extend({}, @hooks)

    @editor.on "keypress", (e) =>
      return unless e.which is 32 or e.which is 13

      range = @editor.selection.getRange()
      container = range?.commonAncestorContainer
      return unless range and range.collapsed and container and container.nodeType is 3 \
        and not $(container).parent("pre").length

      content = container.textContent
      for name, hook of hooks
        return if e.which is 13 and not hook.enterKey
        continue unless hook and hook.cmd instanceof RegExp
        match = content.match hook.cmd
        continue unless match
        button = @editor.toolbar.findButton name
        continue if button is null or button.disabled

        if hook.block
          $blockEl = @editor.util.closestBlockEl container
          testRange = document.createRange()
          testRange.setStart container, 0
          testRange.collapse true
          continue unless @editor.selection.rangeAtStartOf($blockEl, testRange)

        cmdStart = match.index
        cmdEnd = match[0].length + match.index
        range.setStart container, cmdStart
        range.setEnd container, cmdEnd

        if hook.block
          range.deleteContents()
          $blockEl.append(@editor.util.phBr) if @editor.util.isEmptyNode($blockEl)
          @editor.selection.setRangeAtEndOf $blockEl

        result = hook.callback.call(@, button, hook, range, match, $blockEl)
        e.preventDefault() if (e.which is 32 or name is "code") and result
        break


  hooks:
    # Header
    title:
      cmd: /^#+/
      block: true
      enterKey: true
      callback: (button, hook, range, match, $blockEl) ->
        level = Math.min match[0].length, 3
        button.command "h#{level}"


    # Blockquote
    blockquote:
      cmd: /^>{1}/
      block: true
      enterKey: true
      callback: (button, hook, range, match, $blockEl) ->
        button.command()


    # Code
    code:
      cmd: /^`{3}/
      block: true
      enterKey: true
      callback: (button, hook, range, match, $blockEl) ->
        button.command()


    # Horizontal rule
    hr:
      cmd: /^\*{3,}$|^\-{3,}$/
      block: true
      enterKey: true
      callback: (button, hook, range, match, $blockEl) ->
        button.command()


    # Emphasis: bold
    bold:
      cmd: /\*{2}([^\*]+)\*{2}$|_{2}([^_]+)_{2}$/
      block: false
      callback: (button, hook, range, match) ->
        text = match[1] or match[2]
        textNode = document.createTextNode text
        @editor.selection.selectRange range
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
    italic:
      cmd: /\*([^\*]+)\*$/
      block: false
      callback: (button, hook, range, match) ->
        text = match[1] or match[2]
        textNode = document.createTextNode text
        @editor.selection.selectRange range
        range.deleteContents()
        range.insertNode textNode
        range.selectNode textNode
        @editor.selection.selectRange range
        document.execCommand "italic"
        @editor.selection.setRangeAfter textNode
        document.execCommand "italic"
        @editor.trigger "valuechanged"
        @editor.trigger "selectionchanged"


    # Unordered list
    ul:
      cmd: /^\*{1}$|^\+{1}$|^\-{1}$/
      block: true
      callback: (button, hook, range, match, $blockEl) ->
        button.command()


    # Ordered list
    ol:
      cmd: /^[0-9][\.\u3002]{1}$/
      block: true
      callback: (button, hook, range, match, $blockEl) ->
        button.command()


    # Image
    image:
      cmd: /!\[(.+)\]\((.+)\)$/
      block: true
      callback: (button, hook, range, match) ->
        button.command match[2]


    # Link
    link:
      cmd: /\[(.+)\]\((.+)\)$|\<((.[^\[\]\(\)]+))\>$/
      block: false
      callback: (hook, range, match) ->
        url = match[2] or match[4]
        return false unless /[a-zA-z]+:\/\/[^\s]*/.test url

        $link = $("<a/>", {
          text: match[1] or match[3]
          href: url
          target: "_blank"
        })
        @editor.selection.selectRange range
        range.deleteContents()
        range.insertNode $link[0]
        @editor.selection.setRangeAfter $link
        @editor.trigger "valuechanged"
        @editor.trigger "selectionchanged"


Simditor.connect SimditorLivemd
