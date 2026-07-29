# TODO pin
REPOS := \
  "https://github.com/ADBond/havilering.git::havilering" \
  "https://github.com/ADBond/scalade.git::scalade" \

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
	@mkdir -p deps
	@for entry in $(REPOS); do \
	  url=$${entry%%::*}; name=$${entry##*::}; \
	  if [ -d "deps/$$name/.git" ]; then \
	    git -C deps/$$name pull --ff-only; \
	  else \
	    git clone --depth 1 $$url deps/$$name; \
	  fi; \
	done

build: clean
	cp -r src site
	sed -i -e "s/__BUILD_TIME__/$(DATE)/g" site/index.html

# 	TODO: do we need more than just vite build?
	@for entry in $(REPOS); do \
	  name=$${entry##*::}; \
	  echo "== Building $$name =="; \
	  ( cd deps/$$name && npm ci && \
	    npx vite build --base=/$(BASE_PATH)/$$name/ \
	      --outDir=../../$(OUT_DIR)/$$name --emptyOutDir ); \
	done

serve:
	npx http-server site

