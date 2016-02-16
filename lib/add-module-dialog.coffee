path = require 'path'
fs = require 'fs-extra'
fso = require 'fs'
Dialog = require './dialog'
DirectoryHandler = require './directoryHandler'
Config = require './configHandler'

module.exports =
class AddDialog extends Dialog
  constructor: (initialPath, templatePath, fileName, title, options) ->

    # if fs.isFileSync(initialPath)
    #   directoryPath = path.dirname(initialPath)
    # else
    directoryPath = initialPath

    @templatePath = templatePath
    @fileName = fileName
    @title = title

    if (@fileName)
      @baseName = path.basename(@fileName, ".ts")
      @baseName = path.basename(@baseName, ".js")
      title = @baseName

    relativeDirectoryPath = directoryPath
    [@rootProjectPath, relativeDirectoryPath] = atom.project.relativizePath(directoryPath)
    relativeDirectoryPath += path.sep if relativeDirectoryPath.length > 0

    if templatePath && fileName
      customTemplate = @getCustomTemplate(@baseName)

      if customTemplate
        templateText = customTemplate.content
        options = customTemplate.placeHolders
        console.log("Init from custom template ...")
      else
        tp = atom.packages.resolvePackagePath("mantrajs/" + templatePath) + "/" + fileName
        templateText = fso.readFileSync(tp, 'utf8')

    super
      prompt: "Enter the name of the new " + title
      initialPath: relativeDirectoryPath
      select: false
      iconClass: 'icon-file-directory-create'
      options: options
      templateText: templateText

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
        fromPath = atom.packages.resolvePackagePath("mantrajs/" + @templatePath) # TODO: use path.combine
        if @fileName
          fs.writeFileSync(newPath, @templateView.text())
          #fromPath += "/" + @fileName
        else
          customTemplate = @getCustomTemplate('module')
          if @title == 'module' && customTemplate
            @createModuleFromConfig(newPath, customTemplate)
          else
            fs.copySync(fromPath, newPath)

        @trigger 'module-created', [newPath]
        @cancel()
    catch error
      @showError("#{error.message}.")

  getCustomTemplate: (name) ->
    cf = Config.get('templates')
    lang = Config.get('language')
    if cf && cf[lang] && cf[lang][name]
      return cf[lang][name]
    return null

  createModuleFromConfig: (newPath, template) ->
    for directory in template
      p = path.join(newPath, directory.path)
      fs.ensureDirSync(p)

      if directory.files && directory.files.length
        for file in directory.files
          pf = path.join(p, file.name)
          fs.outputFile(pf, file.content)
          console.log "Created custom: " + pf
