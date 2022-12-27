# My dotfiles

This is a collection of the configuration files and scripts I use for various
tools and environments.

Although some files support macOS, most of them assume that they are used on a
GNU/Linux system. The systems I use include an Artix, a Manjaro and an Ubuntu
installation. All of them running i3wm and the arch-based systems without a DE.
I use [my fork][1] of [st][2] as terminal, [zsh][3] as shell and [neovim][4] as
text editor.

The repository mimics my `$HOME`, trying to conform to the [XDG Base Directory
Specification][5] as close as possible. An exception is `etc/ -> /etc/`, as well
as `meta/` and some other files in the root of the repository (e.g. this README
or the LICENSE) which are not in my `$HOME`.

The most interesting files are probably in [.config/zsh][6] and
[.config/vim][7].

## Installation

The repository content can be installed via [dotbot][8]. All existing files
which would be overridden are first packed into an archive for backup (see
[meta/archive][9]) and then dotbot places symlinks in the appropriate places for
the different files and folders in this repository.

To start the installation run:

```sh
$ ./meta/install
```

<!--- Links -->

[1]: https://github.com/druckdev/st
[2]: https://st.suckless.org/
[3]: https://www.zsh.org/
[4]: https://github.com/neovim/neovim
[5]: https://wiki.archlinux.org/title/XDG_Base_Directory
[6]: .config/zsh
[7]: .config/vim
[8]: https://github.com/anishathalye/dotbot
[9]: meta/archive
