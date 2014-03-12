path = require 'path'

module.exports = ->
  class YellExtension

    fs: ->
      category: 'upcased'
      extract: true
      detect: (f) ->
        # remove extension from path so you can detect files like FOO.bar
        ext = path.extname(f.relative)
        filename = path.basename(f.relative, ext)

        # check for upcased filenames
        filename == filename.toUpperCase()

    compile_hooks: ->
      category: 'upcased'
      after_file: (ctx) =>
        ctx.content = ctx.content.toUpperCase()
