.PHONY: help build serve clean update release

PORT ?= 8080

help:
	@echo "Available targets:"
	@echo "  make build    - Build the site to Output/"
	@echo "  make serve    - Build and serve at http://localhost:$(PORT)/"
	@echo "  make release  - Build the site in release mode"
	@echo "  make update   - Update Swift package dependencies"
	@echo "  make clean    - Remove Output/ and .publish/ caches"

build:
	swift run AdamYoungSite

release:
	swift run -c release AdamYoungSite

serve: build
	@echo "Serving Output/ at http://localhost:$(PORT)/"
	python3 -m http.server -d Output $(PORT)

update:
	swift package update

clean:
	rm -rf Output .publish .build
