# To run (from within Atom):
#   window:run-package-specs
#   which is probably `control-option-command-p`
# Highl-level Atom testing docs:
#   http://flight-manual.atom.io/hacking-atom/sections/writing-specs/
# Jasmine 1.3 docs (they use an old Jasmine):
#   https://jasmine.github.io/1.3/introduction.html#section-Asynchronous_Support
# NOTE!!! JASMINE MOCKS setTimeout!!
#   I have no idea how to do something async :(
# Good reference (a lot of stuff in here is cargo culted from there):
#   https://github.com/atom/snippets/blob/master/spec/snippets-spec.coffee
#   Likely to have good integration examples:
#     describe "when 'tab' is triggered on the editor"
#     describe "when there are multiple cursors"
#     describe "when the 'snippets:available' command is triggered"

# expect().toEqual()
# expect().not.toEqual()
# expect().toContain()

# beforeEach ->
#   spyOn(Snippets, 'loadAll')
#   spyOn(Snippets, 'getUserSnippetsPath').andReturn('')
#
#   waitsForPromise ->
#     atom.workspace.open('sample.js')
#
#   waitsForPromise ->
#     atom.packages.activatePackage('language-javascript')
#
#   waitsForPromise ->
#     atom.packages.activatePackage("snippets")
#
#   runs ->
#     editor = atom.workspace.getActiveTextEditor()
#     editorElement = atom.views.getView(editor)

# simulateTabKeyEvent = ({shift}={}) ->
#   event = atom.keymaps.constructor.buildKeydownEvent('tab', {shift, target: editorElement})
#   atom.keymaps.handleKeyboardEvent(event)
#       atom.workspace.open('sample.js')

# atom.commands.dispatch(editorElement, "snippets:available")
# availableSnippetsView = atom.workspace.getModalPanels()[0].getItem()

# editor.insertText('t9')
# editor.setCursorBufferPosition([12, 2])
# editor.insertText(' t9')
# editor.addCursorAtBufferPosition([0, 2])
# simulateTabKeyEvent()
#
# expect(editor.lineTextForBufferRow(0)).toBe "with placeholder test"

# waitsForPromise ->
#   atom.workspace.open('c.coffee').then (editor) ->
#     expect(editor.getPath()).toContain 'c.coffee'

# path = require 'path'
# temp = require('temp').track()
# it "opens ~/.atom/snippets.cson", ->
#   jasmine.unspy(Snippets, 'getUserSnippetsPath')
#   atom.workspace.destroyActivePaneItem()
#   configDirPath = temp.mkdirSync('atom-config-dir-')
#   spyOn(atom, 'getConfigDirPath').andReturn configDirPath
#   atom.workspace.open('atom://.atom/snippets')
#   waitsFor ->
#     atom.workspace.getActiveTextEditor()?
#   runs ->
#     expect(atom.workspace.getActiveTextEditor().getURI()).toBe path.join(configDirPath, 'snippets.cson')

SiB = require '../lib/seeing-is-believing'

