"===============================================================================
"
"          File:  mapathon.vim
"
"   Description:  
"
"   VIM Version:  7.0+
"        Author:  Wolfgang Mehner, wolfgang-mehner@web.de
"  Organization:  
"       Version:  1.0
"       Created:  21.09.2017
"      Revision:  ---
"       License:  Copyright (c) 2017, Wolfgang Mehner
"===============================================================================

"-------------------------------------------------------------------------------
" === Basic checks ===   {{{1
"-------------------------------------------------------------------------------

" need at least 7.0
if v:version < 700
	echohl WarningMsg
	echo 'The plugin mapathon.vim needs Vim version >= 7.'
	echohl None
	finish
endif

" prevent duplicate loading
" need compatible
if &cp || ( exists('g:Mapathon_Version') && ! exists('g:Mapathon_DevelopmentOverwrite') )
	finish
endif

let g:Mapathon_Version= '0.9'     " version number of this script; do not change

"-------------------------------------------------------------------------------
" === Auxiliary functions ===   {{{1
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" s:ApplyDefaultSetting : Write default setting to a global variable.   {{{2
"
" Parameters:
"   varname - name of the variable (string)
"   value   - default value (string)
" Returns:
"   -
"
" If g:<varname> does not exists, assign:
"   g:<varname> = value
"-------------------------------------------------------------------------------

function! s:ApplyDefaultSetting ( varname, value )
	if ! exists ( 'g:'.a:varname )
		let { 'g:'.a:varname } = a:value
	endif
endfunction    " ----------  end of function s:ApplyDefaultSetting  ----------

"-------------------------------------------------------------------------------
" s:ErrorMsg : Print an error message.   {{{2
"
" Parameters:
"   line1 - a line (string)
"   line2 - a line (string)
"   ...   - ...
" Returns:
"   -
"-------------------------------------------------------------------------------

function! s:ErrorMsg ( ... )
	echohl WarningMsg
	for line in a:000
		echomsg line
	endfor
	echohl None
endfunction    " ----------  end of function s:ErrorMsg  ----------

"-------------------------------------------------------------------------------
" s:GetGlobalSetting : Get a setting from a global variable.   {{{2
"
" Parameters:
"   varname - name of the variable (string)
"   glbname - name of the global variable (string, optional)
" Returns:
"   -
"
" If 'glbname' is given, it is used as the name of the global variable.
" Otherwise the global variable will also be named 'varname'.
"
" If g:<glbname> exists, assign:
"   s:<varname> = g:<glbname>
"-------------------------------------------------------------------------------

function! s:GetGlobalSetting ( varname, ... )
	let lname = a:varname
	let gname = a:0 >= 1 ? a:1 : lname
	if exists ( 'g:'.gname )
		let { 's:'.lname } = { 'g:'.gname }
	endif
endfunction    " ----------  end of function s:GetGlobalSetting  ----------

"-------------------------------------------------------------------------------
" s:ImportantMsg : Print an important message.   {{{2
"
" Parameters:
"   line1 - a line (string)
"   line2 - a line (string)
"   ...   - ...
" Returns:
"   -
"-------------------------------------------------------------------------------

function! s:ImportantMsg ( ... )
	echohl Search
	echo join ( a:000, "\n" )
	echohl None
endfunction    " ----------  end of function s:ImportantMsg  ----------

"-------------------------------------------------------------------------------
" s:Redraw : Redraw depending on whether a GUI is running.   {{{2
"
" Example:
"   call s:Redraw ( 'r!', '' )
" Clear the screen and redraw in a terminal, do nothing when a GUI is running.
"
" Parameters:
"   cmd_term - redraw command in terminal mode (string)
"   cmd_gui -  redraw command in GUI mode (string)
" Returns:
"   -
"-------------------------------------------------------------------------------

function! s:Redraw ( cmd_term, cmd_gui )
	if has('gui_running')
		let cmd = a:cmd_gui
	else
		let cmd = a:cmd_term
	endif

	let cmd = substitute ( cmd, 'r\%[edraw]', 'redraw', '' )
	if cmd != ''
		silent exe cmd
	endif
