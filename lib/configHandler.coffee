fs = require 'fs'
cson = require('CSON')

module.exports =
class ConfigHandler
  @options: null
  @get: (key) ->
    if ConfigHandler.options == null
      configPath = atom.project.resolvePath("mantra.cson")
      try
        fs.accessSync configPath, fs.F_OK
        ConfigHandler.options = cson.parseCSONFile(configPath)
      catch e
        console.log e

    if (ConfigHandler.options == null)
      ConfigHandler.options =
        root: atom.config.get("mantrajs.projectRoot")
        libFolderName: atom.config.get("mantrajs.libFolderName")
        language: if atom.config.get("mantrajs.language") == "Javascript" then "js" else "ts"
    else
      root = ConfigHandler.options.root
      if (root && root.length > 0 && root[root.length-1] != "/")
        ConfigHandler.options.root += "/"
    return ConfigHandler.options[key]
