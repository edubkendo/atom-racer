require "atom/file"

module Racer
  class Client
    `Suggestion = require("autocomplete-plus").Suggestion`
    attr_accessor :atom, :editor, :text, :tempfile, :file, :filepath, :candidates

    def initialize(atom)
      @atom = atom
    end

    def completions(editor, row, col, cb)
      @editor = editor
      @candidates = []
      create_temp -> tempfile {
        @tempfile = tempfile
        @text = @editor.getText
        @tempfile.write(@text)
        `process.env.RUST_SRC_PATH = "/Users/ericwest/installs/rust/src/"`

        command = "/Users/ericwest/git/community/racer/bin/racer"
        args = ["complete", row + 1, col, @filepath]
        stdout = -> output {
          parsed = parse_single(output)
          @candidates << parsed if parsed
        }
        stderr = -> arg { puts arg }
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

      if last_char =~ /::/
        #cb.call(`[new Suggestion(this, {word: "cool", label: "awesome"})]`)
        completions @editor, row, col, -> suggestions {
          cb.call( `null`, suggestions.to_n)
        }
      else
        cb.call(`null`,`[]`)
      end
    end

    def parse_single(line)
      if matches = line.match(/^MATCH (\w*)\,/)
        matches.captures.first
      end
    end

    def parse_completions(output)
      output.split("\n").map {|line|
        if matches = line.match(/^MATCH (\w*)\,/)
          matches.captures.first
        end
      }.compact
    end

    def arrange_suggestions(candidates)
      candidates.map do |candidate|
        Native(`new Suggestion(this, { word: #{candidate}, label: #{candidate} })`)
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
