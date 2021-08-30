if glob('mvnw') != "" || glob('mvnw.bat') != ""
    CompilerSet makeprg=mvnw\ clean\ compile
else
    CompilerSet makeprg=mvn\ -Dstyle.color=never\ clean\ compile
endif

" Set up Dispatch if it exists
if exists("g:loaded_dispatch")
    let b:dispatch = "mvn test" " Set default for :Dispatch command
    augroup DispatchMake
        autocmd!
        " Automatically :Make in background on write
        autocmd BufWritePost * silent execute("Make!")
    augroup END
endif

augroup Make
    autocmd!
    if has('win32') || has('win64')
        " After Dispatch :Make finishes
        autocmd QuickFixCmdPost cgetfile call s:ProcessQuickFixForMaven(getqflist())
        " After normal :make finishes
        autocmd QuickFixCmdPost *make* call s:ProcessQuickFixForMaven(getqflist())
    endif
augroup END


" Set up errorformat
" Ignored message
setlocal errorformat=
    \%-G[INFO]\ %.%#,
    \%-G[debug]\ %.%#
" Error message for POM
setlocal errorformat+=
    \[FATAL]\ Non-parseable\ POM\ %f:\ %m%\\s%\\+@%.%#line\ %l\\,\ column\ %c%.%#,
    \[%tRROR]\ Malformed\ POM\ %f:\ %m%\\s%\\+@%.%#line\ %l\\,\ column\ %c%.%#
" Error message for compiling
setlocal errorformat+=
    \[%tARNING]\ %f:[%l\\,%c]\ %m,
    \[%tRROR]\ %f:[%l\\,%c]\ %m
" Message from JUnit 5(5.3.X), TestNG(6.14.X), JMockit(1.43), and AssertJ(3.11.X)
setlocal errorformat+=
    \%+E%>[ERROR]\ %.%\\+Time\ elapsed:%.%\\+<<<\ FAILURE!,
    \%+E%>[ERROR]\ %.%\\+Time\ elapsed:%.%\\+<<<\ ERROR!,
    \%+Z%\\s%#at\ %f(%\\f%\\+:%l),
    \%+C%.%#
" Misc message removal
setlocal errorformat+=%-G%.%#,%Z

" Cleans up the file path on Windows
" Slightly modified from https://github.com/mikelue/vim-maven-plugin/blob/master/plugin/maven.vim
" Because the path in message output by Maven has '/<fullpath>' in windows
" system, this function would adapt the path for correct path of jump voer
" quickfix
function! <SID>ProcessQuickFixForMaven(qflist)
	for qfentry in a:qflist
		" Get the filename coming from VIM's quickfix
		if has_key(qfentry, "filename")
			let filename = qfentry.filename
		elseif qfentry.bufnr > 0
			let filename = bufname(qfentry.bufnr)
		else
			let filename = ""
		endif
		" //:~)

		" ==================================================
		" Process the file name for:
		" 1. Fix wrong file name in Windows system
		" 2. Convert class name(<full class name>.<method name>) to file name for unit test
		" ==================================================
		"
		" The file name which comes from full class name of Java.
		" It maybe includes method name.
		if qfentry.type =~ '^[EW]$' && filename =~ '\v^\f+$' " The file name matches valid file format under OS
			call s:AdaptFilenameOfError(qfentry, filename)
		endif
		" //:~)
	endfor

	call setqflist(a:qflist, 'r')
endfunction

function! <SID>AdaptFilenameOfError(qfentry, rawFileName)
	let rawFileName = a:rawFileName
	let shellSlash = &shellslash ? '/' : '\\'

	" ==================================================
	" Fix the /C:/source.code path generated by maven-compiler-plugin 3.0
	" ==================================================
	let headingShellSlashOfWin32 = '\v^' . shellSlash . '[a-zA-Z]:' . shellSlash
	if has("win32") && rawFileName =~ headingShellSlashOfWin32
		let a:qfentry.filename = substitute(rawFileName, '^' . shellSlash, '', '')
		unlet a:qfentry.bufnr
	endif
	" //:~)
endfunction
