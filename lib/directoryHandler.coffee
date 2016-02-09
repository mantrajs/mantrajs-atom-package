{$} = require 'space-pen'

AddDialog = null

module.exports =
class DirectoryHandler
  constructor: (name, parent, path, template) ->
    self = this
    @name = name
    @template = template
    @path = path

    func = null;
    if (template)
      func = @create.bind(this)


    @container = DirectoryHandler.createList(name, parent, func)

    dir = atom.project.resolvePath(path)
    unless atom.project.contains(dir)
      atom.notifications.addWarning("This is not a Mantra project, " + path + " directory missing!");

    @methodDir = atom.project.getDirectories()[0].getSubdirectory(path)
    @methodDir.onDidChange(() -> self.load())

    @load()

  load: () ->
    @clear(@container)
    @loadDirectory(@methodDir, @container)

    $(@container).on 'click', '.list-item[is=tree-view-file]', ->
      atom.workspace.open(this.file.path)

  loadDirectory: (dir, container) ->
    files = dir.getEntriesSync()

    for file in files
      if (file.isFile())
        DirectoryHandler.addFile(container, file)
      if (file.isDirectory())
        newDir = DirectoryHandler.createList(file.getBaseName(), container)
        @loadDirectory(file, newDir)

  create: ->
    path = atom.project.resolvePath(@path)

    AddDialog ?= require './add-module-dialog'
    dialog = new AddDialog(path, "/templates/parts", @template, @name.toLowerCase())

    dialog.attach()

    return false

  clear: (elem) ->
    while (elem.firstChild)
      elem.removeChild(elem.firstChild);

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
    clientHeader = document.createElement('div')
    clientHeader.classList.add('header', 'list-item')

    clientSpan = document.createElement('span')
    clientSpan.innerText = headerText
    clientSpan.classList.add('name', 'icon', 'icon-file-directory')

    clientHeader.appendChild clientSpan

    client = document.createElement('li');

    #tests are collapsed, everything else is expanded
    if headerText == "tests"
      client.classList.add('mantra', 'list-nested-item', 'collapsed')
    else
      client.classList.add('mantra', 'list-nested-item', 'expanded')

    client.appendChild clientHeader

    clientList = document.createElement('ol')
    clientList.classList.add('entries', 'list-tree')

    client.appendChild clientList

    parent.appendChild client

    $(clientHeader).on 'click', ->
      nested = $(this).closest('.list-nested-item')
      nested.toggleClass('expanded')
      nested.toggleClass('collapsed')

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

    return clientList
