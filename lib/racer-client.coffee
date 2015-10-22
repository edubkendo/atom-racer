# disable max line length because it's annoying
# coffeelint: disable=max_line_length
{BufferedProcess} = require 'atom'
_ = require 'underscore-plus'
fs = require 'fs'
temp = require('temp').track()
path = require 'path'

module.exports = class RacerClient
  constructor: ->
    @racer_bin = null
    @rust_src = null
    @project_path = null
    @candidates = null
    @last_stderr = null
    @last_process = null

  check_generator: (racer_action, editor, row, col, cb) ->
    if !@process_env_vars()
      # atom.notifications.addFatalError "Atom racer is not properly configured."
      cb null
      return

    temp_folder_path = path.dirname(editor.getPath())
    original_file_name = path.basename(editor.getPath())
    # temp_folder_path will be '.' for unsaved files
    if temp_folder_path == "."
      temp_folder_path = @project_path

    tempOptions =
      prefix: "._" + original_file_name + ".racertmp"
      dir: temp_folder_path

    temp.open tempOptions, (err, info) =>
      if err
        atom.notifications.addFatalError "Unable to create temp file: #{err}"
        cb null
      else
        tempFilePath = info.path
        cb null unless tempFilePath

        text = editor.getText()
        fs.writeFileSync tempFilePath, text
        fs.close(info.fd)

        console.log "#{@racer_bin} #{racer_action} #{row + 1} #{col} #{tempFilePath}"

        options =
          command: @racer_bin
          args: [racer_action, row + 1, col, tempFilePath]
          stdout: (output) =>
            return unless this_process == @latest_process
            parsed = @parse_single(output)
            @candidates.push(parsed) if parsed
            return
          stderr: (output) =>
            return unless this_process == @latest_process
            @last_stderr = output
            return
          exit: (code) =>
            return unless this_process == @latest_process
            @candidates = _.uniq(_.compact(_.flatten(@candidates)), (e) -> e.word + e.file + e.type )
            cb @candidates
            temp.cleanup()
            if code == 3221225781
              atom.notifications.addWarning "racer could not find a required DLL; copy racer to your Rust bin directory"
            else if code != 0
              atom.notifications.addWarning "racer returned a non-zero exit code: #{code}\n#{@last_stderr}"
            return

        @candidates = []
        @latest_process = this_process = new BufferedProcess(options)
        return
    return

  check_completion: (editor, row, col, cb) ->
    @check_generator("complete", editor, row, col, cb)

  check_definition: (editor, row, col, cb) ->
    @check_generator("find-definition", editor, row, col, cb)

  find_racer_path: () ->
    for p in process.env.PATH.split(':')
      pArray = p.split('/')
      if pArray[pArray.length - 1] == 'racer'
        return p

  process_env_vars: ->
    # This is where the env varialbes are set
    config_is_valid = true

    atom.config.set('racer.racerBinPath', @find_racer_path())

    if !@racer_bin?
      conf_bin = atom.config.get("racer.racerBinPath")

      if conf_bin?
        try
          stats = fs.statSync conf_bin
          if stats?.isFile()
            @racer_bin = conf_bin

    if !@racer_bin?
      config_is_valid = false
      atom.notifications.addFatalError "racer.racerBinPath is not set in your config."

    if !@rust_src?
      conf_src = atom.config.get("racer.rustSrcPath")
      if conf_src
        try
          stats = fs.statSync conf_src
          if stats?.isDirectory()
            @rust_src = conf_src
    if !@rust_src?
      config_is_valid = false
      atom.notifications.addFatalError "racer.rustSrcPath is not set in your config."

    if config_is_valid
      process.env.RUST_SRC_PATH = @rust_src

    return config_is_valid

  parse_single: (line) ->
    matches = []
    rcrgex = /MATCH (\w*)\,(\d*)\,(\d*)\,([^\,]*)\,(\w*)\,(.*)\n/mg
    while match = rcrgex.exec(line)
      if match?.length > 4
        candidate =
          word: match[1],
          line: parseInt(match[2], 10),
          column: parseInt(match[3], 10),
          filePath: match[4],
          file: "this",
          type: match[5],
          context: match[6]
        file_name = path.basename(match[4])

        if path.extname(match[4]).indexOf(".racertmp") == 0
          candidate.filePath = path.dirname(match[4]) + path.sep + file_name.match(/\._(.*)\.racertmp.*?$/)[1]

        else
          candidate.file = file_name

        matches.push(candidate)
    return matches
