_ = require 'underscore-plus'

module.exports =
  # Config schema
  config:
    rustSrcPath:
      title: 'Path to the Rust source code directory'
      type: 'string'
      default: '/usr/local/src/rust/src/'
    racerBinPath:
      title: 'Path to the Racer executable'
      type: 'string'
      default: '/usr/local/bin/racer'
  # members
  editorSubscription: null
  autocomplete: null
  providers: []

  ###
   * Registers a RacerProvider for each editor
  ###
  activate: (state) ->
    return unless _.contains(atom.packages.getAvailablePackageNames(), 'autocomplete-plus')
    atom.packages.activatePackage("autocomplete-plus")
      .then (pkg) =>
        @autocomplete = pkg.mainModule
        RacerProvider = (require './racer-provider').ProviderClass(@autocomplete.Provider, @autocomplete.Suggestion)
        @editorSubscription = atom.workspace.observeTextEditors( (editor) =>
          @registerProvider(RacerProvider, editor))

  ###
   * Registers a RacerProvider for each editor
  ###
  registerProvider: (RacerProvider, editor) ->
    return unless editor?
    editorView = atom.views.getView(editor)
    if not editorView.mini and editor.getGrammar()?.scopeName is 'source.rust'
      provider = new RacerProvider(editor)
      @autocomplete.registerProviderForEditor(provider, editor)
      @providers.push provider

  ###
   * Cleans everything up, unregisters all RacerProvider instances
  ###
  deactivate: ->
    @editorSubscription?.dispose()
    @editorSubscription = null
    @providers.forEach (provider) =>
      @autocomplete.unregisterProvider provider
    @providers = []
