# [Racer](https://atom.io/packages/racer)

> Providing intelligent code completion and "find definition" for Rust via [Racer](https://github.com/phildawes/racer).

![A screenshot of racer at work](https://cloud.githubusercontent.com/assets/1395968/2886329/0396e8a4-d4e2-11e3-9813-f6697a01d959.gif)

## Installation

1. Ensure you have the Atom package [language-rust](https://atom.io/packages/language-rust) installed and active.
2. Ensure you have [Racer](https://github.com/phildawes/racer) properly installed.
3. Ensure you have a copy of the [rustc source code](http://www.rust-lang.org/install.html) extracted on your disk.
4. Install this package via Atom's package manager:
 * go to `Preferences > Packages`, search for `racer`, and install it
 * **OR** use the command line `apm install racer`).

## Configuration

go to `Preferences > Packages`, search for `racer`, and click `Settings`

| Display Name                             | Description                                                                                                                                                      | Required | Name                          |
|:-----------------------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------|:---------|:------------------------------|
| Path to the Racer executable             | Full path (including executable) of Racer's binary (e.g. `/Users/me/racer/bin/racer` or `c:\racer\bin\racer.exe`)                                                | `YES`    | `racer.racerBinPath`          |
| Path to the Rust source code directory   | Should point to the rustc source directory (e.g. `/Users/me/code/rust/src/`)                                                                                     | `YES`    | `racer.rustSrcPath`           |
| Autocomplete Scope Blacklist             | Scopes for which no suggestions will be made (e.g. `.source.go .comment`)                                                                                        | `NO`     | `racer.autocompleteBlacklist` |
| Show position for editor with definition | Can be `Right` or `New`. If `Right` is selected and your view is vertically split, the item will be open in the rightmost pane of the current active pane's row. | `NO`     | `racer.show`                  |

## Usage

Just type some code in a `.rs` file, and racer will automatically show you some suggestions (using the autocomplete+ package provided by Atom).

You can also `find definition` of your current element by pushing the `F3` key.

## FAQ:
### Racer doesn't work, or I see plugin errors when I type:
Your configuration is probably wrong:
* The path to Racer has to point to the *Racer binary executable* (this is **NOT a directory** we request here).
* The Rustc source has to point to the *base directory of the source code*.
* The Atom package *language-rust* is installed and active.

### My project tree (tree-view) flickers:
We use temporary files to communicate with racer and need to place them along with your source files.

We shaped them as `._racertmpXXXXX` because the `._*` files are ignored by default by Atom.

Change your configuration so that the `tree-view` package follows Atom ignore rules!
* Open `Settings > Packages`
* Search the core package called `tree-view`, click `Settings`
* Check the box called `Hide Ignored Names`

Note: by the way, you can control what is ignored in the main Atom settings top panel.
* Open `Settings > Settings` (the first tab)
* Search the "core settings" section for the `Ignored Names` field
* check that it's either empty (default), or contains `._*`, or add yourself a `._racertmp*` entry if you already changed the settings.

### Why do you constantly put (and remove) temporary files in my project:
We use temporary files to communicate with racer and need to place them along with your source files so that racer:
* locates your project,
* provides completion for your whole projects code,
* locates your cargo file if it exists and use it to provide completion for your dependencies.
