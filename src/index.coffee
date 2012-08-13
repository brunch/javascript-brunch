fs = require('fs')
_path = require('path')
# Example
# 
#   capitalize 'test'
#   # => 'Test'
#
capitalize = (string) ->
  (string[0] or '').toUpperCase() + string[1..]

# Example
# 
#   formatClassName 'twitter_users'
#   # => 'TwitterUsers'
#
formatClassName = (filename) ->
  filename.split('_').map(capitalize).join('')

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
