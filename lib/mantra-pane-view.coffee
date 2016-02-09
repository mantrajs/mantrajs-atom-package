{CompositeDisposable} = require 'event-kit'
_ = require 'lodash'
{$} = require 'space-pen'
fs = require('fs-extra')
DirectoryHandler = require('./directoryHandler')
ModuleHandler = require('./moduleHandler')

AddDialog = null  # Defer requiring until actually needed

module.exports =
class TreeViewOpenFilesPaneView

  constructor: (repo) ->
    self = this

    @items = []
    @panes = []
    @activeItem = null
    @repo = repo
    @paneSub = new CompositeDisposable

    #repoPath = repo.repo.workingDirectory
    #repoName = repoPath.split('/')[repoPath.split('/').length-1]

    # top level element
    @element = document.createElement('li')
    @element.setAttribute('is', 'tree-view-git-modified')

    # add header

    header = document.createElement('div')
    header.classList.add('header', 'list-item')

    headerSpan = document.createElement('span')
    headerSpan.classList.add('name', 'icon', 'icon-mantrajs')
    #headerSpan.setAttribute('data-name', 'Git Modified: ' + repoName)
    headerSpan.innerText = 'Mantra JS'
    header.appendChild(headerSpan)

    @element.appendChild(header)

    # load modules

    moduleFields = document.createElement('div')
    moduleFields.classList.add('mantra', 'pane')
    @element.appendChild(moduleFields)

    moduleHandler = new ModuleHandler(moduleFields)

    # add server methods

    serverFields = document.createElement('div')
    serverFields.classList.add('mantra', 'pane')
    @element.appendChild(serverFields)

    root = atom.config.get('mantrajs.projectRoot');
    if root
      root += "/"

    new DirectoryHandler("methods", serverFields, root + "server/methods", "method")

    # add publications

    new DirectoryHandler("publications", serverFields, root + "server/publications", "publication")

    # add lib directory

    new DirectoryHandler("library", serverFields, root + atom.config.get('mantrajs.libFolderName'))

  setPane: (pane) ->
    @paneSub.add pane.observeActiveItem (item) =>
      @activeItem = item
      @setActiveEntry item

    @paneSub.add pane.onDidChangeActiveItem (item) =>
      if (!item)
        @activeEntry?.classList.remove 'selected'

    @paneSub.add pane.onDidChangeActive (isActive) =>
      @activeItem = pane.activeItem
      if (isActive)
        @setActiveEntry pane.activeItem

  entryForItem: (item) ->
    _.detect @items, (entry) ->
      if item.buffer && item.buffer.file
        item.buffer.file.path.indexOf(entry.item) > -1

  entryForElement: (item) ->
    _.detect @items, (entry) ->
      if (entry.element is item)
        return item

  setActiveEntry: (item) ->
    if item
      @activeEntry?.classList.remove 'selected'
      if entry = @entryForItem item
        entry.element.classList.add 'selected'
        @activeEntry = entry.element

  removeAll: ->
    for item in @items
      item.element.remove()
    @items = []

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  hide: ->
    @element.classList.add 'hidden'

  show: ->
    @element.classList.remove 'hidden'

  # Tear down any state and detach
  destroy: ->
    @element.remove()
    @paneSub.dispose()
