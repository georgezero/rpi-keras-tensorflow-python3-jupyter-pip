IMGNAME = rpi-keras-tensorflow-python3-jupyter-pip
VERSION = 1.0.1
USER=georgezero
.PHONY: all build test taglatest  

all: build test

build:
	@docker build -t $(IMGNAME):$(VERSION) --rm . && echo Buildname: $(IMGNAME):$(VERSION)
test:
	sudo docker run -it \
        --name $(IMGNAME)_test \
		-p 8888:8888 -p 6006:6006 \
		-v /$(pwd)/tensorflow:/notebooks \
	--rm \
	$(IMGNAME):$(VERSION) \
        /pocketmine/start.sh || sudo docker stop $(IMGNAME)_test && docker rm $(IMGNAME)_test
run: 
	sudo docker run -it \
        --name $(IMGNAME)_run \
		-p 8888:8888 -p 6006:6006 \
		-v /$(pwd)/tensorflow:/notebooks \
	$(IMGNAME):$(VERSION) 
stop:
	@docker stop $(IMGNAME)_test || docker stop $(IMGNAME)_run || docker stop $(IMGNAME)_shell
	@docker rm $(IMGNAME)_test || docker rm $(IMGNAME)_run || docker rm $(IMGNAME)_shell
shell:
	@sudo docker run -t \
        --name $(IMGNAME)_shell \
		-p 8888:8888 -p 6006:6006 \
		-v /$(pwd)/tensorflow:/notebooks \
        -ti --entrypoint=/bin/bash \
	--rm \
	$(IMGNAME):$(VERSION) || sudo docker stop $(IMGNAME)_shell && docker rm $(IMGNAME)_shell
clean:
	@docker ps -a |grep $(IMGNAME) |cut -f 1 -d' '|xargs -P1 -i docker stop {}
	@docker ps -a |grep $(IMGNAME) |cut -f 1 -d' '|xargs -P1 -i docker rm {}
	@docker rmi $(IMGNAME):$(VERSION)
taglatest:
	docker tag $(IMGNAME):$(VERSION) $(IMGNAME):latest
	docker tag $(IMGNAME):$(VERSION) $(USER)/$(IMGNAME):$(VERSION)
	docker tag $(IMGNAME):$(VERSION) $(USER)/$(IMGNAME):latest
push:
	docker push $(USER)/$(IMGNAME)
	docker push $(USER)/$(IMGNAME):$(VERSION)
release: taglatest push

# 1.0.1 add jupyter lab 0.20, TF 1.0.1
# 0.2 add jupyterthemes, zsh, tmux
# 0.11 add tensorflow 0.11, keras, pandas, statsmodels
