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

| Config                  | Default         | Description                                       |
| ------                  | -------         | -----------                                       |
| `g:peekaboo_window`     | `vert bo 30new` | Command for creating Peekaboo window              |
| `g:peekaboo_delay`      | 0 (ms)          | Delay opening of Peekaboo window                  |
| `g:peekaboo_compact`    | 0 (boolean)     | Compact display                                   |
| `g:peekaboo_prefix`     | Empty (string)  | Prefix for key mapping (e.g. `<leader>`)          |
| `g:peekaboo_ins_prefix` | Empty (string)  | Prefix for insert mode key mapping (e.g. `<c-x>`) |

License
-------

MIT
