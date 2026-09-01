REPOS_JSON := config.json
BASE_PATH := games
OUT_DIR   := site/$(BASE_PATH)
DATE      := $(shell ./formatted_date.sh)

.PHONY: all clone build clean serve clean-deps

all: clean clone build

clean:
	rm -rf site

clean-deps:
	rm -rf deps

clone:
	python3 clone_modules.py $(REPOS_JSON)

build: clean
	cp -r src site
	sed -i -e "s/__BUILD_TIME__/$(DATE)/g" site/index.html
	python3 build_modules.py $(REPOS_JSON) $(BASE_PATH) $(OUT_DIR)

serve:
	npx http-server site

