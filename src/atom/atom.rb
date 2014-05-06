require 'native'
require "./buf_process"
require "./file"
require "./config"

module Atom
  class Atom
    include Native
    native_accessor :clipboard, :context_menu,
    :deserializers, :keymap, :menu, :packages, :project,
    :syntax, :themes, :workspace, :github_auth_token

    def initialize
      super(`atom`)
    end

    def config
      @config || Atom::Config.new()
    end

    # Visually and audibly trigger a beep.
    alias_native :beep

    # Move current window to the center of the screen.
    alias_native :center

    # Close the current window
    alias_native :close

    # Open a confirm dialog
    #
    # @param [Hash] opts the options to create a message.
    # @option opts [String] :message The message to display
    # @option opts [String] :detailed_message The detailed message
    # @option opts [Array<String,Hash>] :buttons Either an array of
    #   strings or a hash where keys are button names and the values are callbacks to invoke when clicked.
    # @returns [Numeric] index of the selected button
    def confirm(opts)
      message = opts[:message] || ""
      detailed_message = opts[:detailed_message] || ""
      buttons = opts[:buttons].to_n
      `#@native.confirm({message: #{message}, detailedMessage: #{detailed_message}, buttons: #{buttons}})`
    end

    # Focus the current window
    alias_native :focus

    # Get the directory path to Atom's configuration area
    alias_native :config_dir_path, :getConfigDirPath

    # Get the current window
    alias_native :current_window, :getCurrentWindow

    # Get the github token from the keychain
    #
    # @returns [String] github_auth_token The token
    alias_native :github_auth_token, :getGithubAuthToken

    # Get the load settings for the current window.
    alias_native :load_settings, :getLoadSettings

    # Get the version of the Atom application.
    alias_native :version, :getVersion

    # Get the dimensions of the current window
    alias_native :window_dimensions, :getWindowDimensions

    # Get the time taken to completely load the current window.
    #
    # This time include things like loading and activating packages,
    # creating DOM elements for the editor, and reading the config.
    # @returns [Numeric] number of milliseconds taken to load the
    #   window or null if the window hasn't finished loading yet.
    alias_native :window_load_time, :getWindowLoadTime

    # Hide the current window
    alias_native :hide

    # Is the current window in development mode?
    alias_native :dev_mode?, :inDevMode

    # Is the current window running specs?
    alias_native :spec_mode?, :inSpecMode

    # Sets up the basic services that should be available in all modes
    # (both spec and application). Call after this instance has been
    # assigned to the atom global.
    def atom_init
      `atom.initialize()`
    end

    # Is the current window in full screen mode?
    #
    # @returns [Boolean] fullscreen is it?
    alias_native :full_screen?, :isFullScreen

    # Determine whether the current version is an official release.
    #
    # @returns [Boolean] released_version is it?
    alias_native :released_version, :isReleasedVersion

    # Open a new Atom window using the given options.
    #
    # Calling this method without an options parameter will open a
    # prompt to pick a file/folder to open in the new window.
    #
    # @param [Hash] opts Options for calling the `open` method
    # @option opts [Array<String, Pathname>] :paths_to_open An Array
    #   of String paths to open.
    def open(opts={})
      paths = opts[:paths_to_open].map do |p|
        if p.respond_to? :to_path
          p.to_path
        else
          p
        end
      end
      `#@native.open({ pathsToOpen: #{paths} })`
    end

    # Open the dev tools for the current window.
    alias_native :open_dev_tools, :openDevTools

    #Reload the current window.
    alias_native :reload

    # Set the full screen state of the current window.
    #
    # @param [Boolean] fullscreen Defaults to `false`.
    def full_screen=(fullscreen=false)
      `#@native.setFullScreen(#{fullscreen})`
    end

    # Set the the github token in the keychain
    #
    # @param [String] token The token to set.
    def github_auth_token=(token)
      @github_auth_token = `#@native.setGithubAuthToken(token)`
    end

    # Set the position of current window.
    #
    # @param [Numeric] x The number of pixels
    # @param [Numeric] y The number of pixels
    def position=(x,y)
      `#@native.setPosition(x,y)`
    end

    # Set the size of the current window.
    #
    # @param [Numeric] width The number of pixels
    # @param [Numeric] height The number of pixels
    def size=(width, height)
      `#@native.setSize(width, height)`
    end

    # Set the dimensions of the window.
    #
    # The window will be centered if either the x or y coordinate is
    # not set in the dimensions parameter. If x or y are omitted the
    # window will be centered. If height or width are omitted only the
    # position will be changed.
    #
    # @param [Hash] dimensions Hash containing coordinates and size
    #   info
    # @option dimensions [Numeric] x The new x coordinate.
    # @option dimensions [Numeric] y The new y coordinate.
    # @option dimensions [Numeric] width The new width.
    # @option dimensions [Numeric] height The new height.
    def window_dimensions=(dimensions={})
      `#@native.setWindowDimensions(#{dimensions}.map)`
    end

    # Show the current window
    alias_native :show

    # Toggle the visibility of the dev tools for the current window
    alias_native :toggle_dev_tools, :toggleDevTools

    # Toggle the full screen state of the current window.
    alias_native :toggle_full_screen

    alias_native :workspace

    alias_native :workspace_view, :workspaceView

  end
end
