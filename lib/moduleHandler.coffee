{$} = require 'space-pen'
DirectoryHandler = require('./directoryHandler')
Config = require('./configHandler')
PaneHandler = require('./paneHandler')

fspath = require 'path'

AddDialog = null

module.exports =
class ModuleHandler extends PaneHandler
  constructor: (pane, parent) ->
    self = this

    @path = DirectoryHandler.resolvePath("client/modules", false, true)
    @pane = pane

    # add controls
    label = document.createElement('span')
    label.innerText = "Module "
    parent.appendChild(label)

    # add button to add a module
    @appendButton(parent, "NEW", @createModule.bind(this))

    # add combobox with all modules
    @moduleList = document.createElement('select')
    @moduleList.classList.add('form-control')
    @moduleList.classList.add('tomi')
    @moduleList.onchange = @loadModule.bind(this)
    parent.appendChild(@moduleList)


    # add top level element in which we display the selected modules
    @container = document.createElement('ol')
    @container.classList.add('entries', 'list-tree')
    parent.appendChild(@container)

    dir = atom.project.resolvePath(@path)
    unless atom.project.contains(dir)
      atom.notifications.addWarning("This is not a Mantra project, " + @path + " directory missing!")

    @moduleDir = atom.project.getDirectories()[0].getSubdirectory(@path)
    @moduleDir.onDidChange(() -> self.load())

    @load()
  load: () ->
    # clear all loaded modules
    @clear(@moduleList)

    # find all modules in the directory
    files = @moduleDir.getEntriesSync()

    for file in files
      if file.isDirectory()
        ModuleHandler.addModule(@moduleList, file, file.getBaseName() == @selectedModule)

    # $(@container).on 'click', '.list-item[is=tree-view-file]', ->
    #   atom.workspace.open(this.file.path)

    @moduleList.onchange()

  createModule: ->
    path = DirectoryHandler.resolvePath("client/modules", true, true)

    AddDialog ?= require './add-module-dialog'
    dialog = new AddDialog(path,
      null,
      "module")

    self = this
    dialog.on "module-created", (event, newPath) ->
      name = fspath.basename(newPath)

      # set selected module
      self.selectedModule = name

      # reload modules
      self.load()

      # find the name of the new module
      [rootProjectPath, relativeDirectoryPath] = atom.project.relativizePath(newPath)

      # load this pane
      self.clear(self.container)
      self.loadPane(self.pane, relativeDirectoryPath, self.container, true)

      # execute actions on module
      template = Config.template('client')
      DirectoryHandler.executeActions(newPath, template)

      # modify main.js
      # mainFile = DirectoryHandler.resolvePath("client/main.$lang", true, true)
      #
      # DirectoryHandler.replaceInFile(mainFile, [
      #     /(import \{createApp\} from ['"]mantra-core['"];)/, "$1\nimport " + name  + "Module from \"./modules/" + name + "\";",
      #     "app.init();", "app.loadModule(" + name + "Module);\napp.init();"
      # ])

    dialog.attach()

    return false

  loadModule: (event) ->
    @clear(@container)

    sel = @moduleList
    unless sel.selectedOptions[0]
      return

    selectedPath = sel.selectedOptions[0].file.path
    [rootProjectPath, relativeDirectoryPath] = atom.project.relativizePath(selectedPath)

    @loadPane(@pane, relativeDirectoryPath, @container, false)

  loadPane: (pane, dir, container, createEntries) ->
    for item in pane.structure
      if item.directory
        @checkDirectory(item, dir, container, createEntries)
      if item.file
        @checkFile(item, dir, container, createEntries)

    #
    # #new DirectoryHandler("Actions", @container, relativeDirectoryPath + "/actions", "action.js")
    # #new DirectoryHandler("Components", @container, relativeDirectoryPath + "/components", "component.js")
    # #new DirectoryHandler("Configs", @container, relativeDirectoryPath + "/configs")
    # #new DirectoryHandler("Containers", @container, relativeDirectoryPath + "/containers", "container.js")
    #
    # self = this
    # new DirectoryHandler(null, @container, relativeDirectoryPath, null, {
    #   "actions":
    #     "file": "action",
    #     "callback": (e, newPath) -> self.updateAction(e, newPath)
    #   "components":
    #     "file": "component"
    #     "options": ["Class Name"]
    #   "containers":
    #     "file": "container"
    #     "options": ["Component Name", "Parameters", "Subscription", "Collection"]
    # })

  updateAction: (e, newPath) ->
    # modify main.js
    name = fspath.basename(newPath, ".js")
    name = fspath.basename(name, ".ts")

    dir = fspath.dirname(newPath)
    indexFile = fspath.join(dir, "index." + Config.get("language"))

    DirectoryHandler.replaceInFile(indexFile, [
        "const actions = {", "import " + name  + " from \"./" + name + "\";\nconst actions = {",
        "const actions = {", "const actions = {\n  " + name + ","
    ])

  clear: (elem) ->
    while (elem.firstChild)
      elem.removeChild(elem.firstChild)

  @addModule: (parent, file, selected) ->
    listItem = document.createElement('option')
    listItem.file = file
    listItem.innerText = file.getBaseName()
    if selected
      listItem.setAttribute('selected', selected)
    parent.appendChild listItem

  appendButton: (parent, text, func) ->
    button = document.createElement('button')
    button.classList.add('pull-right', 'mantra', 'addButton')

    buttonSpan = document.createElement('div')
    buttonSpan.innerText = text
    buttonSpan.classList.add('mantra', 'addText')

    button.appendChild(buttonSpan)
    button.onclick = func

    parent.appendChild button
