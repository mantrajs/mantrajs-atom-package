fs = require("fs-extra")
path = require 'path'

{requirePackages} = require 'atom-utils'
{CompositeDisposable} = require 'event-kit'
Config = require('./configHandler')
DirectoryHandler = require('./directoryHandler')

MantraPaneView = require './mantra-pane-view'

AddDialog = null  # Defer requiring until actually needed
showing = false

module.exports =
class MantraView

  @treeView = null

  constructor: (serializedState) ->

    # Create root element
    @element = document.createElement('li')

    @mantraPanes = []

    @paneSub = new CompositeDisposable

    @currentPath = null

    #@loadDirectories()
    #
    # @paneSub.add atom.project.onDidChangePaths (path) =>
    #   @annotate()

    # @paneSub.add atom.workspace.observePanes (pane) =>
    #   @mantraPaneView.setPane pane
      # TODO: Implement tear down on pane destroy subscription if needed (TBD)
      # destroySub = pane.onDidDestroy =>
      #   destroySub.dispose()
      #   @removeTabGroup pane
      # @paneSub.add destroySub

  loadDirectories: ->
    self = this

    # Remove all existing panels
    for tree in @mantraPanes
      tree.hide()

    path = atom.project.resolvePath(".")

    # if we are showing the same project, just show the previous panes
    if path != @currentPath && @mantraPanes.length
      for tree in @mantraPanes
        tree.show()
      return


    # it is a new project, load new panes
    currentPath = path

    self.mantraPanes = []
    atom.project.getDirectories().map (repo) ->

      # if there are more projects opened, we only consider the first one
      if self.mantraPanes.length
        atom.notifications.addInfo "Ignoring " + repo.path
        return

      #for repo in repos
        #if repo.repo == null
        #  for tree in self.mantraPanes
        #    if repo.path == tree.repo.path

        #      tree.show()
        #else
      @mantraPaneView = new MantraPaneView repo
      #mantraPaneView.setRepo repo
      self.mantraPanes.push mantraPaneView
      self.element.appendChild mantraPaneView.element

      self.paneSub.add atom.workspace.observePanes (pane) ->
        mantraPaneView.setPane pane

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()
    @paneSub.dispose()

  getElement: ->
    @element

  # Toggle the visibility of this view
  toggle: ->
    if @element.parentElement?
      @hide()
    else
      @show()

  hide: ->
    @element.remove()
    # recursively remove all buttons
    if @parentElement
      @hideButtons @parentElement

    showing = false

  hideButtons: (parent) ->
    for elem in parent.children
      unless elem
        continue
      if (elem.getAttribute("data-mantra"))
        elem.remove()
      if (elem.children && elem.children.length > 0)
        @hideButtons child for child in elem.children

  # Append pane before the tree view
  show: ->
    Config.reset()
    console.log("showing: " + showing)
    if showing
      return
    showing = true

    @loadDirectories()

    requirePackages('tree-view').then ([treeView]) =>
      @treeView = treeView.treeView
      @treeView.find('.tree-view-scroller').css 'background', treeView.treeView.find('.tree-view').css 'background'
      @parentElement = @treeView.element.querySelector('.tree-view-scroller .tree-view')

      m = @element
      @parentElement.insertBefore(@element, @parentElement.firstChild)

      MantraView.treeView = @treeView.element
