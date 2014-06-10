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
    selection = vars.editor.selectAll()[0]
    crntBody  = selection.getText()
    newBody   = ""

    console.log("Invoking Seeing is believing with flags & env:", vars.flags, vars.env)
    sib = spawn(vars.rubyCommand,
                ['-S', 'seeing_is_believing'].concat(vars.flags),
                {"env": vars.env})

    sib.stdout.on 'data', (output) ->
      newBody += output

    sib.stderr.on 'data', (output) ->
      console.log("Seeing is Believing stderr:" + output)

    sib.on 'close', (code) ->
      console.log("Seeing is Believing closed with code " + code)
      selection.insertText(newBody)

    sib.stdin.write(crntBody)
    sib.stdin.end()

  getVars: ->
    sibConfig     = atom.config.get('seeing-is-believing')
    newEnvVars    = sibConfig['add-to-env']   || {}
    flags         = sibConfig['flags']        || []
    rubyCommand   = sibConfig['ruby-command'] || 'ruby'

    editor        = atom.workspace.activePaneItem
    fileName      = editor.getPath()

    # if file is saved, run as that file (otherwise uses a tempfile)
    flags.push("--as", fileName) if fileName

    # add new path locations
    addToPath = newEnvVars.ADD_TO_PATH || ""
    delete newEnvVars.ADD_TO_PATH
    env = this.merge process.env, newEnvVars
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
    this.invokeSib this.getVars()

  annotateMagicComments: ->
    vars = this.getVars()
    vars.flags.push('--xmpfilter-style')
    this.invokeSib vars

  removeAnnotations: ->
    vars = this.getVars()
    vars.flags.push('--clean')
    this.invokeSib vars

  # apparently JS doesn't have hashes, hashes are objects
  # and it doesn't have a clone method, or a merge method
  # so you have to write your own...
  #
  # But you don't even get iterators to work with (I saw some people use forEach
  # but it was not available)
  #
  # and you have to check each key to see if it is data or metadata
  # because otherwise you'll merge things like constructors and stuff
  # instead of just the "hash keys"
  #
  # How does everyone not have to write this code every time they want to add
  # a variable to the environment for just a single shelling-out?
  #
  # ...what a horrible language
  merge: (leftObj, rightObj) ->
    mergedObj = {}
    this.copyKeys(mergedObj, leftObj)
    this.copyKeys(mergedObj, rightObj)
    mergedObj

  copyKeys: (target, source) ->
    keyIndex = 0
    keys     = Object.keys(source)
    while keyIndex < keys.length
      key = keys[keyIndex]
      if source.hasOwnProperty(key)
        target[key] = source[key]
      keyIndex += 1