describe "Seeing Is Believing extension", ->
  [editorElement, editor] = []

  #
  waitForAsync = (checkCondition) ->
    new Promise (resolve, reject) ->
      maybeResolve = ->
        if checkCondition()
          resolve()
        else
          setTimeout(maybeResolve, 5)
      maybeResolve()

  # based on git logs, it took me nearly 2 hours to figure this out >.<
  activatePackage = (packageName) ->
    # Call the toplevel activation method in order to get the promise
    # We must do this before we activate the package, for whatever reason -.-
    promise = atom.packages.activatePackage(packageName)

    # The above code does not actually activate SiB,
    # it decides SiB's activation shold be deferred https://github.com/atom/atom/blob/1a039df6435ba0d3fc2eead8e1b6e7a0cf0ebf9b/src/package.coffee#L144
    # So we need to use activateNow to force it to activate
    atom.packages.loadPackage(packageName).activateNow()

    # Now return the pre-activation promise
    promise


  beforeEach ->
    # atom.commands.dispatch(editorElement, "application:new-file")
    waitsForPromise -> atom.workspace.open()
    waitsForPromise -> activatePackage 'language-ruby'
    waitsForPromise -> activatePackage 'seeing-is-believing'

    # I *think* `runs` executes after promises resolve, not sure,
    # half of this is cargo culted from the Snippets package
    runs ->
      editor        = atom.workspace.getActiveTextEditor()
      editorElement = atom.views.getView(editor)
      rubyGrammar   = atom.grammars.grammarForScopeName('source.ruby')
      editor.setGrammar(rubyGrammar)

  # afterEach ->
  #   atom.packages.deactivatePackage('seeing-is-believing')

  describe 'seeing-is-believing:annotate-document', ->
    it 'annotates every line in the document', ->
      original = "1  # => \n2"
      expected = "1  # => 1\n2  # => 2"
      # console.log('setTimeout:', window.setTimeout)
      editor.insertText original
      # Oh my god, I don't fucking know.
      # There is supposed to be a listener that invokes the command,
      # that listener is definitely defined outside my test, but not inside
      # Run this code in the atom window and you'll see it, but run it in the onDidDispatch and it's not there:
      #    atom.commands.selectorBasedListenersByCommandName['seeing-is-believing:annotate-document']
      atom.commands.onDidDispatch (event) ->
        currentTarget = event.target
        console.log("type:", event.type)
        console.log('expected:', atom.commands.selectorBasedListenersByCommandName)
        listeners = atom.commands.selectorBasedListenersByCommandName[event.type]
        console.log("Listeners1:", listeners)
        listeners = listeners.filter (listener) -> currentTarget.webkitMatchesSelector(listener.selector)
        console.log("listeners2:", listeners)
        console.log("Event: ", event.type, event.target.webkitMatchesSelector)

      smth = atom.commands.dispatch(editorElement, 'seeing-is-believing:annotate-document')
      console.log('smth: ', smth)
      window.myEditor = editor
      # waitsForPromise ->
      #   console.log("making Promise")
      #   waitForAsync ->
      #     console.log("checking now:", editor.getText())
      #     original != editor.getText()
      # runs ->
      #   expect(editor.getText()).toEqual expected

  describe 'seeing-is-believing:annotate-magic-comments', ->
    xit 'only annotates lines that are already marked', ->
      # make a document with a marked and unmarked line
      # run it
      # the marked line should be updated
  describe 'seeing-is-believing:remove-annotations', ->
    xit 'clears out the annotations', ->
      # make a document with a marked and unmarked line
      # run it
      # the marked line should be cleared

  describe 'when the file is saved', ->
    xit 'informs SiB of the path and filename'

  describe 'when SiB has a displayable error', ->

  describe 'when SiB has a nondisplayable error', ->
    xit 'notifies me of the error'
    xit 'dismisses any previous SiB notifications soas not to spam us'

  describe 'when the source file is not Ruby, it notifies me in an error', ->
    xit 'dismisses old notifications'
    xit 'includes the keybinding to load the grammar selector if it exists'

  describe 'updating the buffer non-jarringly', ->
    xit 'updates the cursor to its position just prior to updating the document'
    xit 'maintains selections between runs (letting Atom decide how best to deal with discrepancies)'
    xit 'works with multiple cursors'
    xit 'sets the screen\'s position to their position just prior to updating (letting Atom decide how best to deal with discrepancies)'

  describe 'configuration', ->
    describe 'sibCommand', ->
      xit 'defaults to seeing_is_believing'
      xit 'allows the user to specify a custom executable so they can setup environment stuff or whatever'
    describe 'flags', ->
      xit 'is an array of strings that are passed to SiB'
      xit 'uses the default strategy, such as "chunk" alignment strategy'
      xit 'uses the user\'s updated value, such as "file" alignment strategy'
