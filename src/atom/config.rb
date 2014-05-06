module Atom
  class Config
    include Native

    def initialize
      super(`atom.config`)
    end

    alias_native :settings, :getSettings
    alias_native :user_config_path, :getUserConfigPath
    alias_native :default?, :isDefault
    alias_native :observe
    alias_native :push_at_key_path, :pushAtKeyPath
    alias_native :remove_at_key_path, :removeAtKeyPath
    alias_native :restore_default, :restoreDefault
    alias_native :toggle
    alias_native :unobserve
    alias_native :unshift_at_key_path, :unshiftAtKeyPath

  end
end
