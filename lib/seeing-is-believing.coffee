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
    @notifications = []
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-text-editor',
      'seeing-is-believing:annotate-document':       => @run [],
      'seeing-is-believing:annotate-magic-comments': => @run ['--xmpfilter-style'],
      'seeing-is-believing:remove-annotations':      => @run ['--clean']

  deactivate: ->
    @subscriptions.dispose()

  run: (args) ->
    console.log('ANNOTATING THE DOCUMENT')
    editor = atom.workspace.getActiveTextEditor()

    # Ideally we figure out whether this can happen,
    # and if so, update the scope on our subscription.
    return unless editor

    # Here, we intentionally avoid using a subscription to scope this as there's
    # no feedback about why it's not working, so it just seems broken. Eg #26
    if @isntRuby editor
      @dismissOurErrors()
      @notifyError "Seeing Is Believing expects a Ruby file",
                   description: @expectedRubyError(editor, atom.keymaps),
                   dismissable: true
      return

    sibCommand = atom.config.get('seeing-is-believing.sibCommand')
    args       = args.concat atom.config.get('seeing-is-believing.flags')

    @invokeSib sibCommand, args, editor.getText(), editor.getPath(), (code, stdout, stderr) =>
      @dismissOurErrors()
      if code == 2 # nondisplayable error
        @notifyError 'Seeing Is Believing', detail: "exec error: #{stderr}", dismissable: true
      else
        @withoutMovingScreenOrCursors editor, -> editor.setText(stdout + stderr)

  # https://atom.io/docs/api/v1.13.1/NotificationManager#instance-addError
  notifyError: (message, options) ->
    @notifications.push atom.notifications.addError(message, options)

  dismissOurErrors: ->
    @notifications.shift().dismiss() while 0 < @notifications.length

  invokeSib: (sibCommand, args, body, filename, onClose) ->
    args.push('--as', filename) if filename
    [stdout, stderr] = ["", ""]
    sib = spawn(sibCommand, args)
    sib.stdout.on 'data',  (output) -> stdout += output
    sib.stderr.on 'data',  (output) -> stderr += output
    sib.on        'close', (code)   -> onClose(code, stdout, stderr)
    sib.stdin.write(body)
    sib.stdin.end()

  withoutMovingScreenOrCursors: (editor, f) ->
    element       = editor.element
    cursors       = editor.getSelectedBufferRanges()
    scrollTop     = element.getScrollTop()
    scrollLeft    = element.getScrollLeft()
    f()
    editor.setSelectedBufferRanges(cursors)
    element.setScrollLeft(scrollLeft)
    element.setScrollTop(scrollTop)

  isntRuby: (editor) ->
    "ruby" != editor.getGrammar().name.toLowerCase()

  expectedRubyError: (editor, keymaps) ->
    grammarName = editor.getGrammar().name
    grammarKeys = @keystrokesFor editor, keymaps, "grammar-selector:show"
    howToOpenGrammarSelector =
      if grammarKeys?
        "`#{grammarKeys}` or click `#{grammarName}` in the bottom right of the window"
      else
        "click `#{grammarName}` in the bottom right of the window"
    """
    Atom thinks your file is `#{grammarName}`.

    To tell Atom that this is a `Ruby` file, use the Grammar Selector
    (#{howToOpenGrammarSelector}).

    The syntax highlighting will change and you'll see `Ruby` in the bottom-right.
    """

  keystrokesFor: (editor, keymaps, name) ->
    keymaps.findKeyBindings(command: name, target: editor.element)
           .map((cmd) -> cmd.keystrokes)
           .filter((ks) -> ks)[0]
