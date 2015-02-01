RacerProvider = require './racer-provider'

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
  registration: null
  racerProvider: null

  activate: (state) ->
    @racerProvider = new RacerProvider()
    @registration = atom.services.provide('autocomplete.provider', '1.0.0', {provider: @racerProvider})
    return

  deactivate: ->
    @registration?.dispose()
    @registration = null
    @racerProvider?.dispose()
    @racerProvider = null
    return
