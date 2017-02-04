# To run (from within Atom):
#   window:run-package-specs
#   which is probably `control-option-command-p`
# Highl-elvel docs:
#   http://flight-manual.atom.io/hacking-atom/sections/writing-specs/
# Good reference:
#   https://github.com/atom/snippets/blob/master/spec/snippets-spec.coffee
#   Likely to have good integration examples:
#     describe "when 'tab' is triggered on the editor"
#     describe "when there are multiple cursors"
#     describe "when the 'snippets:available' command is triggered"


# expect().toEqual()
# expect().not.toEqual()
# expect().toContain()

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

SiB = require '../lib/seeing-is-believing'

describe "Seeing Is Believing extension", ->
  it 'passes a trivial test (sanity)', ->
    expect("a").toEqual("a")
  it 'fails a trivial test (sanity)', ->
    expect("a").toEqual("b")
  describe 'seeing-is-believing:annotate-document', ->
    xit 'annotates every line in the document'
  describe 'seeing-is-believing:annotate-magic-comments', ->
    xit 'only annotates lines that are already marked'
  describe 'seeing-is-believing:remove-annotations', ->
    xit 'clears out the annotations'

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
