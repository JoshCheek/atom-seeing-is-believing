# seeing-is-believing package

Integrates Atom with [Seeing Is Believing](https://github.com/JoshCheek/seeing_is_believing),
allowing Ruby programs to show you the result of each line of code that was evaluated.

Here is an example session:

![example](https://s3.amazonaws.com/josh.cheek/images/scratch/sib-example1.gif)

[Here](https://vimeo.com/73866851) is a longer video that goes into more details.

## Using the package

Keybindings:

* `Command+Option+B` to annotate every line
* `Command+Option+N` to annotate just marked lines (mark them by placing `# =>` after them, or below them)
* `Command+Option+V` to remove annotations

Snippets (use SiB to play around with ideas without needing a complex environment):

* `s_arb` in-memory ActiveRecord::Base code, so you can play with models without Rails.
* `s_sinatra` Example Sinatra app with Rack-style invocation setup for you to play with.
* `s_nokogiri` Parse html, play with css selectors, etc.
* `s_reflection` Examples of useful reflection tools.


## Install the Atom package

* Atom -> Preferences -> Packages
* Search for "seeing is believing"
* Click "install"

Or, you can do it from the command line `$ apm install seeing-is-believing`


## You need [Seeing Is Believing](https://github.com/JoshCheek/seeing_is_believing) installed

This integrates into your specific environment, it doesn't come with the gem loaded by default.
Install it by getting into the environment you want, and running `$ gem install seeing_is_believing`
If you're using rbenv, you'll need to `$ rbenv rehash` afterwards. You can check that it worked
by running `$ seeing_is_believing --version`

## Using the default configuration

This package uses somewhat intelligent defaults,
but in reality, it does not know how to find your Ruby, or what settings you want to use.
**The defaults will only work if you launch atom from the console**
(this is because it will then inherit your environment variables)

## Custom configuration

To customize it to always work, regardless of how you start Atom, edit your config file
(on my Mac, that's at `~/.atom/config.cson`).
Add the following keys (as of 0.138.0, they go under 'global', before that,
you can just append this to the bottom of the file),
changing them as appropriate for your environment,
and according to your preferences.

[**Here is what my configuration looks like**](https://gist.github.com/JoshCheek/ff2a4e82587b68f3b190)

**Here are the configuraiton options you can set**

Descriptions of the variables are below.

```coffeescript
'seeing-is-believing':
  'ruby-command': 'path/to/your/ruby'
  'add-to-env':
    "SOME_KEY":    "SOME_VALUE"
    "ADD_TO_PATH": "dir1:dir2"
  'flags': [
      '--alignment-strategy', 'chunk',
      '--number-of-captures', '300',
      '--line-length',        '1000',
      '--timeout',            '12'
  ]
```

### ruby-command

`ruby-command` is the location of the ruby program you want to run.

**rvm** You need to [make a wrapper](https://rvm.io/integration/textmate),
an executable that sets everything up for you. Run `rvm list strings` to see
what versions you have available, then `$ rvm wrapper YOUR_VERSION sib`, e.g.
`$ rvm wrapper ruby-2.0.0-p481 sib`. Now, set your `ruby-command` to
whatever `$ which sib_ruby` tells you.

**rbenv** set it to whatever `$ which ruby` tells you

**chruby** You can set it to whatever `$ which ruby` tells you,
and then set environment variables as described below,
or you can make your own wrapper like [this](https://github.com/JoshCheek/dotfiles/blob/c307d7c0af66c616281c82b48f0f28d3ea190a40/bin/sib_ruby),
and then set it to the path to that wrapper.


### add-to-env

Here, you can specify environment variables.

**rvm** If you used the wrapper approach above, then you don't need any environment variables.

**rbenv** You need to set `RBENV_VERSION`,
you can see what your it should be with `$ env | grep RBENV_VERSION`.

**chruby** If you made your own wrapper above, you don't need to do anything here.
Otherwise, chruby requires a lot of variables,
look in your current environment to see what they should be.
[Here is an example](https://github.com/JoshCheek/atom-seeing-is-believing/blob/d271293ee62deb3f7748ce2fa5343b1efc4a50de/lib/seeing-is-believing.coffee#L54-65)
that worked for me.
It might also be worth setting your SHELL environment variable
to bash, otherwise [this](https://github.com/postmodern/chruby/blob/dadcdba85e50fd2b62930d6bb7835972873f879b/bin/chruby-exec#L36)
could fuck up (e.g. I set mine to fish for other packages that actually launch a shell,
which causes, this to happen).


### modifying the path
To add paths, use the environment variable `ADD_TO_PATH` (this will go in `add-to-env` key)

**rvm** you should be fine

**rbenv** You might need to set it to `/Users/YOUR_USERNAME/.rbenv/shims` I'm not sure.

**chruby** If you used the wrapper above, you don't need to do anything here.
Otherwise, run `env | grep PATH` and set it to whatever you think was added by chruby.
You can look at [my example](https://github.com/JoshCheek/atom-seeing-is-believing/blob/d271293ee62deb3f7748ce2fa5343b1efc4a50de/lib/seeing-is-believing.coffee#L54-65)
to see what I wound up adding.


### flags

You can get a full list of flags by running `seeing_is_believing --help`
The most common and useful ones are going to be:

* "--alignment-strategy" (I recommend "chunk")
* "--number-of-captures" (say you have a line that executes in a loop, 1 million times,
  you don't want to record all 1 million of those invocations, because it's too much information,
  it would eat up your memory, maybe start paging, and just generally take a really long time to execute)
* '--line-length' (how much output to show, use this to keep it from affecting editor performance or getting too spammy)
* '--timeout' (say you accidentally have an infinite loop... don't want to wait around forever!)


## Troubleshooting

* Do you have the gem installed in the correct environment? (load your env in whatever way you do that, and then `gem which seeing_is_believing`)
* Do you have the package installed? (Command+Shift+P and start typing "seeing", you should see the commands and be able to run them from there)
* What do the logs say? (use Command+Option+I to run the console, the package will print some debugging information you can look at)
* Did Atom get really messed up after you installed this? Probably the `~/.atom/config.cson` has a syntax error or something, which will mess up all the configuration, not just Seeing Is Believing's

## <a href="http://www.wtfpl.net/"><img src="http://www.wtfpl.net/wp-content/uploads/2012/12/wtfpl.svg" height="20" alt="WTFPL" /></a> License

    Copyright (C) 2014 Josh Cheek <josh.cheek@gmail.com>

    This program is free software. It comes without any warranty,
    to the extent permitted by applicable law.
    You can redistribute it and/or modify it under the terms of the
    Do What The Fuck You Want To Public License,
    Version 2, as published by Sam Hocevar.
    See http://www.wtfpl.net/ for more details.
