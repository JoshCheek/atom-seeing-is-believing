# seeing-is-believing package

Integrates Atom with [Seeing Is Believing](https://github.com/JoshCheek/seeing_is_believing),
allowing Ruby programs to show you the result of each line of code that was evaluated.

# You need [Seeing Is Believing](https://github.com/JoshCheek/seeing_is_believing) installed

This integrates into your specific environment, it doesn't come with the gem loaded by default.
Install it by getting into the environment you want, and running `$ gem install seeing_is_believing`
If you're using rbenv, you'll need to `$ rbenv rehash` afterwards. You can check that it worked
by running `$ seeing_is_believing --version`

# Setup

This package does not know how to find your Ruby, you have to configure that yourself.
You do this in your config directory (on my Mac, that's at `~/.atom/config.cson`).
Define the following keys, changing them as appropriate for your environment,
and according to your preferences:

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
In this example, it is setup for rbenv. If you're using chruby, it would be
`/Users/josh/.rubies/ruby-2.1.1/bin/ruby`, for rvm, you need to [make a
wrapper](https://rvm.io/integration/textmate), which might look like
`$ rvm wrapper ruby-2.0.0-p481 sib`, and then your ruby command would be
whatever `$ which sib_ruby` returns. If you don't know where your
ruby manager is located, you can find it with `$ which ruby`.

add-to-env
----------

`add-to-env` Here, you can specify environment variables. rbenv requires
you to set `RBENV_VERSION`, you can see what your version is with
`env | grep RBENV_VERSION`, set it to that. rvm doesn't need any environment
variables set if you are using the wrapper approach (actually, it might
need you to modify the path -- read about that below). Chruby requires
a lot of variables, look in your current environment to see what they should be.
[Here is an example](https://github.com/JoshCheek/atom-seeing-is-believing/blob/d271293ee62deb3f7748ce2fa5343b1efc4a50de/lib/seeing-is-believing.coffee#L54-65)
that worked for me.

modifying the path
------------------
To add paths, use the environment variable `ADD_TO_PATH`.
For example, if you're using rbenv, you might need to set it to
`/Users/josh/.rbenv/shims:/usr/local/bin:/usr/bin:/bin`
I don't know, I'm using chruby right now.
Might switch back, though, who knows.

flags
-----

You can get a full list of flags by running `seeing_is_believing --help`

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
