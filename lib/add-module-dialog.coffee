path = require 'path'
fs = require 'fs-extra'
fso = require 'fs'
Dialog = require './dialog'
DirectoryHandler = require './directoryHandler'
Config = require './configHandler'

module.exports =
class AddDialog extends Dialog
  constructor: (initialPath, template, title) ->

    # if fs.isFileSync(initialPath)
    #   directoryPath = path.dirname(initialPath)
    # else
    directoryPath = initialPath

    @template = template
    @title = title

    relativeDirectoryPath = directoryPath
    [@rootProjectPath, relativeDirectoryPath] = atom.project.relativizePath(directoryPath)
    relativeDirectoryPath += path.sep if relativeDirectoryPath.length > 0

    if template
      templateText = template.text
      options = template.placeholders
      console.log("Init from custom template ...")

    super
      prompt: "Enter the name of the new " + title
      initialPath: relativeDirectoryPath
      select: false
      iconClass: 'icon-file-directory-create'
      options: options
      templateText: templateText

  onConfirm: (newPath) ->
    newPath = atom.project.resolvePath(newPath)

    return unless newPath

    try
      if fs.existsSync(newPath)
        @showError("'#{newPath}' already exists.")
      else
        # copy all template files and create all directories
        if @template
          fs.writeFileSync(newPath, @templateView.text())

        @trigger 'module-created', [newPath]
        @cancel()
    catch error
      @showError("#{error.message}.")
