# vim: ft=zsh

(( ! $+functions[_page_readme_chpwd_handler] )) \
	|| add-zsh-hook chpwd _page_readme_chpwd_handler
