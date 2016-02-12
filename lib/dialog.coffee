{$, TextEditorView, View} = require 'atom-space-pen-views'
path = require 'path'

module.exports =
class Dialog extends View
  self = this

  @content: ({prompt, options, templateText} = {}) ->
    @div class: 'tree-view-dialog', =>
      @label prompt, class: 'icon', outlet: 'promptText'
      @subview 'miniEditor', new TextEditorView(mini: true)

      if options
        optionTexts = []

        changeText = (view, index, optionTexts, templateText, getLabel) ->
          label = getLabel()
          text = templateText

          optionTexts[index] = view.getText()
          for j in [0...optionTexts.length]
            val = optionTexts[j]
            if val
              regex = new RegExp("\\$" + (j + 1), "g");
              text = text.replace(regex, val)

          label.text(text)

        for i in [0...options.length]
          optionTexts[i] = null

          @div class: ''
          @label options[i], class: 'icon'
          view = new TextEditorView(mini: true)
          @subview 'option_' + i, view

          view.on 'keyup', changeText.bind(this, view, i, optionTexts, templateText, -> self.getLabel())

        @div class: ''

      if templateText
        @pre templateText, outlet: 'templateView'

      @div class: 'error-message', outlet: 'errorMessage'

      @button 'Accept', class: 'pull-right', outlet: 'acceptButton'
      @button 'Cancel', outlet: 'closeButton'


  getLabel: ->
    return @templateView

  initialize: ({initialPath, select, iconClass, templateText} = {}) ->
    self = this

    @promptText.addClass(iconClass) if iconClass
    atom.commands.add @element,
      'core:confirm': => @onConfirm(@miniEditor.getText())
      'core:cancel': => @cancel()
    #@miniEditor.on 'blur', => @close()
    @miniEditor.getModel().onDidChange => @showError()
    @miniEditor.getModel().setText(initialPath)

    @closeButton.on 'click', -> self.cancel()
    @acceptButton.on 'click', => @onConfirm(@miniEditor.getText())

    if select
      extension = path.extname(initialPath)
      baseName = path.basename(initialPath)
      if baseName is extension
        selectionEnd = initialPath.length
      else
        selectionEnd = initialPath.length - extension.length
      range = [[0, initialPath.length - baseName.length], [0, selectionEnd]]
      @miniEditor.getModel().setSelectedBufferRange(range)

  attach: ->
    @panel = atom.workspace.addModalPanel(item: this.element)
    @miniEditor.focus()
    @miniEditor.getModel().scrollToCursorPosition()

  close: ->
    panelToDestroy = @panel
    @panel = null
    panelToDestroy?.destroy()
    atom.workspace.getActivePane().activate()

  cancel: ->
    @close()
    $('.tree-view').focus()

  showError: (message='') ->
    @errorMessage.text(message)
    @flashError() if message
