fs = require("fs-extra")
path = require("path")
_ = require 'lodash'

Config = require('./configHandler')
DirectoryHandler = require('./directoryHandler')

module.exports =
class PaneHandler
  constructor: (pane, paneFields) ->
    label = document.createElement('span')
    label.innerText = pane.name
    paneFields.appendChild(label)

    # handle directories
    for item in pane.structure
      if item.directory
        @checkDirectory(item, Config.get('root'), paneFields)
      if item.file
        @checkFile(item, Config.get('root'), paneFields)

  checkDirectory: (item, parentPath, paneFields) ->
    templates = Config.get('templates')
    name = item.directory
    bname = path.basename item.directory
    tname = if item.template then item.template else name
    template = _.find(templates, (im) -> im.name == tname)
    directoryPath = path.join parentPath, name

    # check if directory exists
    DirectoryHandler.checkCreateDirectory(directoryPath)

    # add directory handler
    handler = new DirectoryHandler(
      bname,
      paneFields,
      Config.path(directoryPath),
      template
    )

    # browse directory
    if item.structure
      for child in item.structure
        if child.directory
          @checkDirectory(child, directoryPath, paneFields)
        if child.file
          @checkFile(child, directoryPath, paneFields)

  checkFile: (item, dirPath, paneFields) ->
    templates = Config.get('templates')
    name = item.file
    bname = path.basename item.file
    tname = if item.template then item.template else name
    template = Config.template(tname)
    filePath = path.join dirPath, name
    filePath = atom.project.resolvePath(filePath)

    # we can request whether the file exists
    # we can request whether the file will be displayed inside directory
    if template.create
      try
        fs.accessSync filePath, fs.F_OK
      catch e
        atom.notifications.addInfo "Creating: " + filePath
        fs.writeFile(filePath, template.text, 'utf8', (err) ->
          if err
            atom.notifications.addError err.message
        )

    if template.show
      # we have to find the file in the atom project
      [rootPath, relativePath] = atom.project.relativizePath(filePath)
      # get only the directory path
      dirName = path.dirname relativePath
      # find the firectory
      dir = atom.project.getDirectories()[0].getSubdirectory(dirName)
      # find the file
      fileName = path.basename relativePath
      f = dir.getFile fileName
      # append to the pane
      DirectoryHandler.addFile(paneFields, f)
