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
Install it by getting into the environment you want, and running:

```sh
$ gem install seeing_is_believing
$ seeing_is_believing -e '1 + 1'   # to check that it worked
```

If you use rbenv, you may need to `$ rbenv rehash`


## Configuration

### Custom / non-working Ruby environment

Atom loads your environment by launching a new shell and copying its environment
variables into Atom's environment variables. So, assuming that your shell sets
your Ruby, then everything should just work. Note that [it looks](https://github.com/atom/atom/blob/9ab6a07df3c9f271d9d4fb5ff2a9b257e3bc8fb7/src/update-process-env.js#L79)
in the `SHELL` environment variable to decide what shell to use
(you can change yours with `chsh`).

If `seeing_is_believing` is not available by default in a new shell (perhaps
because it's not located in a `$PATH` directory, or your Ruby environment needs
some fancier setup) then you can use the "Seeing is believing command"
configuration option to either change the name or pass an absolute path to a
script you wrote. This allows you total control over how to set it up.
I've used this to setup non-standard environments and then exec SiB.
When I want to try features from my development SiB, I set mine to `/Users/josh/code/seeing_is_believing/bin/seeing_is_believing`.


### Flags

You can get a full list of flags by running `seeing_is_believing --help`
The most common and useful ones are going to be:

* "--alignment-strategy" (defaults to "chunk", but you may want "file")
* "--number-of-captures" (say you have a line that executes in a loop, 1 million times,
  you don't want to record all 1 million of those invocations, because it's too much information,
  it would eat up your memory, maybe start paging, and just generally take a really long time to execute)
* '--line-length' (how much output to show, use this to keep it from affecting editor performance or getting too spammy)
* '--timeout' (say you accidentally have an infinite loop... don't want to wait around forever!)


## <a href="http://www.wtfpl.net/"><img src="http://www.wtfpl.net/wp-content/uploads/2012/12/wtfpl.svg" height="20" alt="WTFPL" /></a> License

    Copyright (C) 2014 Josh Cheek <josh.cheek@gmail.com>

    This program is free software. It comes without any warranty,
    to the extent permitted by applicable law.
    You can redistribute it and/or modify it under the terms of the
    Do What The Fuck You Want To Public License,
    Version 2, as published by Sam Hocevar.
    See http://www.wtfpl.net/ for more details.
