all:
	stack build

run:
	clear && stack build && stack exec app && cat index.html
