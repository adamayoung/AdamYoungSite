.PHONY: help install update build serve

help:
	@echo "Available targets:"
	@echo "  install   Install gems (bundle install)"
	@echo "  update    Update gems within Gemfile constraints (bundle update)"
	@echo "  build     Build the site into _site/"
	@echo "  serve     Run the local dev server at http://127.0.0.1:4000"

install:
	bundle install

update:
	bundle update

build:
	bundle exec jekyll build

serve:
	bundle exec jekyll serve
