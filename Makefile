all: opensusefs2.tar.gz

arch:=$(shell uname -m)
ifeq ("$(arch)","ppc64le")
        docker_image := "ppc64le/ubuntu:trusty"
        docker_file := cflinuxfs2/Dockerfile.$(arch)
        $(shell cp cflinuxfs2/Dockerfile $(docker_file))
        $(shell sed -i 's/FROM ubuntu:trusty/FROM ppc64le\/ubuntu:trusty/g' $(docker_file))
else
        docker_image := "ubuntu:trusty"
        docker_file := cflinuxfs2/Dockerfile
endif

opensusefs2.cid:
	docker build --no-cache -f $(docker_file) -t jandubois/opensusefs2 cflinuxfs2
	docker run --cidfile=opensusefs2.cid jandubois/opensusefs2 zypper se --installed-only --details | tee cflinuxfs2/opensusefs2_zypper.out

opensusefs2.tar: opensusefs2.cid
	mkdir -p tmp
	docker export `cat opensusefs2.cid` > tmp/opensusefs2.tar
	# Always remove the cid file in order to grab updated package versions.
	rm opensusefs2.cid

opensusefs2.tar.gz: opensusefs2.tar
	docker run -w /stacks -v `pwd`:/stacks $(docker_image) ./bin/make_tarball.sh opensusefs2
