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

  # Splits `str` by the regex/substring `split`, unless the split
  # occurs in a nested set of delimiters.
  # Example: @splitNested('foo; (bar; baz); qux', /;\s+/)
  #            => ['foo', '(bar; baz)', 'qux']
  splitNested: (str, split) ->
      depth = 0

      openDelims = ['(', '<', '[']
      closeDelims = [')', '>', ']']

      splits = []

      lastSplit = 0
      i = 0
      while i < str?.length
          match = str.slice(i).match(split)
          shouldSplit = depth == 0 && match?.index == 0

          if openDelims.indexOf(str[i]) >= 0
              depth += 1
          else if closeDelims.indexOf(str[i]) >= 0
              depth -= 1
          else if shouldSplit
              splits.push(str.slice(lastSplit, i))
              lastSplit = i + match[0].length

          i += 1

      splits.push(str?.slice(lastSplit))
      splits

  # If the start of `str` matches the regex/substring `matcher`, then
  # return an array consisting of [matched part, remaining part]; else,
  # return [null, str].
  # Example: @consumePart('foobar', /fo+/) => ['foo', 'bar']
  consumePart: (str, matcher) ->
    match = str?.match(matcher)
    if match?.index == 0
      [match[0], str.slice(match[0].length)]
    else
      [null, str]

  # If the start of `str` is surrounded by `openDelim`, `closedDelim`, then
  # return an array of [part of str surrounded, rest of str]; else,
  # return [null, str].
  # Example: @consumeDelimited('(foo bar (baz qux)) asdf jkl", ['(', ')'])
  #            => ['(foo bar (baz qux))', ' asdf jkl']
  consumeDelimited: (str, [openDelim, closeDelim]) ->
    depth = 0
    i = 0
    while i < str?.length
      if str[i] == openDelim
        depth += 1
      else if str[i] == closeDelim
        depth -= 1

      if depth == 0
        break
      i += 1

    consumed = str.slice(0, i + 1)
    if str[0] == openDelim && depth == 0
      [consumed, str.slice(i + 1)]
    else
      [null, str]

  # Given a string of Rust trait params, and a snippet offset `n`, return
  # an array of [snippet, nextOffset]. `nextOffset` should be used as the
  # offset of the next snippet.
  # Example: @snippetForTraits('<T: Trait1, U: Trait2>', 1)
  #            => ['${1:::<T: Trait1, U: Trait2>}', 2]
  snippetForTraits: (traits, n) ->
    if traits?
      ["${#{n}:::#{traits}}", n + 1]
    else
      ["", n]

  # Given a string of Rust params, and a snippet offset `n`, return an array
  # of [snippet, nextOffset]. `nextOffset` should be used as the offset of the
  # next snippet.
  # Example: @snippetForParams('foo: T1, bar: T2', 1)
  #            => ['${1:foo: T1}, ${2:bar: T2}', 3]
  snippetForParams: (params, n) ->
    snippets = []
    for param in @splitNested(params, /\s*,\s*/)
      snippets.push("${#{n}:#{param}}")
      n += 1

    ["(#{snippets.join(', ')})", n + snippets.length]

  suggestionSnippet: (word) ->
    switch word.type
      when 'Function'
        rest = word.context
        [decl, rest] = @consumePart(rest, /(pub)?\s*fn\s+/)
        [name, rest] = @consumePart(rest, /\w+/)
        [traits, rest] = @consumeDelimited(rest, ['<', '>'])
        [signature, rest] = @consumeDelimited(rest, ['(', ')'])
        [ret, rest] = @consumePart(rest, /->\s*(.*)\s*{/)

        params = signature?.slice(1, -1)
        n = 1
        [traitsSnippet, n] = @snippetForTraits(traits, n)
        [paramsSnippet, n] = @snippetForParams(params, n)
        if name? && paramsSnippet?
          "#{name}#{traitsSnippet}#{paramsSnippet}"

  suggestionText: (word) ->
    word.word

  suggestionFor: (word, prefix) ->
    suggestion =
      replacementPrefix: prefix
      rightLabelHTML: "<em>(#{word.file})</em>"
      leftLabel: word.type
      type: @mapType(word.type)
    snippet = @suggestionSnippet(word)
    text = @suggestionText(word)

    if snippet?
      suggestion.snippet = snippet
    else
      suggestion.text = text

    suggestion

  findSuggestionsForPrefix: (prefix, completions) ->
    if completions?.length
      # Sort the candidates
      words = _.sortBy( completions, (e) => e.word )

      # Builds suggestions for the candidate words
      suggestions = []
      for word in words when word.word isnt prefix
        # Eliminate prefixes that are counted as part of words and break the completion.
        prefix = '' if prefix.slice(-1).match(/(\)|\.|:|;)/g)
        suggestion = @suggestionFor(word, prefix)
        suggestions.push(suggestion)

      return suggestions

    return []

  mapType: (type) ->
    switch type
      when 'Function' then 'function'
      when 'Module' then 'module'
      else type

  dispose: ->
