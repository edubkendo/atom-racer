RacerClient = require './racer-client'
_ = require 'underscore-plus'

module.exports =
ProviderClass: (Provider, Suggestion)  ->

  class RacerProvider extends Provider
    wordRegex: /(\b\w*[a-zA-Z1-9:.]\w*\b|[a-zA-Z1-9:.])/g
    exclusive: false
    racerClient: null
    completions: null

    initialize: ->
      @racerClient = new RacerClient

    buildSuggestions: ->
      selection = @editor.getLastSelection()
      prefix = @prefixOfSelection selection
      return unless prefix.length

      @fetchCompletionsSync()

      suggestions = @findSuggestionsForPrefix prefix
      return unless suggestions?.length
      return suggestions

    fetchCompletionsSync: () ->
      cursor = @editor.getCursor()
      row = cursor.getBufferRow()
      col = cursor.getBufferColumn()
      @completions = @racerClient.check_completion @editor, row, col
      return

    findSuggestionsForPrefix: (prefix) ->
      if @completions?.length
        # Sort the candidates
        words = _.sortBy( @completions, (e) => e.word )

        # Builds suggestions for the candidate words
        suggestions = for word in words when word.word? isnt prefix
          new Suggestion this, word: word.word, prefix: prefix, label: "#{word.type} <em>(#{word.file})</em>", renderLabelAsHtml: true

        return suggestions

      return []
