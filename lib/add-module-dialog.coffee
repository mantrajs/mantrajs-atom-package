path = require 'path'
fs = require 'fs-extra'
Dialog = require './dialog'
DirectoryHandler = require './directoryHandler'

module.exports =
class AddDialog extends Dialog
  constructor: (initialPath, templatePath, fileName, title) ->

    # if fs.isFileSync(initialPath)
    #   directoryPath = path.dirname(initialPath)
    # else
    directoryPath = initialPath

    @templatePath = templatePath
    @fileName = fileName

    relativeDirectoryPath = directoryPath
    [@rootProjectPath, relativeDirectoryPath] = atom.project.relativizePath(directoryPath)
    relativeDirectoryPath += path.sep if relativeDirectoryPath.length > 0

    super
      prompt: "Enter the name of the new " + title
      initialPath: relativeDirectoryPath
      select: false
      iconClass: 'icon-file-directory-create'

  onConfirm: (newPath) ->
    newPath = atom.project.resolvePath(newPath)
    # newPath.replace(/\s+$/, '') # Remove trailing whitespace
    # endsWithDirectorySeparator = newPath[newPath.length - 1] is path.sep
    # unless path.isAbsolute(newPath)
    #   unless @rootProjectPath?
    #     @showError("You must open a directory to create a module with a relative path")
    #     return
    #
    #   newPath = path.join(@rootProjectPath, newPath)

    return unless newPath

    try
      if fs.existsSync(newPath)
        @showError("'#{newPath}' already exists.")
      # else if @isCreatingFile
      #   if endsWithDirectorySeparator
      #     @showError("File names must not end with a '#{path.sep}' character.")
      #   else
      #     fs.writeFileSync(newPath, '')
      #     repoForPath(newPath)?.getPathStatus(newPath)
      #     @trigger 'file-created', [newPath]
      #     @close()
      else
        # copy all template files and create all directories
        fromPath = atom.packages.resolvePackagePath("mantrajs/" + @templatePath); # TODO: use path.combine
        if @fileName
          fromPath += "/" + @fileName
        fs.copySync(fromPath, newPath)

        @trigger 'module-created', [newPath]
        @cancel()
    catch error
      @showError("#{error.message}.")