endfunction    " ----------  end of function s:Redraw  ----------

"-------------------------------------------------------------------------------
" s:SID : Return the <SID>.   {{{2
"
" Parameters:
"   -
" Returns:
"   SID - the SID of the script (string)
"-------------------------------------------------------------------------------

function! s:SID ()
	return matchstr ( expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$' )
endfunction    " ----------  end of function s:SID  ----------

"-------------------------------------------------------------------------------
" s:UserInput : Input after a highlighted prompt.   {{{2
"
" Parameters:
"   prompt - the prompt (string)
"   text - the default input (string)
"   compl - completion (string, optional)
"   clist - list, if 'compl' is "customlist" (list, optional)
" Returns:
"   input - the user input, an empty sting if the user hit <ESC> (string)
"-------------------------------------------------------------------------------

function! s:UserInput ( prompt, text, ... )

	echohl Search                                         " highlight prompt
	call inputsave()                                      " preserve typeahead
	if a:0 == 0 || a:1 == ''
		let retval = input( a:prompt, a:text )
	elseif a:1 == 'customlist'
		let s:UserInputList = a:2
		let retval = input( a:prompt, a:text, 'customlist,<SNR>'.s:SID().'_UserInputEx' )
		let s:UserInputList = []
	else
		let retval = input( a:prompt, a:text, a:1 )
	endif
	call inputrestore()                                   " restore typeahead
	echohl None                                           " reset highlighting

	let retval  = substitute( retval, '^\s\+', "", "" )   " remove leading whitespaces
	let retval  = substitute( retval, '\s\+$', "", "" )   " remove trailing whitespaces

	return retval

endfunction    " ----------  end of function s:UserInput ----------

"-------------------------------------------------------------------------------
" s:UserInputEx : ex-command for s:UserInput.   {{{3
"-------------------------------------------------------------------------------
function! s:UserInputEx ( ArgLead, CmdLine, CursorPos )
	if empty( a:ArgLead )
		return copy( s:UserInputList )
	endif
	return filter( copy( s:UserInputList ), 'v:val =~ ''\V\<'.escape(a:ArgLead,'\').'\w\*''' )
endfunction    " ----------  end of function s:UserInputEx  ----------
" }}}3
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" s:WarningMsg : Print a warning/error message.   {{{2
"
" Parameters:
"   line1 - a line (string)
"   line2 - a line (string)
"   ...   - ...
" Returns:
"   -
"-------------------------------------------------------------------------------

function! s:WarningMsg ( ... )
	echohl WarningMsg
	echo join ( a:000, "\n" )
	echohl None
endfunction    " ----------  end of function s:WarningMsg  ----------

" }}}2
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" === Module setup ===   {{{1
"-------------------------------------------------------------------------------

let s:MapathonBrowserExec = 'firefox'
let s:MapathonBrowserArgs = ''

let s:MapathonBrowserSearchFlag = '-search'

call s:GetGlobalSetting ( 'MapathonBrowserExec' )
call s:GetGlobalSetting ( 'MapathonBrowserArgs' )
call s:GetGlobalSetting ( 'MapathonBrowserSearchFlag' )

"-------------------------------------------------------------------------------
" === Help facilities ===   {{{1
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" s:CallHelpWiki : Search a word in the dictionary.   {{{2
"
" Toy example: Please see 's:CallHelp' below.
"-------------------------------------------------------------------------------
function! s:CallHelpWiki ()

	if ! executable ( s:MapathonBrowserExec )
		return s:ErrorMsg ( 'browser not executable: "'.s:MapathonBrowserExec.'"' )
	endif

	let url  = 'https://en.wiktionary.org/wiki/%s'

	let word = expand ( '<cword>' )
	let word = substitute ( word, '\W', '', 'g' )

	if word == ''
		return s:ImportantMsg ( 'no word under cursor' )
	endif

	let url_f = printf ( url, word )

	call system ( shellescape( s:MapathonBrowserExec ).' '.s:MapathonBrowserArgs.' '.shellescape( url_f ) )

	if v:shell_error != 0
		return s:WarningMsg ( 'failed to execute browser' )
	endif

endfunction    " ----------  end of function s:CallHelpWiki  ----------

"-------------------------------------------------------------------------------
" s:CallHelp : Bring up help in a browser.   {{{2
"
" Brings up the help for a word under the cursor.
"
" Parameters:
"   url - the url, with an "%s" to include the word under the cursor (string)
" Returns:
"   -
"-------------------------------------------------------------------------------
function! s:CallHelp ( url )

	if ! executable ( s:MapathonBrowserExec )
		return s:ErrorMsg ( 'browser not executable: "'.s:MapathonBrowserExec.'"' )
	endif

	let word = expand ( '<cword>' )
	let word = substitute ( word, '\W', '', 'g' )

	if word == ''
		return s:ImportantMsg ( 'no word under cursor' )
	endif

	let url_f = printf ( a:url, word )

	call system ( shellescape( s:MapathonBrowserExec ).' '.s:MapathonBrowserArgs.' '.shellescape( url_f ) )

	if v:shell_error != 0
		return s:WarningMsg ( 'failed to execute browser' )
	endif

endfunction    " ----------  end of function s:CallHelp  ----------

"-------------------------------------------------------------------------------
" s:CallSearch : Bring up help in a browser.   {{{2
"
" Brings up the help for a word under the cursor.
"
" Parameters:
"   searchterm - the words to search for (string)
" Returns:
"   -
"-------------------------------------------------------------------------------
function! s:CallSearch ( searchterm )

	if ! executable ( s:MapathonBrowserExec )
		return s:ErrorMsg ( 'browser not executable: "'.s:MapathonBrowserExec.'"' )
	endif

	call system ( shellescape( s:MapathonBrowserExec ).' '.s:MapathonBrowserArgs.' '.s:MapathonBrowserSearchFlag.' '.shellescape( a:searchterm ) )

	if v:shell_error != 0
		return s:WarningMsg ( 'failed to execute browser' )
	endif

endfunction    " ----------  end of function s:CallSearch  ----------

"-------------------------------------------------------------------------------
" s:CmdLineWordDelete : Word-wise deletion on the cmd.-line.   {{{2
"
" Please see '<Plug>MapathonCmdLineWordDelete' below.
"
" Parameters:
"   -
" Returns:
"   repl - the replacement string (string)
"-------------------------------------------------------------------------------
function! s:CmdLineWordDelete ()

	" current cmd.-line and position of the cursor (adapt for string indexing)
	let cmdline = getcmdline()
	let cmdpos  = getcmdpos() - 1

	" split: <head><CURSOR><tail>
	let cmdline_head = strpart ( cmdline, 0, cmdpos )
	let cmdline_tail = strpart ( cmdline, cmdpos )

	if match ( cmdline_head, '\s$' ) > -1
		" remove consecutive spaces
		let cmdline_head = substitute ( cmdline_head, '\s\+$', '', '' )
	elseif match ( cmdline_head, '\w$' ) > -1
		" remove word
		let cmdline_head = substitute ( cmdline_head, '\w\+$', '', '' )
	else
		" remove one character
		let cmdline_head = substitute ( cmdline_head, '.$', '', '' )
	endif

	" overcome map silent
	" (silent map together with this trick seems to look prettier)
	call feedkeys(" \<bs>")

	" set new cmdline cursor position
	call setcmdpos ( len(cmdline_head)+1 )

	return cmdline_head.cmdline_tail
endfunction    " ----------  end of function s:CmdLineWordDelete  ----------

" }}}2
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" === Define maps ===   {{{1
"-------------------------------------------------------------------------------

command  -nargs=1  MapathonHelp    call <SID>CallHelp(<q-args>)
command  -nargs=+  MapathonSearch  call <SID>CallSearch(<q-args>)

nmap  <silent>  <Plug>MapathonCallHelpWiki  :call <SID>CallHelpWiki()<CR>

cmap  <silent>  <Plug>MapathonCmdLineWordDelete  <C-\>e<SID>CmdLineWordDelete()<CR>

" }}}1
"-------------------------------------------------------------------------------

" =====================================================================================
"  vim: foldmethod=marker
