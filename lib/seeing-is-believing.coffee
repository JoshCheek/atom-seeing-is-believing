# http://nodejs.org/api/child_process.html#child_process_child_process_exec_command_options_callback
spawn = require('child_process').spawn

# https://github.com/JoshCheek/atom-seeing-is-believing/issues/8
defaultLang = 'en_US.UTF-8'

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
  # Convig vars are at https://github.com/JoshCheek/seeing_is_believing/blob/4200822e9cef765caa3e30cfe87c21257c46939b/lib/seeing_is_believing/binary/config.rb#L276-301
  # Note that these are v3, I'm keeping --number-of-captures for now,
  # because it will work with both SiB 2 and SiB 3, even though it's now deprecated
  # in favour of --max-line-captures
  config:
    'ruby-command':
      title:       'Ruby Executable'
      description: 'By default, we find Ruby by looking in the PATH. But path is not consistently correct (e.g. launching from shell vs double clicking icon). So you can specify the Ruby here. e.g. "/Users/josh/.rubies/ruby-2.1.1/bin/ruby"'
      type:        'string'
      default:     'ruby'
    'add-to-env':
      title:       'Additional environment variables'
      description: 'Set any environment variables you need (e.g. if your executable is ~/.rbenv/shims/ruby then you might also need to set the variable "RBENV_VERSION" to "2.2.0-p0"'
      type:        'object'
      required:   ['ADD_TO_PATH', 'LANG']
      properties:
        ADD_TO_PATH:
          title:       'Directories to prepend to the PATH'
          description: 'In the format /path/to/dir1:/path/to/dir2'
          type:        'string'
          default:     ''
        LANG:
          title:       'LANG'
          description: 'Encodings >.< see https://github.com/JoshCheek/atom-seeing-is-believing/issues/8 if you need to know more.'
          type:        'string'
          default:     'en_US.UTF-8'
      additionalProperties:
        type:          'string'
    flags:
      description: 'You can get a list by running `seeing_is_believing --help` from the shell'
      type:        'array'
      items:
        type: 'string'
      default: ['--alignment-strategy', 'chunk',
                '--number-of-captures', '300',
                '--line-length',        '1000',
                '--timeout',            '12'
               ]

  # These assume the active pane item is an editor <-- is there some way to guard agains this being untrue? e.g. check its class or methods
  activate: ->
    atom.workspaceView.command 'seeing-is-believing:annotate-document',       => @annotateDocument()
    atom.workspaceView.command 'seeing-is-believing:annotate-magic-comments', => @annotateMagicComments()
    atom.workspaceView.command 'seeing-is-believing:remove-annotations',      => @removeAnnotations()


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
    sibConfig       = atom.config.get('seeing-is-believing') ? {}

    # copy env vars
    newEnvVars      = {}
    oldEnvVars      = sibConfig['add-to-env'] ? {}
    newEnvVars[key] = oldEnvVars[key] for key of oldEnvVars

    # copy flags
    oldFlags        = sibConfig['flags'] ? []
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

    # Ensure LANG env var is set (https://github.com/JoshCheek/atom-seeing-is-believing/issues/8)
    # the defaults above won't work if the user overrides add-to-env in their config
    # (it overrides the hash instead of merging)
    newEnv.LANG ||= defaultLang

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
