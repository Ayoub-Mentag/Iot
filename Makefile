.PHONY: p1 p2 p3 bonus clean

p1:
	VAGRANT_CWD=./p1 vagrant up

p2:
	VAGRANT_CWD=./p2 vagrant up

p3:
	./p3/scripts/install.sh

bonus:
	./bonus/scripts/install.sh

clean:
	vagrant box remove bento/ubuntu-20.04
	VAGRANT_CWD=./p1 vagrant destroy -f ; rm -rf .vagrant
	VAGRANT_CWD=./p2 vagrant destroy -f ; rm -rf .vagrant
	k3d cluster delete my-cluster