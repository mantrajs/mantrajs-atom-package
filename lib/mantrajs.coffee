MantrajsView = require './mantrajs-view'
{CompositeDisposable} = require 'atom'

module.exports = Mantrajs =
  mantrajsView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @mantrajsView = new MantrajsView(state.mantrajsViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @mantrajsView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'mantrajs:toggle': => @toggle()
 
  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @mantrajsView.destroy()

  serialize: ->
    mantrajsViewState: @mantrajsView.serialize()

  toggle: ->
    console.log 'Mantrajs was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()

  #in main module
  consumeAutoreload: (reloader) ->
    reloader(pkg:"mantrajs",files:["package.json"],folders:["lib/"])
    # pkg has to be the name of your package and is required
    # files are watched and your package reloaded on changes, defaults to ["package.json"]
    # folders are watched and your package reloaded on changes, defaults to ["lib/"]
