## What is Vim-Grammalecte? ##

Vim-Grammalecte is a plugin that integrates Grammalecte into Vim.
Grammalecte is an Open Source grammar checker for French.

See http://grammalecte.net for more details about Grammalecte.

## Screenshots ###

If you don't have time to read help files, this screenshot will give you
an idea of what the Grammalecte plugin does:

![alt text](http://dominique.pelle.free.fr/pic/GrammalecteVimTermPlugin.png "Grammalecte plugin")

In GVim (with curly underlines to highlight errors):

![alt text](http://dominique.pelle.free.fr/pic/GrammalecteGVimPlugin.png "Grammalecte plugin in GVim")

## Installation ##

### Installing the plugin ###

This plugin contains 3 files:

	autoload/grammalecte.vim
	plugin/Grammalecte.vim
	doc/Grammalecte.txt

Copy those files respectively into ~/.vim/autoload/ ,  ~/.vim/plugin
and ~/.vim/doc/ directories, and update the documentation tags using:

	vim -c 'helptags ~/.vim/doc'

You also have to enable plugins by adding these two lines in your .vimrc
file:

	set nocompatible
	filetype plugin on

If you prefer to use vim-plug, Vundle or Pathogen plugin managers,
the plugin is available on github at:

	https://github.com/dpelle/vim-Grammalecte

For example, using vim-plug, you can install the plugin by adding this line
in you ~/.vimrc:

  Plug 'dpelle/vim-Grammalecte'

Or using Vundle, you can install the plugin by adding this line in you ~/.vimrc:

  Plugin 'dpelle/vim-Grammalecte'


### Installing Grammalecte ###

To use this plugin, you need to install the Python Grammalecte program.
Grammalecte CLI & Server can be downloaded at:

	https://grammalecte.net/#download

Or:

	$ wget https://grammalecte.net/grammalecte/zip/Grammalecte-fr-v1.9.0.zip

Unzip the Grammalecte-fr-v1.9.0.zip file and specify the location
of Grammalecte into your ~/.vimrc file using something like:

	let g:grammalecte_cli_py='~/Downloads/Grammalecte-fr-v1.9.0.zip/grammalecte-cli.py'

## Description ##

The Grammalecte plugin defines 2 commands :GrammalecteCheck and
:GrammalecteClear.

	:GrammalecteCheck

Use the :GrammalecteCheck command to check the grammar in the current
buffer. This will highlight errors in the buffer. It will also open a new
scratch window with the list of grammar mistakes with further explanations
for each error. It also populates the location-list for the window.

The :GrammalecteCheck command accepts a range. You can for example check
grammar between lines 100 and 200 in buffer with :100,200GrammalecteCheck,
check grammar in the visual selection with :<',>'GrammalecteCheck, etc.
The default range is 1,$ (whole buffer).

	:GrammalecteClear

Use the :GrammalecteClear command to clear highlighting of grammar
mistakes, close the scratch window containing the list of errors, clear
and close the location-list.

See  :help Grammalecte  for more details.

## License ##

The VIM LICENSE applies to the Grammalecte.vim plugin (see
:help copyright except use "Grammalecte.vim" instead of "Vim".

Grammalecte is freely available under GPL.
