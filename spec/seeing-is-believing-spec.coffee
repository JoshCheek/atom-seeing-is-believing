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

# *sigh* for whatever reason, the test environment does not have the env vars
# from the process. This causes it to be unable to locate the seeing_is_believing
# executable. So just add them here, ourselves.
require('child_process').exec '/bin/bash -ilc "command env"', (error, stdout, stderr) ->
  for definition in stdout.split('\n')
    [key, value] = definition.trim().split('=', 2)
    process.env[key] = value

describe "Seeing Is Believing extension", ->
  # I assume this is an iffy way to share state between the lifecycle hooks and the tests
  [editorElement, editor] = []

  # *sigh* the package doesn't activate so we have to do it in this contrived manner
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
    waitsForPromise -> atom.workspace.open()
    waitsForPromise -> activatePackage 'language-ruby'
    waitsForPromise -> activatePackage 'seeing-is-believing'
    runs ->
      editor        = atom.workspace.getActiveTextEditor()
      editorElement = atom.views.getView(editor)
      editor.setGrammar atom.grammars.grammarForScopeName('source.ruby')

  describe 'seeing-is-believing:annotate-document', ->
    it 'annotates every line in the document', ->
      original = "1  # => \n2"
      expected = "1  # => 1\n2  # => 2"
      editor.insertText original
      dispatched = atom.commands.dispatch(editorElement, 'seeing-is-believing:annotate-document')
      expect(dispatched).toEqual true
      waitsFor -> original != editor.getText()
      runs -> expect(editor.getText()).toEqual expected

  describe 'seeing-is-believing:annotate-magic-comments', ->
    it 'only annotates lines that are already marked', ->
      original = "1  # => \n2"
      expected = "1  # => 1\n2"
      editor.insertText original
      dispatched = atom.commands.dispatch(editorElement, 'seeing-is-believing:annotate-magic-comments')
      expect(dispatched).toEqual true
      waitsFor -> original != editor.getText()
      runs -> expect(editor.getText()).toEqual expected

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
