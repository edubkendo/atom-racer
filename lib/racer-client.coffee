{BufferedProcess} = require 'atom'
_ = require 'underscore-plus'
fs = require 'fs'
temp = require('temp').track()
path = require 'path'

module.exports =
class RacerClient
  racer_bin: null
  rust_src: null
  project_path: null
  candidates: null

  check_generator = (racer_action) ->
    (editor, row, col, cb) ->
      if !@process_env_vars()
        atom.notifications.addFatalError "Atom racer is not properly configured."
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
          fs.close(info.fd);
          options =
            command: @racer_bin
            args: [racer_action, row + 1, col, tempFilePath]
            stdout: (output) =>
              parsed = @parse_single(output)
              @candidates.push(parsed) if parsed
              return
            exit: (code) =>
              @candidates = _.uniq(_.compact(_.flatten(@candidates)), (e) => e.word + e.file + e.type )
              cb @candidates
              temp.cleanup()
              if code == 3221225781
                atom.notifications.addWarning "racer could not find a required DLL; copy racer to your Rust bin directory"
              else if code != 0
                atom.notifications.addWarning "racer returned a non-zero exit code: #{code}"
              return

          @candidates = []
          process = new BufferedProcess(options)
          return
      return

  check_completion: check_generator("complete")

  check_definition: check_generator("find-definition")

  process_env_vars: ->
    config_is_valid = true

    if !@racer_bin?
      conf_bin = atom.config.get("racer.racerBinPath")
      if conf_bin
        try
          stats = fs.statSync(conf_bin);
          if stats?.isFile()
            @racer_bin = conf_bin
    if !@racer_bin?
      config_is_valid = false
      atom.notifications.addFatalError "racer.racerBinPath is not set in your config."

    if !@rust_src?
      conf_src = atom.config.get("racer.rustSrcPath")
      if conf_src
        try
          stats = fs.statSync(conf_src);
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
    fnrgx = /( -> .*)/
    while match = rcrgex.exec(line)
      fnmatch = match[6].match(fnrgx)
      if match?.length > 4
        candidate = {word: match[1] + (fnmatch && fnmatch[0] || ""), line: parseInt(match[2], 10), column: parseInt(match[3], 10), filePath: match[4], file: "this", type: match[5]}
        file_name = path.basename(match[4])
        if path.extname(match[4]).indexOf(".racertmp") == 0
          candidate.filePath = path.dirname(match[4]) + path.sep + file_name.match(/\._(.*)\.racertmp.*?$/)[1]
        else
          candidate.file = file_name
        matches.push(candidate)
    return matches
