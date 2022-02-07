# vim: ft=zsh

(( ! $+function[_page_readme_chpwd_handler] )) \
	|| add-zsh-hook chpwd _page_readme_chpwd_handler
