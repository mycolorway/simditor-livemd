class SimditorMarkdown extends Plugin

  opts:
    markdown: false

  constructor: (args...) ->
    super args...
    @editor = @widget

  _init: ->
    @opts.markdown = @opts.markdown || @editor.textarea.data("markdown")
    return unless @opts.markdown

    @editor.body.on("keypress", $.proxy(@_onKeyPress, @))

    toolbar = @editor.toolbar.list

    # Unordered list
    @addInputHook
      key:
        42: "*"
      cmd: /^\*/
      block: true
      callback: =>
        toolbar.find(".toolbar-item-ul").mousedown()
        container = $(@editor.selection.getRange().commonAncestorContainer.parentNode)
        container.text("")
        @editor.selection.setRangeAtStartOf container

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
