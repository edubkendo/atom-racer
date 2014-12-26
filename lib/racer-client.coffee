{spawnSync} = require 'child_process'
_ = require 'underscore-plus'
fs = require 'fs'
temp = require('temp').track()
path = require 'path'

module.exports =
class RacerClient
  racer_bin: null
  rust_src: null
  project_path: null

  check_completion: (editor, row, col) ->
    tempFilePath = temp.openSync({ suffix: ".racertmp" }).path
    return unless tempFilePath

    text = editor.getText()
    fs.writeFileSync tempFilePath, text

    process.env.RUST_SRC_PATH = @process_env_vars()

    command = @racer_bin
    args = ["complete", row + 1, col, tempFilePath]
    options =
      encoding: 'utf8'
    result = spawnSync(command, args, options)
    if result.error?
      console.error 'Error: ' + result.error
      return
    if not result?.stdout? then return

    candidates = []
    parsed = @parse_single(result.stdout)
    candidates.push(parsed) if parsed

    candidates = _.uniq(_.compact(_.flatten(candidates)), (e) => e.word+e.file+e.type )
    return candidates

  process_env_vars: ->
    @racer_bin = @racer_bin or atom.config.get("racer.racerBinPath")
    @rust_src = @rust_src or atom.config.get("racer.rustSrcPath")
    @project_path = @project_path or atom.project.getPath()
    separator = if process.platform is 'win32' then ';' else ':'
    "#{@rust_src}#{separator}#{@project_path}"

  parse_single: (line) ->
    matches = []
    rcrgex = /MATCH (\w*)\,\d*\,\d*\,([^\,]*)\,(\w*)\,.*\n/mg
    while match = rcrgex.exec(line)
      if match?.length > 2
        candidate = {word:match[1], file:"this", type:match[3]}
        candidate.file = path.basename(match[2]) if path.extname(match[2]) != ".racertmp"
        matches.push(candidate)
    return matches
