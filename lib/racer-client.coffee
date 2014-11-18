{BufferedProcess} = require 'atom'
_ = require "underscore-plus"
pathwatcher = require "pathwatcher"
tmp = require "tmp"

module.exports =
class RacerClient
  racer_bin: null
  rust_src: null
  project_path: null
  candidates: null

  check_completion: (editor, row, col, cb) ->
    process.env.RUST_SRC_PATH = @process_env_vars()

    @create_temp (tempfilepath, tempfile) =>
      if not tempfilepath
        cb []
        return

      text = editor.getText()
      tempfile.write(text)

      options =
        command: @racer_bin
        args: ["complete", row + 1, col, tempfilepath]
        stdout: (output) =>
          parsed = @parse_single(output)
          @candidates.push(parsed) if parsed
          return
        exit: (code) =>
          @candidates = (_.uniq(_.compact(_.flatten(@candidates)))).sort()
          cb @candidates
          return

      @candidates = []
      process = new BufferedProcess(options)
      return
    return

  process_env_vars: ->
    @racer_bin = @racer_bin or atom.config.get("racer.racerBinPath")
    @rust_src = @rust_src or atom.config.get("racer.rustSrcPath")
    @project_path = @project_path or atom.project.getPath()
    "#{@rust_src}:#{@project_path}"

  parse_single: (line) ->
    matches = []
    rcrgex = /MATCH (\w*)\,.*\n/mg
    while match = rcrgex.exec(line)
      matches.push(match[1]) if match?.length > 1
    return matches

  create_temp: (cb) ->
    tmp.file { postfix: ".racertmp" }, (err, path) =>
      if err
        console.error(err)
        cb null
      cb path, new pathwatcher.File(path)
      return
    return
