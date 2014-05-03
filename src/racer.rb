require "native"
require "atom/atom"
require "racer/client"

module Racer
  class Racer
    include Native

    attr_accessor :atom, :editor_subscription, :providers, :autocomplete, :racer_client, :providers

    def initialize
      @atom = Atom::Atom.new
      @racer_client = Racer::Client.new(@atom)
      @providers = []
    end

    def register_providers
      workspace_view = Native(@atom.workspace_view)
      workspace_view.eachEditorView -> editorView {
        editorView = Native(`#{editorView}`)
        editor = editorView.editor
        editor.on "grammar-changed", -> {
          if editor.getGrammar().name =~ /Rust/ && !editorView.mini
            view = workspace_view.getActiveView()
            `RacerProvider = require("../racer-provider")`
            provider = `new RacerProvider(#{editorView})`
            @autocomplete.registerProviderForEditorView(provider, editorView.to_n)
          end
        }
      }
    end

    def add_provider(provider)
      nprovider = Native(provider)
      @providers << nprovider
      nprovider.init(@racer_client)
    end

    def clear_providers
      @providers = []
    end

  end
end
