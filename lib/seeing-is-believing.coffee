# http://nodejs.org/api/child_process.html#child_process_child_process_exec_command_options_callback
spawn = require('child_process').spawn

module.exports =
  # These assume the active pane item is an editor
  activate: ->
    atom.workspaceView.command "seeing-is-believing:annotate-document",       => @annotateDocument()
    # atom.workspaceView.command "seeing-is-believing:annotateMagicComments", => @annotate_magic_comments()
    # atom.workspaceView.command "seeing-is-believing:removeAnnotations",      => @remove_annotations()

  annotateDocument: ->
    editor        = atom.workspace.activePaneItem
    bodySelection = editor.selectAll()[0]
    crntBody      = bodySelection.getText()
    newBody       = ""
    sib           = spawn "seeing_is_believing", []

    sib.stdout.on 'data', (output) ->
      newBody += output

    sib.on 'close', (code) ->
      bodySelection.insertText(newBody)

    sib.stdin.write(crntBody)
    sib.stdin.end()




  annotateMagicCmments: ->

  removeAnnotations: ->
