_ = require 'underscore-plus'
RacerClient = require './racer-client'

module.exports =
class RacerProvider
  id: 'racer-racerprovider'
  selector: '.source.rust'
  racerClient: null

  constructor: ->
    @racerClient = new RacerClient

  requestHandler: (options) ->
    return new Promise (resolve) =>
      return resolve() unless options?
      return resolve() unless options.prefix?.length
      return resolve() unless options.cursor?
      return resolve() unless options.editor?
      return resolve() unless options.buffer?

      row = options.cursor.getBufferRow()
      col = options.cursor.getBufferColumn()
      completions = @racerClient.check_completion(options.editor, row, col, (completions) =>
        suggestions = @findSuggestionsForPrefix(options.prefix, completions)
        return resolve() unless suggestions?.length
        return resolve(suggestions)
      )
      return

  findSuggestionsForPrefix: (prefix, completions) ->
    if completions?.length
      # Sort the candidates
      words = _.sortBy( completions, (e) => e.word )

      # Builds suggestions for the candidate words
      suggestions = []
      for word in words when word.word isnt prefix
        # Eliminate prefixes that are counted as part of words and break the completion.
        prefix = '' if prefix.slice(-1).match(/(\)|\.|:|;)/g)
        suggestion =
          word: word.word
          prefix: prefix
          label: "#{word.type} <em>(#{word.file})</em>"
          renderLabelAsHtml: true
        suggestions.push(suggestion)

      return suggestions

    return []

  dispose: ->
