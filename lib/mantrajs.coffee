{CompositeDisposable} = require 'atom'
{requirePackages} = require 'atom-utils'
TreeViewGitModifiedView = require './mantra-view'
fs = require("fs-plus")

module.exports = TreeViewGitModified =
  config:
    language:
      type: 'string'
      default: 'Javascript'
      enum: ["Javascript", "Typescript"]
    projectRoot:
      type: 'string'
      default: ''
      description: "Defines the directory which is root to server/client and lib folder"
    libFolderName:
      type: 'string'
      default: 'lib'
      description: "Defines the name of the lib folder"

  mantraTreeView: null
  subscriptions: null
  isVisible: false

  activate: (state) ->
    @mantraTreeView = new TreeViewGitModifiedView(state.mantraTreeViewState)
    @isVisible = state.isVisible

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'mantrajs:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'mantrajs:init': => @init()
    @subscriptions.add atom.commands.add 'atom-workspace', 'mantrajs:show': => @show()
    @subscriptions.add atom.commands.add 'atom-workspace', 'mantrajs:hide': => @hide()

    @subscriptions.add atom.project.onDidChangePaths (path) =>
      @show()

    requirePackages('tree-view').then ([treeView]) =>
      if (!@mantraTreeView)
        @mantraTreeView = new TreeViewGitModifiedView

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
    atom.notifications.addWarning("I must warn you, this is only alpha!");

    @mantraTreeView.show()
    @isVisible = true

  hide: ->
    @mantraTreeView.hide()
    @isVisible = false

  init: ->
    pathFrom = atom.packages.resolvePackagePath("mantrajs/templates/app/client");
    pathTo =  atom.project.resolvePath("client");
    fs.copySync(pathFrom, pathTo)

    pathFrom = atom.packages.resolvePackagePath("mantrajs/templates/app/server");
    pathTo =  atom.project.resolvePath("server");
    fs.copySync(pathFrom, pathTo)

    pathFrom = atom.packages.resolvePackagePath("mantrajs/templates/app/lib");
    pathTo =  atom.project.resolvePath("lib");
    fs.copySync(pathFrom, pathTo)
