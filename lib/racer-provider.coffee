_ = require 'underscore-plus'
RacerClient = require './racer-client'

module.exports =
class RacerProvider
  selector: '.source.rust'
  inclusionPriority: 1
  excludeLowerPriority: false
  racerClient: null

  constructor: ->
    @disableForSelector = atom.config.get('racer.autocompleteBlacklist')
    @racerClient = new RacerClient

  getSuggestions: ({editor, bufferPosition, prefix}) ->
    return new Promise (resolve) =>
      return resolve() unless prefix?.length
      return resolve() unless editor?
      buffer = editor.getBuffer()
      return resolve() unless buffer?
      return resolve() unless bufferPosition?
      return resolve() unless prefix?

      row = bufferPosition.row
      col = bufferPosition.column
      completions = @racerClient.check_completion(editor, row, col, (completions) =>
        suggestions = @findSuggestionsForPrefix(prefix, completions)
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
          text: word.word
          replacementPrefix: prefix
          rightLabelHTML: "<em>(#{word.file})</em>"
          leftLabel: word.type
          type: @mapType(word.type)
        suggestions.push(suggestion)

      return suggestions

    return []

  mapType: (type) ->
    switch type
      when 'Function' then 'function'
      when 'Module' then 'module'
      else type

  dispose: ->
