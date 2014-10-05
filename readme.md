# My convoluted ~/src or dotfiles setup

So this is the src dir I (more or) less use for setting up my dotfiles.

Hitchhikers guide to the insanity.

I install this by running something like ``curl https://raw.githubusercontent.com/mitchty/src/master/bootstrap.sh | sh``.

This links everything from ``~/Developer/github.com/mitchty/src/dotfiles/*`` to ``~/.file|dirname``. It doesn't save anything or copy things around at all, so caveat emptor there if anyone but me runs this.

Then if I have any site specific things I need to customize, I run ``~/Developer/github.com/mitchty/src/site.sh sitename``.

That sets up ``~/site/local`` as a link to ``~/site-name``

Then the fun begins, my ``.profile|.kshrc|.zshrc`` are somewhat convoluted in that I couldn't ``chsh`` my login shell to ``/bin/zsh`` where I work, so it actually searches for zsh and then execs into it if found.

Outside of that inanity, the real fun begins when ``.zshrc`` sources in:
``~/Developer/github.com/mitchty/src/funcs/sourceme``

This sources all of the files in ``~/Developer/github.com/mitchty/src/funcs`` to setup all the rest as needed.

I have separate files for oses I use that get sourced from within ``src/funcs/oses`` as needed. There isn't much interesting to view here as I tend to put interesting(ish) things into my site clones which happen to be private.

Finally the ``~/Developer/github.com/mitchty/src/funcs`` or ``~/site-local`` dir can have a host dir with host specific customization.

As for the rest, it's mostly a mishmash of crap I've written over the years, most of varying usefulness/utility. A lot of it probably doesn't work anymore but I rarely delete things.
