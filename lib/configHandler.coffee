_ = require 'lodash'
path = require 'path'
fs = require 'fs'
YAML = require('yamljs')

module.exports =
class ConfigHandler
  @userConfig: null
  @systemConfig: null
  @template: (name) ->
    templates = ConfigHandler.get('templates')
    return _.find(templates, (im) -> im.name == name)
  @reset: ->
    ConfigHandler.userConfig = null
    ConfigHandler.systemConfig = null
  @path: (filePath) ->
    return path.join ConfigHandler.get('root'), filePath
  @get: (key) ->
    if ConfigHandler.systemConfig == null
      packagePath = atom.packages.resolvePackagePath("mantrajs")
      configPath = path.join packagePath, 'mantra.yaml'
      try
        ConfigHandler.systemConfig = YAML.load(configPath)
      catch e
        atom.notifications.addError "Error parsing system config: " + e.message
    if ConfigHandler.userConfig == null
      configPath = atom.project.resolvePath("mantra.yaml")
      try
        fs.accessSync configPath, fs.F_OK
        ConfigHandler.userConfig = YAML.load(configPath)
      catch e
        atom.notifications.addError "Error parsing system config: " + e.message
    # return the value
    return if ConfigHandler.userConfig[key] then ConfigHandler.userConfig[key] else ConfigHandler.systemConfig[key]
