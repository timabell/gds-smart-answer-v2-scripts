# About

Scripts for assisting with management of the v2 versions of [smart answers](https://github.com/alphagov/smart-answers)

# Setup

Requires [kdiff3](http://kdiff3.sourceforge.net/) to be installed and available on your path.

I recommend cloning this repository and then symlinking to somewhere on your path. I find it handy to have `~/bin` (a folder called bin in your home directory) in the `$PATH` and put such scripts in there.  Then you can call this script from anywhere without the full path.
# Usage

Run the script from the root of smart answers folder in a terminal window.

Note that there are often files that need a v2 that this script doesn't know about, and sometimes shared files.

## Compare an existing v2

    create-v2.rb smart-answer-name --diff

## 3-way diff with a base revision

    create-v2.rb smart-answer-name --diff base-ref

`base-ref` is any valid git ref, e.g. a branch name, tag name or sha-1 hash

## Create a new v2

    create-v2.rb smart-answer-name

# Licence

MIT Licence

# More

Patches welcome :-)
