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

### Installing and configuration ###

To install and configure the vim-Grammalecte plugin, refer to
the documentation:

  https://github.com/dpelle/vim-Grammalecte/blob/master/doc/Grammalecte.txt

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
