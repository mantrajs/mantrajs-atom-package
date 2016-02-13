fs = require("fs-extra")
path = require 'path'

{requirePackages} = require 'atom-utils'
{CompositeDisposable} = require 'event-kit'
Config = require('./configHandler')
DirectoryHandler = require('./directoryHandler')

TreeViewGitModifiedPaneView = require './mantra-pane-view'

AddDialog = null  # Defer requiring until actually needed

module.exports =
class TreeViewGitModifiedView

  constructor: (serializedState) ->

    # Create root element
    @element = document.createElement('li')

    @mantraPanes = []

    @paneSub = new CompositeDisposable

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

    # DirectoryHandler.checkCreateFile("mantra.json", "templates/mantra.json")

    # dir = DirectoryHandler.resolvePath("client/modules", true, true)
    # unless fs.existsSync(dir)
    #   atom.notifications.addWarning("This is not a Mantra project, client/modules directory missing!");
    #   return

    # Remove all existing panels
    for tree in @mantraPanes
      tree.hide()

    atom.project.getDirectories().map (repo) ->
      #for repo in repos
        #if repo.repo == null
        #  for tree in self.mantraPanes
        #    if repo.path == tree.repo.path

        #      tree.show()
        #else
      @mantraPaneView = new TreeViewGitModifiedPaneView repo
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
    Config.options = null # erase options
    
    @loadDirectories()

    requirePackages('tree-view').then ([treeView]) =>
      @treeView = treeView.treeView
      @treeView.find('.tree-view-scroller').css 'background', treeView.treeView.find('.tree-view').css 'background'
      @parentElement = @treeView.element.querySelector('.tree-view-scroller .tree-view')

      @parentElement.insertBefore(@element, @parentElement.firstChild)
