# seeing-is-believing package

Integrates Atom with [Seeing Is Believing](https://github.com/JoshCheek/seeing_is_believing),
allowing Ruby programs to show you the result of each line of code that was evaluated.


# Using the package
Press `Command+Option+B` to annotate every line,
`Command+Option+N` to annotate just marked lines
(mark them by placing `# =>` after them, or below them),
`Command+Option+V` to remove annotations


# Install the Atom package
Atom -> Preferences -> Packages

Search for "seeing is believing"

Click "install"


# You need [Seeing Is Believing](https://github.com/JoshCheek/seeing_is_believing) installed

This integrates into your specific environment, it doesn't come with the gem loaded by default.
Install it by getting into the environment you want, and running `$ gem install seeing_is_believing`
If you're using rbenv, you'll need to `$ rbenv rehash` afterwards. You can check that it worked
by running `$ seeing_is_believing --version`

# Configure to work with your environment

This package does not know how to find your Ruby, you have to configure that yourself.
You do this at the top level of your config directory (on my Mac, that's at `~/.atom/config.cson`).
Define the following keys, changing them as appropriate for your environment,
and according to your preferences.

**Descriptions of the variables below.**

```coffeescript
'seeing-is-believing':
  'ruby-command': '/Users/josh/.rbenv/shims/ruby'
  'add-to-env':
    "RBENV_VERSION": "2.0.0-p0"
  'flags': [
      '-Ku',
      '--alignment-strategy', 'line',
      '--number-of-captures', '200',
      '--result-length',      '200',
      '--alignment-strategy', 'chunk',
      '--timeout',            '12'
    ]
```

ruby-command
------------

`ruby-command` is the location of the ruby program you want to run.

**rvm** You need to [make a wrapper](https://rvm.io/integration/textmate),
an executable that sets everything up for you. Run `rvm list strings` to see
what versions you have available, then `$ rvm wrapper YOUR_VERSION sib`, e.g.
`$ rvm wrapper ruby-2.0.0-p481 sib`. Now, set your `ruby-command` to
whatever `$ which sib_ruby` tells you.

**rbenv and chruby** set it to whatever `$ which ruby` tells you



add-to-env
----------

Here, you can specify environment variables.

**rvm** If you used the wrapper approach above, then you don't need any environment variables.

**rbenv** You need to set `RBENV_VERSION`, you can see what your it should be with
`env | grep RBENV_VERSION`.

**chruby** Chruby requires a lot of variables,
look in your current environment to see what they should be.
[Here is an example](https://github.com/JoshCheek/atom-seeing-is-believing/blob/d271293ee62deb3f7748ce2fa5343b1efc4a50de/lib/seeing-is-believing.coffee#L54-65)
that worked for me.


modifying the path
------------------
To add paths, use the environment variable `ADD_TO_PATH` (this will go in `add-to-env` key)

**rvm** you should be fine

**rbenv** You might need to set it to `/Users/YOUR_USERNAME/.rbenv/shims` I'm not sure.

**chruby** run `env | grep PATH` and set it to whatever you think was added by chruby.
You can look at [my example](https://github.com/JoshCheek/atom-seeing-is-believing/blob/d271293ee62deb3f7748ce2fa5343b1efc4a50de/lib/seeing-is-believing.coffee#L54-65)
to see what I wound up adding:


flags
-----

You can get a full list of flags by running `seeing_is_believing --help`


Troubleshooting
---------------

* Do you have the gem installed in the correct environment? (load your env in whatever way you do that, and then `gem which seeing_is_believing`)
* Do you have the package installed? (Command+Shift+P and start typing "seeing", you should see the commands and be able to run them from there)
* What do the logs say? (use Command+Option+I to run the console, the package will print some debugging information you can look at)

# LICENSE

```
       DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                   Version 2, December 2004

Copyright (C) 2014 Josh Cheek <josh.cheek@gmail.com>

Everyone is permitted to copy and distribute verbatim or modified
copies of this license document, and changing it is allowed as long
as the name is changed.

           DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
  TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

 0. You just DO WHAT THE FUCK YOU WANT TO.
```
