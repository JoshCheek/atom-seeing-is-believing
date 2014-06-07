# http://nodejs.org/api/child_process.html#child_process_child_process_exec_command_options_callback
spawn = require('child_process').spawn

# might be cool to use the -j option to split into a second or third pane
# would be like:
# if there are multiple panes open that SIB did not create
#   then just run with magic comment style
# if there is only one pane that SIB did not open
#   run with --json flag
#   find or open 2nd pane to the right, add metadata to it so we know it is "sib-results"
#   print results there
#   if there is stdout/stderr
#     find or open 3rd & 4th panes under them, print results there
#   if there is not stderr or stdout
#     close the stdout / stderr panes if they are open

module.exports =
  # These assume the active pane item is an editor
  activate: ->
    atom.workspaceView.command "seeing-is-believing:annotate-document",       => @annotateDocument()
    # atom.workspaceView.command "seeing-is-believing:annotateMagicComments", => @annotate_magic_comments()
    # atom.workspaceView.command "seeing-is-believing:removeAnnotations",      => @remove_annotations()

  annotateDocument: ->
    # default_options="$default_options --shebang $TM_RUBY"
    #
    # if [ -n "$TM_FILEPATH" ]; then
    #   default_options="$default_options --as $TM_FILEPATH"
    # fi
    #
    # "${TM_RUBY}" -S seeing_is_believing $default_options

    # --shebang ruby-executable # if you want SiB to use some ruby other than the one in the path
    editor        = atom.workspace.activePaneItem
    bodySelection = editor.selectAll()[0]
    crntBody      = bodySelection.getText()
    newBody       = ""
    sib           = spawn "seeing_is_believing", [
      '-Ku',
      '--alignment-strategy', 'line',
      '--number-of-captures', '200',
      '--result-length',      '200',
      '--alignment-strategy', 'chunk',
      '--timeout',            '12'
      # '--shebang',            '...' # chruby won't work until we figure out env vars
    ]

    sib.stdout.on 'data', (output) ->
      newBody += output

    sib.on 'close', (code) ->
      bodySelection.insertText(newBody)

    sib.stdin.write(crntBody)
    sib.stdin.end()




  annotateMagicCmments: ->
    # -x,  --xmpfilter-style         # annotate marked lines instead of every line

  removeAnnotations: ->
    # -c,  --clean                   # remove annotations from previous runs of seeing_is_believing
