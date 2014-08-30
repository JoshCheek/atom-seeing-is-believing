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
    atom.workspaceView.command "seeing-is-believing:annotate-magic-comments", => @annotateMagicComments()
    atom.workspaceView.command "seeing-is-believing:remove-annotations",      => @removeAnnotations()


  invokeSib: (vars) ->
    selection     = vars.editor.selectAll()[0]
    crntBody      = selection.getText()
    newBody       = ""
    capturedError = ""

    console.log("Invoking Seeing is believing with flags & env:", vars.flags, vars.env)
    sib = spawn(vars.rubyCommand,
                ['-S', 'seeing_is_believing'].concat(vars.flags),
                {"env": vars.env})

    sib.stdout.on 'data', (output) ->
      newBody += output

    sib.stderr.on 'data', (output) ->
      capturedError += output
      console.error("Seeing is Believing stderr:" + output)

    sib.on 'close', (code) ->
      console.error("Seeing is Believing closed with code " + code)
      if code == 2 # nondisplayable error
        alert(capturedError)
      else
        selection.insertText(newBody)

    sib.stdin.write(crntBody)
    sib.stdin.end()

  getVars: ->
    sibConfig     = atom.config.get('seeing-is-believing')
    newEnvVars    = sibConfig['add-to-env']   ? {}
    flags         = sibConfig['flags']        ? []
    rubyCommand   = sibConfig['ruby-command'] ? 'ruby'

    editor        = atom.workspace.activePaneItem
    fileName      = editor.getPath()

    # if file is saved, run as that file (otherwise uses a tempfile)
    flags.push("--as", fileName) if fileName

    # add new path locations
    addToPath = newEnvVars.ADD_TO_PATH || ""
    delete newEnvVars.ADD_TO_PATH
    env = @merge process.env, newEnvVars
    if env.PATH
      env.PATH = addToPath + ":" + env.PATH
    else
      env.PATH = addToPATH

    # add shebang
    if flags.indexOf('--shebang') != -1
      flags.push '--shebang', rubyCommand

    sibConfig.env         = env
    sibConfig.flags       = flags
    sibConfig.editor      = editor
    sibConfig.rubyCommand = rubyCommand
    sibConfig

  annotateDocument: ->
    @invokeSib @getVars()

  annotateMagicComments: ->
    vars = @getVars()
    vars.flags.push('--xmpfilter-style')
    @invokeSib vars

  removeAnnotations: ->
    vars = this.getVars()
    vars.flags.push('--clean')
    this.invokeSib vars

  merge: (leftObj, rightObj) ->
    mergedObj = {}
    for key, value of leftObj
      mergedObj[key] = value
    for key, value of rightObj
      mergedObj[key] = value
    mergedObj
