module.exports =
class ConfigHandler
  @options: null
  @get: (key) ->
    if ConfigHandler.options == null
      ConfigHandler.options = require(atom.project.resolvePath("mantra.json"))
    if (ConfigHandler.options == null)
      ConfigHandler.options =
        root: ""
        libFolderName: "lib"
    else
      root = ConfigHandler.options.root
      if (root && root.length > 0 && root[root.length-1] != "/")
        ConfigHandler.options.root += "/"
    return ConfigHandler.options[key]
