{$} = require 'space-pen'
fs = require("fs-plus")

AddDialog = null

module.exports =
class DirectoryHandler
  @selectedElement: null

  constructor: (name, parent, path, template, childTemplates) ->
    self = this
    @name = name
    @template = template
    @childTemplates = childTemplates
    @path = path

    func = null;
    if (template)
      func = @create.bind(this, template, name, path)

    @container = DirectoryHandler.createList(name, parent, func)

    dir = atom.project.resolvePath(path)
    unless fs.existsSync(dir)
      atom.notifications.addWarning("This is not a Mantra project, " + path + " directory missing!");

    @methodDir = atom.project.getDirectories()[0].getSubdirectory(path)
    @methodDir.onDidChange(() -> self.load())

    @load()

  load: () ->
    @clear(@container)
    @loadDirectory(@methodDir, @container)

    $(@container).on 'click', '.list-item[is=tree-view-file]', (e) ->
      atom.workspace.open(this.file.path)
      this.getPath = () -> return this.file.path # TODO: Check other options
      DirectoryHandler.select(this)

    $(@container).on 'contextmenu', '.list-item[is=tree-view-file]', (e) ->
      e.stopPropagation()
      e.preventDefault()

  loadDirectory: (dir, container) ->
    files = dir.getEntriesSync()

    for file in files
      if (file.isFile())
        if file.getBaseName()[0] == "."
          continue
        DirectoryHandler.addFile(container, file)
      if (file.isDirectory())
        name = file.getBaseName()
        [rootProjectPath, relativeDirectoryPath] = atom.project.relativizePath(file.path)

        if (@childTemplates)
          # this is template directory so create a new directory handler
          new DirectoryHandler(name, container, relativeDirectoryPath, @childTemplates[name], @childTemplates)
        else
          new DirectoryHandler(name, container, relativeDirectoryPath)

  create: (template, name, path) ->
    path = atom.project.resolvePath(path)

    AddDialog ?= require './add-module-dialog'

    lang = "js";
    if (atom.config.get('mantrajs.language') == "Typescript")
      lang = "ts"

    dialog = new AddDialog(path,
      DirectoryHandler.resolvePath("/templates/$lang/parts"),
      DirectoryHandler.resolvePath("template.$lang"),
      name.toLowerCase())

    dialog.attach()

    return false

  clear: (elem) ->
    while (elem.firstChild)
      elem.removeChild(elem.firstChild);

  @resolvePath: (path) ->
    lang = "js";
    if (atom.config.get('mantrajs.language') == "Typescript")
      lang = "ts"
    return path.replace("$lang", lang)

  @select: (elem) ->
    if elem == DirectoryHandler.selectedElement
      return

    if DirectoryHandler.selectedElement
      DirectoryHandler.selectedElement?.classList.remove 'mselected'

    DirectoryHandler.selectedElement = elem
    DirectoryHandler.selectedElement.classList.add 'selected'
    DirectoryHandler.selectedElement.classList.add 'mselected'


  @addFile: (parent, file) ->
    listItem = document.createElement('li')
    listItem.classList.add('file', 'list-item')
    listItem.setAttribute('is', 'tree-view-file')
    listItem.file = file
    listItemName = document.createElement('span')
    listItemName.innerText = file.getBaseName()
    listItemName.classList.add('name', 'icon', 'icon-file-text')
    listItemName.setAttribute('data-path', file)
    listItemName.setAttribute('data-name', file)
    listItem.appendChild listItemName

    parent.appendChild listItem

  @createList: (headerText, parent, func) ->

    client = document.createElement('li');

    # header

    if headerText
      clientHeader = document.createElement('div')
      clientHeader.classList.add('header', 'list-item')

      clientSpan = document.createElement('span')
      clientSpan.innerText = headerText
      clientSpan.classList.add('name', 'icon', 'icon-file-directory')

      clientHeader.appendChild clientSpan
      client.appendChild clientHeader

      #tests are collapsed, everything else is expanded
      if headerText == "tests"
        client.classList.add('mantra', 'list-nested-item', 'collapsed')
      else
        client.classList.add('mantra', 'list-nested-item', 'expanded')

      if func
        button = document.createElement('button')
        button.classList.add('pull-right', 'mantra', 'addButton')

        buttonSpan = document.createElement('div')
        buttonSpan.innerText = "+"
        buttonSpan.classList.add('mantra', 'addText')

        button.appendChild(buttonSpan)
        button.onclick = (e) ->
          e.stopPropagation()
          e.preventDefault()
          return func()


        clientHeader.appendChild button


    clientList = document.createElement('ol')
    clientList.classList.add('entries', 'list-tree')

    client.appendChild clientList

    parent.appendChild client

    $(clientHeader).on 'click', ->
      nested = $(this).closest('.list-nested-item')
      nested.toggleClass('expanded')
      nested.toggleClass('collapsed')

    $(clientHeader).on 'contextmenu', (e) ->
      e.stopPropagation()
      e.preventDefault()

    return clientList
