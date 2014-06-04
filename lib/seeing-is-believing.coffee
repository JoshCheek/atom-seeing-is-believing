# http://nodejs.org/api/child_process.html#child_process_child_process_exec_command_options_callback
spawn = require('child_process').spawn

module.exports =
  # These assume the active pane item is an editor
  activate: ->
    atom.workspaceView.command "seeing-is-believing:annotate-document",       => @annotateDocument()
    # atom.workspaceView.command "seeing-is-believing:annotateMagicComments", => @annotate_magic_comments()
    # atom.workspaceView.command "seeing-is-believing:removeAnnotations",      => @remove_annotations()

  annotateDocument: ->
    console.log("omgomgomg")
    # editor        = atom.workspace.activePaneItem
    # bodySelection = editor.selectAll()[0]
    # newBody       = ""
    # sib           = spawn "ls", []
    #
    # sib.stdout.on 'data', (output) -> newBody += output
    #
    # cat.stdin.write(bodySelection.getText())
    # cat.stdin.end()
    #
    # bodySelection.insertText(newBody)

  annotateMagicCmments: ->

  removeAnnotations: ->
