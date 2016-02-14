{CompositeDisposable} = require 'event-kit'
_ = require 'lodash'
{$} = require 'space-pen'
fs = require('fs-extra')
fspath = require('path')

DirectoryHandler = require('./directoryHandler')
ModuleHandler = require('./moduleHandler')
Config = require('./configHandler')

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
    moduleFields.classList.add('mantra', 'atom-pane')
    @element.appendChild(moduleFields)

    DirectoryHandler.checkCreateDirectory(Config.get("root") + "client/configs")
    DirectoryHandler.checkCreateFile(Config.get("root") + "client/configs/context.$lang", "templates/$lang/app/client/configs/context.$lang")

    DirectoryHandler.checkCreateFile(Config.get("root") + "client/main.$lang", "templates/$lang/app/client/main.$lang")

    # check create module directory
    DirectoryHandler.checkCreateDirectory(Config.get("root") + "client/modules")
    moduleHandler = new ModuleHandler(moduleFields)

    # add server methods

    serverFields = document.createElement('div')
    serverFields.classList.add('mantra', 'atom-pane')
    @element.appendChild(serverFields)

    # add main server file
    DirectoryHandler.checkCreateDirectory(Config.get("root") + "server/methods")
    DirectoryHandler.checkCreateFile(Config.get("root") + "server/main.$lang", "templates/$lang/app/server/main.$lang")
    DirectoryHandler.checkCreateFile(Config.get("root") + "server/methods/index.$lang", "templates/$lang/app/server/methods/index.$lang")
    DirectoryHandler.checkCreateDirectory(Config.get("root") + "server/publications")
    DirectoryHandler.checkCreateFile(Config.get("root") + "server/publications/index.$lang", "templates/$lang/app/server/publications/index.$lang")

    new DirectoryHandler("methods", serverFields, Config.get("root") + "server/methods", "method", null, (event, newPath) ->
      # find the name of the new module
      name = fspath.basename(newPath, ".js")
      name = fspath.basename(name, ".ts")

      # modify main.js
      mainFile = DirectoryHandler.resolvePath("server/methods/index.$lang", true, true)

      DirectoryHandler.replaceInFile(mainFile, [
          "export default function () {", "import " + name + " from \"./" + name + "\";\nexport default function () {",
          "export default function () {", "export default function () {\n    " + name + "();"
      ])
    , ["Method Name", "Parameter Name"]
    )

    # add publications

    new DirectoryHandler("publications", serverFields, Config.get("root") + "server/publications", "publication", null, (event, newPath) ->
      # find the name of the new module
      name = fspath.basename(newPath, ".js")
      name = fspath.basename(name, ".ts")

      # modify main.js
      mainFile = DirectoryHandler.resolvePath("server/publications/index.$lang", true, true)

      DirectoryHandler.replaceInFile(mainFile, [
          "export default function () {", "import " + name + " from \"./" + name + "\";\nexport default function () {",
          "export default function () {", "export default function () {\n    " + name + "();"
      ])
    , ["Publication Name", "Collection Name"]
    )

    # add lib directory
    new DirectoryHandler("library", serverFields, Config.get("root") + Config.get("libFolderName"))

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
