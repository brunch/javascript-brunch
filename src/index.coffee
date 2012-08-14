fs = require('fs')
_path = require('path')

mkdir = (path) ->
  dirs = path.split(/[\/\\]/g)
  dir = dirs[0]
  while dirs.length
    exists = false

    try 
      if(fs.statSync(dir).isDirectory())
        exists = true
    catch error
      exists = false

    if !exists
      fs.mkdirSync(dir)
    dirs.shift()
    if (dirs.length)
      dir+='/'+dirs[0]

isOlder = (path1, path2) ->
  fs.statSync(path1).mtime < fs.statSync(path2).mtime

module.exports = class JavaScriptCompiler
  brunchPlugin: yes
  type: 'javascript'
  extension: 'js'

  constructor: (@config) ->    
    @linting = 
      config: @config.files.javascripts.lint
    if @linting.config == true
      @linting.config = {}
    if @linting.config instanceof RegExp
      @linting.config =
        filter: @linting.config
    if @linting.config
      @linting.enabled = true
      @linting.name = @linting.config.linter or 'jshint'
      switch @linting.name
        when 'jshint' then @linting.linter = require('jshint').JSHINT
        when 'jslint' then @linting.linter = require('jslint')
        else throw new Error("javascript linter not found: #{@linting.name}")
      @linting.filter = @linting.config.filter or false
    null

  lint: (data, path, callback) ->
    try
      if @linting.enabled and ((@linting.filter instanceof RegExp and @linting.filter.test(path)) or not @linting.filter)
        if not @linting.linter(data)
          output = []
          formatError = (error) ->
            if not error
              return '(more)'
            else
              return "#{error.reason} #{error.id || ''} at line #{error.line}, column #{error.character}" +
                if error.evidence then "\n\n  #{error.evidence}\n" else "\n" 
          output.push(formatError(error)) for error in @linting.linter.errors
          output.unshift("[#{@linting.name}]")
          output.push('\n')
          throw new Error(output.join('\n'))
      callback null, data
    catch error
      callback error

  compile: (data, path, callback) ->
    try
      copySource = @config.files.javascripts.sourceFiles and @config.files.javascripts.sourceFiles.copy
      if copySource == true or (copySource instanceof RegExp and copySource.test(path))
        srcFolder = @config.files.javascripts.sourceFiles.folderName or 'src'
        wrapper = @config.files.javascripts.sourceFiles.wrapper
        outputPath = @config.paths.public+'/'+srcFolder+'/'+path;
        if (isOlder(outputPath, path))
          mkdir(_path.dirname(outputPath))
          sdata = data
          if typeof wrapper == 'function'
            sdata = wrapper(path, sdata)
          fs.writeFileSync(outputPath, sdata)
      callback null, data
    catch error
      callback error
