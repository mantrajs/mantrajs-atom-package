{CompositeDisposable} = require 'atom'
{requirePackages} = require 'atom-utils'
MantraView = require './mantra-view'
fs = require("fs-extra")
Config = require './configHandler'

module.exports = TreeViewGitModified =
  config:
    projectType:
      type: 'string'
      default: 'Classic Mantra (JS)'
      enum: ["Classic Mantra (JS)", "Classic Mantra (TS)"]

  mantraTreeView: null
  subscriptions: null
  isVisible: false

  activate: (state) ->
    @mantraTreeView = new MantraView(state.mantraTreeViewState)
    @isVisible = state.isVisible

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'mantrajs:toggle': => @toggle()

    @subscriptions.add atom.project.onDidChangePaths (path) =>
      @show()

    requirePackages('tree-view').then ([treeView]) =>
      if (!@mantraTreeView)
        @mantraTreeView = new MantraView

      if (treeView.treeView && @isVisible) or (@isVisible is undefined)
        @mantraTreeView.show()

      atom.commands.add 'atom-workspace', 'tree-view:toggle', =>
        if treeView.treeView?.is(':visible')
          @mantraTreeView.hide()
        else
          if @isVisible
            @mantraTreeView.show()

      atom.commands.add 'atom-workspace', 'tree-view:show', =>
        if @isVisible
          @mantraTreeView.show()

  deactivate: ->
    @subscriptions.dispose()
    @mantraTreeView.destroy()

  serialize: ->
    isVisible: @isVisible
    mantraTreeViewState: @mantraTreeView.serialize()

  toggle: ->
    if @isVisible
      @mantraTreeView.hide()
    else
      @mantraTreeView.show()
    @isVisible = !@isVisible

  show: ->
    Config.options = null # erase options
    atom.notifications.addWarning("I must warn you, this is only alpha!")

    @mantraTreeView.show()
    @isVisible = true

  hide: ->
    @mantraTreeView.hide()
    @isVisible = false
