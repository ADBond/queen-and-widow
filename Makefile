# TODO pin
REPOS := \
  "https://github.com/ADBond/havilering.git::havilering"

BASE_PATH := games
OUT_DIR   := dist/$(BASE_PATH)

.PHONY: all clone build clean serve clean-deps

all: clone build

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

build:
	cp -r src dist
# 	TODO: do we need more than just vite build?
	@for entry in $(REPOS); do \
	  name=$${entry##*::}; \
	  echo "== Building $$name =="; \
	  ( cd deps/$$name && npm ci && \
	    npx vite build --base=/$(BASE_PATH)/$$name/ \
	      --outDir=../../$(OUT_DIR)/$$name --emptyOutDir ); \
	done

serve: all
	npx http-server dist

clean:
	rm -rf dist

clean-deps:
	rm -rf deps
