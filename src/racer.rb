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
