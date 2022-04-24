" Create folds for all lines between a section start and either the next section
" start or blank line
setlocal foldexpr=getline(v:lnum)=~'^\\['?'>1':getline(v:lnum+1)=~'(^\\[\\|^$)'?'<1':getline(v:lnum)=~'^\\t'
