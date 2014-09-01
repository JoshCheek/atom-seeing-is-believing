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
  # These assume the active pane item is an editor <-- is there some way to guard agains this being untrue? e.g. check its class or methods
  activate: ->
    atom.workspaceView.command 'seeing-is-believing:annotate-document',       => @annotateDocument()
    atom.workspaceView.command 'seeing-is-believing:annotate-magic-comments', => @annotateMagicComments()
    atom.workspaceView.command 'seeing-is-believing:remove-annotations',      => @removeAnnotations()
  configDefaults:
    'ruby-command':  'ruby'
    'add-to-env':
      'ADD_TO_PATH': ''
    'flags': [
      '--alignment-strategy', 'chunk',
      '--number-of-captures', '300',
      '--line-length',        '1000',
      '--timeout',            '12'
    ]

  invokeSib: (vars) ->
    editor        = vars.editor
    crntBody      = editor.getText()
    args          = ['-S', 'seeing_is_believing'].concat(vars.flags)
    newBody       = ""
    capturedError = ""

    console.log('Seeing is Believing:')
    console.log('  command: ' + vars.rubyCommand + ' ' + args.join(' '))
    console.log('  env:     ',  vars.env)
    sib = spawn(vars.rubyCommand, args, {'env': vars.env})

    sib.stdout.on 'data', (output) =>
      newBody += output

    sib.stderr.on 'data', (output) =>
      capturedError += output
      console.error('Seeing is Believing stderr:' + output)

    sib.on 'close', (code) =>
      console.log('Seeing is Believing closed with code ' + code)
      if capturedError.contains('LoadError')
        alert("It looks like the Seeing is Believing gem hasn't been installed, run\n`gem install seeing is believing`\nto do so, then make sure it worked with\n`seeing_is_believing --version`\n\nIf it should be installed, check logs to see what was executed\n(Option+Command+I)")
      else if code == 2 # nondisplayable error
        alert(capturedError)
      else
        @withoutMovingScreenOrCursor editor, => editor.setText(newBody + capturedError)

    sib.stdin.write(crntBody)
    sib.stdin.end()

  getVars: ->
    sibConfig       = atom.config.get('seeing-is-believing')

    # copy env vars
    newEnvVars      = {}
    oldEnvVars      = sibConfig['add-to-env']   ? {}
    newEnvVars[key] = oldEnvVars[key] for key of oldEnvVars

    # copy flags
    oldFlags        = sibConfig['flags']        ? []
    newFlags        = (flag for flag in oldFlags)

    # other useful objs
    rubyCommand     = sibConfig['ruby-command'] ? 'ruby'
    editor          = atom.workspace.activePaneItem
    fileName        = editor.getPath()

    # if file is saved, run as that file (otherwise uses a tempfile)
    newFlags.push('--as', fileName) if fileName

    # add new path locations
    addToPath = newEnvVars.ADD_TO_PATH || ""
    delete newEnvVars.ADD_TO_PATH
    newEnv = @merge process.env, newEnvVars
    if newEnv.PATH
      newEnv.PATH = addToPath + ':' + newEnv.PATH
    else
      newEnv.PATH = addToPATH

    # add shebang
    if newFlags.indexOf('--shebang') != -1
      newFlags.push '--shebang', rubyCommand

    "env":         newEnv,
    "flags":       newFlags,
    "editor":      editor,
    "rubyCommand": rubyCommand

  annotateDocument: ->
    @invokeSib @getVars()

  annotateMagicComments: ->
    vars = @getVars()
    vars.flags.push('--xmpfilter-style')
    @invokeSib vars

  removeAnnotations: ->
    vars = @getVars()
    vars.flags.push('--clean')
    @invokeSib vars

  # helpers

  merge: (leftObj, rightObj) ->
    mergedObj = {}
    for key, value of leftObj
      mergedObj[key] = value
    for key, value of rightObj
      mergedObj[key] = value
    mergedObj

  withoutMovingScreenOrCursor: (editor, f) ->
    cursor        = editor.getCursorScreenPosition()
    scrollTop     = editor.displayBuffer.getScrollTop()
    scrollLeft    = editor.displayBuffer.getScrollLeft()
    f()
    editor.displayBuffer.setScrollLeft(scrollLeft)
    editor.displayBuffer.setScrollTop(scrollTop)
    editor.setCursorScreenPosition cursor
