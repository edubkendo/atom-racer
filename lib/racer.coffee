RacerProvider = require "./racer-provider"

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
   * Registers a RacerProvider for each editor view
  ###
  activate: ->
    atom.packages.activatePackage("autocomplete-plus")
      .then (pkg) =>
        @autocomplete = pkg.mainModule
        @registerProviders()

  ###
   * Registers a RacerProvider for each editor view
  ###
  registerProviders: ->
    @editorSubscription = atom.workspaceView.eachEditorView (editorView) =>
      if editorView.attached and not editorView.mini and editorView.editor.getGrammar().name.match(/Rust/)
        provider = new RacerProvider editorView
        @autocomplete.registerProviderForEditorView provider, editorView
        @providers.push provider

  ###
   * Cleans everything up, unregisters all RacerProvider instances
  ###
  deactivate: ->
    @editorSubscription?.off()
    @editorSubscription = null
    @providers.forEach (provider) =>
      @autocomplete.unregisterProvider provider
    @providers = []
