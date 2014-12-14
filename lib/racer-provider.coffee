{Provider, Suggestion} = require "autocomplete-plus"
RacerClient = require "./racer-client"

###
 * Note: autocomplete-plus doesnt handle asynchronous providers. We use a trick
 * to poll for completions independantly by monitoring editor content changes by
 * ourselves, while the Provider uses the currently available results to build
 * suggestions.
 * It's kind of buggy: this provider might return old completion results before
 * the fresh ones are obtained from "racer".
###
module.exports =
class RacerProvider extends Provider
  wordRegex: /(\b\w*[a-zA-Z1-9:.]\w*\b|[a-zA-Z1-9:.])/g
  exclusive: false
  racerClient: null
  completions: null

  initialize: ->
    @racerClient = new RacerClient
    aeditor = atom.workspace.getActiveEditor()
    aeditor.getBuffer().on "contents-modified", (e) =>
      @fetchCompletionsAsync()

  buildSuggestions: ->
    selection = @editor.getSelection()
    prefix = @prefixOfSelection selection
    return unless prefix.length

    suggestions = @findSuggestionsForPrefix prefix
    return unless suggestions?.length
    return suggestions

  fetchCompletionsAsync: () ->
    cursor = @editor.getCursor()
    row = cursor.getBufferRow()
    col = cursor.getBufferColumn()
    @racerClient.check_completion @editor, row, col, (candidates) =>
      @completions = candidates
    return

  findSuggestionsForPrefix: (prefix) ->
    if @completions?.length

      # Builds suggestions for the candidate words
      suggestions = for word in @completions when word.word? isnt prefix
        new Suggestion this, word: word.word, prefix: prefix, label: "#{word.type} <em>(#{word.file})</em>", renderLabelAsHtml: true

      return suggestions

    return []
