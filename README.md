vim-peekaboo
============

![](https://cloud.githubusercontent.com/assets/700826/6095261/bb00340c-af96-11e4-9df5-9cd869673a11.gif)

Peekaboo extends `"` and `@` in normal mode and `<CTRL-R>` in insert mode so
you can see the contents of the registers.

Installation
------------

Using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'junegunn/vim-peekaboo'
```

Usage
-----

Peekaboo will show you the contents of the registers on the sidebar when you
hit `"` or `@` in normal mode or `<CTRL-R>` in insert mode. The sidebar is
automatically closed on subsequent key strokes.

You can toggle fullscreen mode by pressing spacebar.

Customization
-------------

```vim
" Default peekaboo window
let g:peekaboo_window = 'vertical botright 30new'

" Delay opening of peekaboo window (in ms. default: 0)
let g:peekaboo_delay = 750
```

License
-------

MIT

