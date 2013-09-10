module.exports = class JavaScriptCompiler
  brunchPlugin: yes
  type: 'javascript'
  extension: 'js'

  constructor: (@config) ->
    null

  compile: (params, callback) ->
    callback null, params
