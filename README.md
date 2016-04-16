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

To customize it to always work, simply edit the values in the package settings.

[**Here is what my configuration looks like (from before atom package settings was used)**](https://gist.github.com/JoshCheek/ff2a4e82587b68f3b190)

### Seeing is believing command

This is the absolute path to your `seeing_is_believing` command. You may need to run
`which seeing_is_believing` or `rbenv which seeing_is_believing` to find this. Examples:
`/home/USERNAME/.gem/ruby/2.3.0/bin/seeing_is_believing` or `/usr/local/bin/bundle exec seeing_is_believing`.

### Flags

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
