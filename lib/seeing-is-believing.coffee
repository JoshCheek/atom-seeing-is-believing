# http://nodejs.org/api/child_process.html#child_process_child_process_exec_command_options_callback
spawn = require('child_process').spawn

# https://atom.io/docs/api/v1.7.2/CompositeDisposable
# An object that aggregates multiple Disposable instances together into a single disposable, so they can all be disposed as a group.
{CompositeDisposable} = require 'atom'

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

module.exports = SeeingIsBelieving =
  config:
    sibCommand:
      title: 'Seeing is believing command'
      description: '
        This is the absolute path to your `seeing_is_believing` command. You may need to run
        `which seeing_is_believing` or `rbenv which seeing_is_believing` to find this. Examples:
        `/home/USERNAME/.gem/ruby/2.3.0/bin/seeing_is_believing` or `/usr/local/bin/bundle exec seeing_is_believing`.
        Alternatively, you could set it to a file containing a script that runs it in a custom environment.
      '
      type: 'string'
      default: 'seeing_is_believing'
    flags:
      description: 'You can get a full list of flags by running seeing_is_believing --help'
      type: 'array'
      default: ['--alignment-strategy', 'chunk',
                '--number-of-captures', '300',
                '--line-length',        '1000',
                '--timeout',            '12']
      items:
        type: 'string'

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'seeing-is-believing:annotate-document':       => @run [],
      'seeing-is-believing:annotate-magic-comments': => @run ['--xmpfilter-style'],
      'seeing-is-believing:remove-annotations':      => @run ['--clean']

  deactivate: ->
    @subscriptions.dispose()

  run: (args) ->
    editor        = atom.workspace.getActivePaneItem()
    return unless @isEditor? editor
    sibCommand    = atom.config.get('seeing-is-believing.sibCommand')
    args          = args.concat atom.config.get('seeing-is-believing.flags')
    @invokeSib sibCommand, args, editor.getText(), editor.getPath(), (code, stdout, stderr) =>
      if code == 2 # nondisplayable error
        atom.notifications.addError 'Seeing Is Believing',
                                    detail: "exec error: #{stderr}",
                                    dismissable: true
      else
        @withoutMovingScreenOrCursor editor, -> editor.setText(stdout + stderr)

  invokeSib: (sibCommand, args, body, filename, onClose) ->
    args.push('--as', filename) if filename
    [stdout, stderr] = ["", ""]
    sib = spawn(sibCommand, args)
    sib.stdout.on 'data',  (output) -> stdout += output
    sib.stderr.on 'data',  (output) -> stderr += output
    sib.on        'close', (code)   -> onClose(code, stdout, stderr)
    sib.stdin.write(body)
    sib.stdin.end()

  isEditor: (editor) ->
    # can't figure out a good way to ask it what it is, so just asking if I can do all the stuff I want with it
    editor?                           &&
      editor.getText?                 &&
      editor.setText?                 &&
      editor.getPath?                 &&
      editor.getCursorBufferPosition? &&
      editor.setCursorBufferPosition? &&
      editor.setScrollLeft?           &&
      editor.setScrollTop?

  withoutMovingScreenOrCursor: (editor, f) ->
    cursor        = editor.getCursorBufferPosition()
    scrollTop     = editor.getScrollTop()
    scrollLeft    = editor.getScrollLeft()
    f()
    editor.setCursorBufferPosition(cursor)
    editor.setScrollLeft(scrollLeft)
    editor.setScrollTop(scrollTop)
