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

module.exports = class JavaScriptCompiler
  brunchPlugin: yes
  type: 'javascript'
  extension: 'js'

  constructor: (@config) ->    
    null

  lint: (data, path, callback) ->
    try
      lint = @config.files.javascripts.lint
      if lint == true or (lint instanceof RegExp and lint.test(path))
        jslint = require('jslint')
        if not jslint(data)
          output = []
          formatError = (error) ->
            if not error
              return '(more)'
            else
              return "#{error.reason} #{error.id || ''} at line #{error.line}, column #{error.character}" +
                if error.evidence then "\n\n  #{error.evidence}\n" else "\n" 
          output.push(formatError(error)) for error in jslint.errors
          output.unshift('\n')
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
        mkdir(_path.dirname(outputPath))
        sdata = data
        if typeof wrapper == 'function'
          sdata = wrapper(path, sdata)  
        fs.writeFileSync(outputPath, sdata)
      callback null, data
    catch error
      callback error
