.PHONY: p1 p2 p3 bonus clean

p1:
	VAGRANT_CWD=./p1 vagrant up

p2:
	VAGRANT_CWD=./p2 vagrant up

p3:
	./p3/scripts/install.sh

bonus:
	./bonus/scripts/install.sh