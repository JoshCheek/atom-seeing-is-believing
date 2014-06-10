# http://nodejs.org/api/child_process.html#child_process_child_process_exec_command_options_callback
spawn = require('child_process').spawn

# ADDED TO MY ~/.atom/config.cson
# 'seeing-is-believing':
#   'ruby-command': '/Users/josh/.rubies/ruby-2.1.1/bin/ruby'
#   'new-env-vars':
#     'GEM_HOME'        : '/Users/josh/.gem/ruby/2.1.1',
#     'GEM_PATH'        : '/Users/josh/.gem/ruby/2.1.1:/Users/josh/.rubies/ruby-2.1.1/lib/ruby/gems/2.1.0',
#     'GEM_ROOT'        : '/Users/josh/.rubies/ruby-2.1.1/lib/ruby/gems/2.1.0',
#     'RUBIES'          : '/Users/josh/.rubies/ruby-2.1.1',
#     'RUBYOPT'         : '',
#     'RUBY_ENGINE'     : 'ruby',
#     'RUBY_PATCHLEVEL' : '76',
#     'RUBY_ROOT'       : '/Users/josh/.rubies/ruby-2.1.1',
#     'RUBY_VERSION'    : '2.1.1',
#     'ADD_TO_PATH'     : '/Users/josh/.gem/ruby/2.1.1/bin:/Users/josh/.rubies/ruby-2.1.1/lib/ruby/gems/2.1.0/bin:/Users/josh/.rubies/ruby-2.1.1/bin:/Users/josh/code/bin'
#   'flags': [
#       '-S',                   'seeing_is_believing',
#       '-Ku',
#       '--alignment-strategy', 'line',
#       '--number-of-captures', '200',
#       '--result-length',      '200',
#       '--alignment-strategy', 'chunk',
#       '--timeout',            '12'
#       '--shebang',            '/Users/josh/.rubies/ruby-2.1.1/bin/ruby'
#     ]

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
    newEnvVars    = sibConfig['new-env-vars'] || {}
    flags         = sibConfig['flags']        || []
    rubyCommand   = sibConfig['ruby-command'] || 'ruby'

    editor        = atom.workspace.activePaneItem
    fileName      = editor.getPath()

    flags.push("--as", fileName) if fileName

    addToPath = newEnvVars.ADD_TO_PATH || ""
    delete newEnvVars.ADD_TO_PATH
    env = this.merge process.env, newEnvVars
    if env.PATH
      env.PATH = addToPath + ":" + env.PATH
    else
      env.PATH = addToPATH

    sibConfig.env         = env
    sibConfig.flags       = flags
    sibConfig.editor      = editor
    sibConfig.rubyCommand = rubyCommand
    sibConfig

  annotateDocument: ->
    this.invokeSib this.getVars()

  annotateMagicCmments: ->
    # -x,  --xmpfilter-style         # annotate marked lines instead of every line

  removeAnnotations: ->
    # -c,  --clean                   # remove annotations from previous runs of seeing_is_believing

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
