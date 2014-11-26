{BufferedProcess} = require 'atom'
_ = require "underscore-plus"
pathwatcher = require "pathwatcher"
tmp = require "tmp"
path = require "path"

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
          @candidates = _.uniq(_.compact(_.flatten(@candidates)), (e) => e.word+e.file+e.type )
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
    rcrgex = /MATCH (\w*)\,\d*\,\d*\,([^\,]*)\,(\w*)\,.*\n/mg
    while match = rcrgex.exec(line)
      if match?.length > 2
        candidate = {word:match[1], file:"this", type:match[3]}
        candidate.file = path.basename(match[2]) if path.extname(match[2]) != ".racertmp"
        matches.push(candidate)
    return matches

  create_temp: (cb) ->
    tmp.file { postfix: ".racertmp" }, (err, tmppath) =>
      if err
        console.error(err)
        cb null
      cb tmppath, new pathwatcher.File(tmppath)
      return
    return
