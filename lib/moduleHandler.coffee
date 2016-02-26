{$} = require 'space-pen'
DirectoryHandler = require('./directoryHandler')
Config = require('./configHandler')

fspath = require 'path'

AddDialog = null

module.exports =
class ModuleHandler
  constructor: (parent) ->
    self = this

    @path = DirectoryHandler.resolvePath("client/modules", false, true)

    # add controls
    label = document.createElement('span')
    label.innerText = "Module "
    parent.appendChild(label)

    # add button to add a module
    @appendButton(parent, "NEW", @createModule)

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
    @clear(@moduleList)

    files = @moduleDir.getEntriesSync()

    for file in files
      if file.isDirectory()
        ModuleHandler.addModule(@moduleList, file)

    # $(@container).on 'click', '.list-item[is=tree-view-file]', ->
    #   atom.workspace.open(this.file.path)

    @moduleList.onchange()

  createModule: ->
    path = DirectoryHandler.resolvePath("client/modules", true, true)

    AddDialog ?= require './add-module-dialog'
    dialog = new AddDialog(path,
      DirectoryHandler.resolvePath("/templates/$lang/parts/module"),
      null,
      "module")

    dialog.on "module-created", (event, newPath) ->
      dialog.load()

      # find the name of the new module
      name = fspath.basename(newPath)

      # modify main.js
      mainFile = DirectoryHandler.resolvePath("client/main.$lang", true, true)

      DirectoryHandler.replaceInFile(mainFile, [
          /(import \{createApp\} from ['"]mantra-core['"];)/, "$1\nimport " + name  + "Module from \"./modules/" + name + "\";",
          "app.init();", "app.loadModule(" + name + "Module);\napp.init();"
      ])

    dialog.attach()

    return false

  loadModule: (event) ->
    @clear(@container)

    sel = @moduleList
    unless sel.selectedOptions[0]
      return

    selectedPath = sel.selectedOptions[0].file.path

    [rootProjectPath, relativeDirectoryPath] = atom.project.relativizePath(selectedPath)

    #new DirectoryHandler("Actions", @container, relativeDirectoryPath + "/actions", "action.js")
    #new DirectoryHandler("Components", @container, relativeDirectoryPath + "/components", "component.js")
    #new DirectoryHandler("Configs", @container, relativeDirectoryPath + "/configs")
    #new DirectoryHandler("Containers", @container, relativeDirectoryPath + "/containers", "container.js")

    self = this
    new DirectoryHandler(null, @container, relativeDirectoryPath, null, {
      "actions":
        "file": "action",
        "callback": (e, newPath) -> self.updateAction(e, newPath)
      "components":
        "file": "component"
        "options": ["Class Name"]
      "containers":
        "file": "container"
        "options": ["Component Name", "Parameters", "Subscription", "Collection"]
    })

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

  @addModule: (parent, file) ->
    listItem = document.createElement('option')
    listItem.file = file
    listItem.innerText = file.getBaseName()
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
