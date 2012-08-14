## javascript-brunch
Adds JavaScript support to
[brunch](http://brunch.io).

## Usage
Add `"javascript-brunch": "x.y.z"` to `package.json` of your brunch app.

Pick a plugin version that corresponds to your minor (y) brunch version.

If you want to use git version of plugin, add
`"javascript-brunch": "git+ssh://git@github.com:brunch/javascript-brunch.git"`.

## Config

    exports.config =
      files:
        javascripts:
        
          # enable javascript lint
          lint:
            linter: 'jshint' # optional. default=jshint. options: jshint | jslint
            filter: /^app/ # optional
            
          # also valid:
          #lint: true
          #or
          #lint: /^app/
    
          # copy source javascript to public folder (under /src)
          # this is useful for debugging, to load all files individually
          # (only files with newer modification date get copied)
          sourceFiles:
            copy: /^app/ # filter by path, to copy all of them use copy: true
            
            # wrapper for source files. optional. (in this example we don't add lines at the top, so error line numbers remain accurate)
            wrapper: (path, data) -> "(function(){'use strict';"+(if data.slice(0,1)=='\n' then '' else '\n')+"#{data}\n})();" 
    
