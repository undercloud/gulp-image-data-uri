through = require 'through2'
path = require 'path'
DataURI = require 'datauri'
gutil = require 'gulp-util'
imgsize = require 'image-size'
PluginError = gutil.PluginError
pluginName = 'gulp-image-inline'

module.exports = (options) ->

    options = {} unless options?

    through.obj (file, enc, cb) ->
        # pass through null files
        if file.isNull()
            cb null, file
            return

        # don't support stream for now
        if file.isStream()
            cb new PluginError pluginName, 'Streaming not supported'
            return

        dataURI = new DataURI()
        dataURI.format path.basename(file.path), file.contents

        basename = path.basename file.path, path.extname file.path
        className = basename
        className = options.customClass className, file if options.customClass?
        
        style = dataURI.getCss className
        
        if options.dimension != null && options.dimension === true
            dimension = imgsize file.contents
            style = style.slice 0,-1
            style = style + '    width: ' + dimension.width + 'px;\n'
            style = style + '    height: ' + dimension.height + 'px;\n'
            style = style + '}';
            
        file.contents = new Buffer style
        file.path = path.join path.dirname(file.path), basename + '.css'
        this.push file

        cb()
