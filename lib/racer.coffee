module.exports =
  # Config schema
  config:
    racerBinPath:
      title: 'Path to the Racer executable'
      type: 'string'
      default: '/usr/local/bin/racer'
      order: 1
    rustSrcPath:
      title: 'Path to the Rust source code directory'
      type: 'string'
      default: '/usr/local/src/rust/src/'
      order: 2
    autocompleteBlacklist:
      title: 'Autocomplete Scope Blacklist'
      description: 'Autocomplete suggestions will not be shown when the cursor is inside the following comma-delimited scope(s).'
      type: 'string'
      default: '.source.go .comment'
      order: 3
  # members
  racerProvider: null

  activate: (state) ->

  provideAutocompletion: ->
    return @racerProvider if @racerProvider?
    RacerProvider = require('./racer-provider')
    @racerProvider = new RacerProvider()
    return @racerProvider

  deactivate: ->
    @racerProvider?.dispose()
    @racerProvider = null
    return
