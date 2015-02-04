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
  racerProvider: null

  activate: (state) ->
    @racerProvider = new RacerProvider()
    return

  provideAutocompletion: ->
    return {provider: @racerProvider}

  deactivate: ->
    @racerProvider?.dispose()
    @racerProvider = null
    return
