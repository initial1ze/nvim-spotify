if exists('g:loaded_spotify') | finish | endif " prevent loading file twice

let s:save_cpo = &cpo " save user coptions
set cpo&vim           " reset them to defaults

" command to run our plugin
command! SpotifyPlay lua require('spotify').play()
command! SpotifyPause lua require('spotify').pause()
command! SpotifyStop lua require('spotify').stop()
command! SpotifyNext lua require('spotify').next()
command! SpotifyPrev lua require('spotify').prev()
command! SpotifyToggle lua require('spotify').toggle()
command! SpotifyURI lua require('spotify').open_url()

let &cpo = s:save_cpo " and restore after
unlet s:save_cpo

let g:loaded_spotify = 1
