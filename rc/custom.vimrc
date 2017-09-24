
" view help in the browser
nmap Hen <Plug>MapathonCallHelpWiki

nnoremap Hcp :MapathonHelp http://en.cppreference.com/mwiki/index.php?title=Special%%3ASearch&search=%s<CR>
"nnoremap Hen :MapathonHelp http://en.wiktionary.org/wiki/%s<CR>
nnoremap Hqt :MapathonHelp http://qt-project.org/doc/qt-4.8/%s.html<CR>

" configure your browser
"let g:MapathonBrowserExec = 'firefox'
"let g:MapathonBrowserArgs = '-new-window'
"let s:MapathonBrowserSearchFlag = '-search'

" CTRL+Backspace for word-wise deletion on the command-line
cmap <c-bs> <Plug>MapathonCmdLineWordDelete

