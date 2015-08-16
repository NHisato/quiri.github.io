#!/usr/bin/make -f
.PHONY: publish draft new
#.SECONDARY:


ROOT_DIR=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
CACHE_DIR=.
R_DIR=$(CACHE_DIR)/_R
POST_DIR=$(CACHE_DIR)/_posts
IMAGES=images
IMAGE_DIR=$(CACHE_DIR)/$(IMAGES)
NAME=new

RMD_FILES=$(notdir $(wildcard $(R_DIR)/*.Rmd))
MD_FILES:=$(RMD_FILES:.Rmd=.md)
NEWEST=$(basename $(shell ls -t $(POST_DIR)/ | head -n 1))


publish: $(MD_FILES:%=$(POST_DIR)/%) 

draft: $(MD_FILES:%=$(R_DIR)/%)

new: 
	octopress new post '$(NAME)'
	mv '$(POST_DIR)'/'$(NEWEST)'.markdown '$(R_DIR)'/'$(NEWEST)'.Rmd

test:
	@echo $(NEWEST)

$(DOWNLOADS_DIR)/%.foo.gz:
	@mkdir -p '$(@D)'
	scp -F $(SSH) '$*':data/serverlogs.foo.txt.gz '$@'

$(R_DIR)/%.md: $(R_DIR)/%.Rmd
	@mkdir -p '$(@D)'	
	Rscript $(R_DIR)/build.R -b '$(CACHE_DIR)' -f '$(IMAGE_DIR)' -o '$@' '$<' \
		&& sed -i "s/\](.*\/$(IMAGES)/]({{ site.url }}\/$(IMAGES)/g" '$@'

$(POST_DIR)/%.md: $(R_DIR)/%.md
	cp '$<' '$@'	
