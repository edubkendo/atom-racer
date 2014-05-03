module Atom
  class BufProcess
    include Native

    def initialize(command, args, stdout, exitcb)
      options = `{ command: #{command}, args: #{args}, stdout: #{stdout}, exit: #{exitcb} }`
      other_atom = `require("atom")`
      super(`new #{other_atom}.BufferedProcess(#{options})`)
    end

    alias_native :kill

  end
end
