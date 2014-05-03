module Atom
  class File
    include Native
    attr_accessor :filepath, :fs, :pathwatcher

    def initialize(filepath)
      @filepath = filepath
      @fs = Native(`require("fs-plus")`)
      @pathwatcher = `require("pathwatcher")`
      super(`new #{@pathwatcher}.File(#{@filepath})`)
    end

    alias_native :base_name, :getBaseName
    alias_native :digest, :getDigest
    alias_native :path, :getPath
    alias_native :real_path_sync, :getRealPathSync
    alias_native :directory?, :isDirectory
    alias_native :file?, :isFile
    alias_native :read
    alias_native :write

  end
end
