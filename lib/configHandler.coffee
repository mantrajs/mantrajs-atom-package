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
  @settingFile: () ->
    setting = atom.config.get("mantrajs.projectType")
    console.log(setting)
    switch setting
      when "Classic Mantra (TS)" then return "configs/mantra-ts.yaml"
      when "Mantra (TS) - No Stories" then return "configs/mantra-ts-ns.yaml"
      else return "configs/mantra-js.yaml"
  @get: (key) ->
    if ConfigHandler.systemConfig == null
      packagePath = atom.packages.resolvePackagePath("mantrajs")
      configPath = path.join packagePath, ConfigHandler.settingFile()
      try
        ConfigHandler.systemConfig = YAML.load(configPath)
      catch e
        atom.notifications.addError "Error parsing system config: " + e.message
    if ConfigHandler.userConfig == null
      configPath = atom.project.resolvePath("mantra.yaml")
      try
        fs.accessSync configPath, fs.F_OK
        try
          ConfigHandler.userConfig = YAML.load(configPath)
        catch e
          atom.notifications.addError "Error parsing user config: " + e.message
      catch e
        ConfigHandler.userConfig = {}
    # return the value
    return if ConfigHandler.userConfig[key] then ConfigHandler.userConfig[key] else ConfigHandler.systemConfig[key]
