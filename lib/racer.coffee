
sourceFile = "#{__dirname}/js/opal.js"

fs = require('fs')

source = fs.readFileSync(sourceFile).toString()

vm = require 'vm'
vm.runInThisContext(source)
RacerProvider = require("./racer-provider")
require('./js/racer.js')

_ = require "underscore-plus"
{ProviderPackageFactory} = require "autocomplete-plus"

module.exports =
  configDefaults:
    rustSrcPath: "/usr/local/src/rust/src",
    racerBinPath: "/usr/local/bin/racer"
  editorSubscription: null
  providers: []
  autocomplete: null

  ###
   * Registers a SnippetProvider for each editor view
  ###
  activate: ->
    @racer = Opal.Racer.Racer.$new()
    atom.packages.activatePackage("autocomplete-plus")
      .then (pkg) =>
        @autocomplete = pkg.mainModule
        @registerProviders()

  ###
   * Registers a SnippetProvider for each editor view
  ###
  registerProviders: ->
    @editorSubscription = atom.workspaceView.eachEditorView (editorView) =>
      if editorView.attached and not editorView.mini
        if editorView.editor.getGrammar().name.match(/Rust/)
          provider = new RacerProvider editorView

          @autocomplete.registerProviderForEditorView provider, editorView

          @providers.push provider
          @racer.$add_provider(provider)

  ###
   * Cleans everything up, unregisters all SnippetProvider instances
  ###
  deactivate: ->
    @editorSubscription?.off()
    @editorSubscription = null

    @providers.forEach (provider) =>
      @autocomplete.unregisterProvider provider
    @racer.$clear_providers()

    @providers = []
