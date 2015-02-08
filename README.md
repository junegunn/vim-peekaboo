vim-peekaboo
============

![](https://cloud.githubusercontent.com/assets/700826/6095261/bb00340c-af96-11e4-9df5-9cd869673a11.gif)

Peekaboo extends `"` and `@` so you can see the contents of the registers.

Installation
------------

Using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'junegunn/vim-peekaboo'
```

Customization
-------------

```vim
" Default peekaboo window
let g:peekaboo_window = 'vertical botright 30new'
```

Other possible values are:
* `[vertical] leftabove [N]new`
* `[vertical] rightbelow [N]new`
* `[vertical] topleft [N]new`
* `[vertical] botright [N]new`

Note: when vertical is ommitted, the window is split horizontally.

See also: 
* `:help new` ([vimdoc](http://vimdoc.sourceforge.net/htmldoc/windows.html#:new))
* `:help vertical` and everything below ([vimdoc](http://vimdoc.sourceforge.net/htmldoc/windows.html#:vertical))

License
-------

MIT

