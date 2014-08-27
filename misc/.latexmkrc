# latexmk rc -*-perl-*-
# General
#
$pdf_mode = 1;
$cleanup_mode = 2;
$pdflatex = 'pdflatex -shell-escape -interaction=nonstopmode -synctex=1 %O %S';

# 
$bibtex_use = 1;
$biber = 'biber %O %S';

# 
$preview_continuous_mode = 1;
$pdf_previewer = 'llpp';
$pdf_update_method = 4;
$pdf_update_command = 'xdotool search --name %S key r';
