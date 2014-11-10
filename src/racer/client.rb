require "atom/file"

module Racer
  class Client
    `Suggestion = require("autocomplete-plus").Suggestion`
    attr_accessor :atom, :editor, :text, :tempfile, :file, :filepath, :candidates, :settings

    def initialize(atom)
      @atom = atom
      @settings = @atom.config
    end

    def process_env_vars
      @rust_src = @rust_src || `atom.config.get("racer.rustSrcPath")`
      @project_path = @project_path || @atom.project.getPath()
      "#{@rust_src}:#{@project_path}"
    end

    def completions(editor, row, col, cb)
      @editor = editor
      @candidates = []
      create_temp -> tempfile {
        @tempfile = tempfile
        @text = @editor.getText
        @tempfile.write(@text)
        RUST_SRC_PATH = process_env_vars()
        `process.env.RUST_SRC_PATH = #{RUST_SRC_PATH}`

        racer_bin = Native(`atom.config.get("racer.racerBinPath")`)
        command = "#{racer_bin}"
        args = ["complete", row + 1, col, @filepath]
        stdout = -> output {
          parsed = parse_single(output)
          @candidates << parsed if parsed
        }
        myexit = -> code {
          @candidates = @candidates.compact.sort
          cb.call(@candidates)
        }
        buffer = Atom::BufProcess.new(command, args, stdout, myexit)
      }
    end

    def check_completion(cb)
      @editor = @atom.workspace.getActiveEditor()
      cursor = Native(@editor.getCursor())
      row = Native(cursor.getBufferRow)
      tbuffer = Native(@editor.getBuffer)
      col = Native(cursor.getBufferColumn)

      last_char = tbuffer.getTextInRange([[row, col -2], [row, col]])

      completions @editor, row, col, -> suggestions {
        cb.call( `null`, suggestions.to_n)
      }

    end

    def parse_single(line)
      matches = line.match(/^MATCH (\w*)\,/)
      if matches && matches.respond_to?(:captures)
        matches.captures.first
      end
    end

    def create_temp(cb)
      tmp = Native(`require("tmp")`)
      tmp.file `{ postfix: ".racertmp" }`, ->(err, path, fd) {
          @filepath = path
          cb.call(Atom::File.new(path))
          raise "Exception while creating tmpfile\n  #{err}" if err
      }
    end

  end
end
