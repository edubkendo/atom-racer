{CompositeDisposable} = require 'atom'
_ = require 'underscore-plus'

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
    cargoHome:
      title: 'Cargo home directory (optional)'
      type: 'string'
      description: 'Needed when providing completions for Cargo crates when Cargo is installed in a non-standard location.'
      default: ''
      order: 3
    autocompleteBlacklist:
      title: 'Autocomplete Scope Blacklist'
      description: 'Autocomplete suggestions will not be shown when the cursor is inside the following comma-delimited scope(s).'
      type: 'string'
      default: '.source.go .comment'
      order: 4
    show:
      title: 'Show position for editor with definition'
      description: 'Choose one: Right, or New. If your view is vertically split, choosing Right will open the definition in the rightmost pane.'
      type: 'string'
      default: 'New'
      enum: ['Right', 'New']
      order: 5
  # members
  racerProvider: null
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable

    # Register command that does find-definition
    @subscriptions.add atom.commands.add 'atom-workspace', 'racer:find-definition': (e)=>
      @findDefinition(e)

  getRacerProvider: ->
    return @racerProvider if @racerProvider?
    RacerProvider = require('./racer-provider')
    @racerProvider = new RacerProvider()
    return @racerProvider

  provideAutocompletion: ->
    @getRacerProvider()

  deactivate: ->
    @racerProvider?.dispose()
    @racerProvider = null
    @subscriptions?.dispose()
    return

  findDefinition: (e)->
    textEditor = atom.workspace.getActiveTextEditor()
    grammar = textEditor?.getGrammar()

    if !grammar or grammar.name != 'Rust' or textEditor.hasMultipleCursors()
      e.abortKeyBinding()
      return

    cursorPosition = textEditor.getCursorBufferPosition()
    @getRacerProvider().racerClient.check_definition(textEditor, cursorPosition.row, cursorPosition.column, (defs) =>
      return if _.isEmpty(defs)
      def = defs[0]

      textEditors = atom.workspace.getTextEditors()
      textEditor = _.find(textEditors, (te) => te.getPath() == def.filePath)
      if textEditor?
        pane = atom.workspace.paneForItem(textEditor)
        pane.activate()
        pane.activateItem(textEditor)
        textEditor.setCursorBufferPosition([def.line-1, def.column])
      else
        newEditorPosition = atom.config.get 'racer.show'
        options = {initialLine: def.line-1, initialColumn: def.column}
        options.split = newEditorPosition.toLowerCase() if newEditorPosition != 'New'
        atom.workspace.open(def.filePath, options).then((te) =>
          te.scrollToCursorPosition()
        )
    )
