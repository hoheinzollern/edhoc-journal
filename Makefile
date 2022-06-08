all:
	latexmk -pdf paper.tex

clean:
	latexmk -C
	latexmk -c

view:
	evince paper.pdf &
