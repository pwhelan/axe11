CROSS_PREFIX=armv8a-libreelec-linux-gnueabihf-
CCACHE?=
CC=$(CCACHE) $(CROSS_PREFIX)gcc
SDL_CONFIG=pkg-config sdl2
SDL_CFLAGS=$(shell $(SDL_CONFIG) --cflags)
SDL_LDFLAGS=$(shell $(SDL_CONFIG) --libs)

ifeq ($(MAKECMDGOALS),debug)
	CFLAGS=-g -O0 -fPIC $(SDL_CFLAGS)
	LDFLAGS=-flto -O0 -fPIC -shared $(SDL_LDFLAGS)
else
	CFLAGS=-flto -O3 -fPIC $(SDL_CFLAGS) -DNDEBUG
	LDFLAGS=-flto -O3 -s -fPIC -shared $(SDL_LDFLAGS)
endif

# Find what libraries to build
# $$ are used to flag targets as proto-phony
LIBS=$(wildcard */Makefile)
LIBSBUILD=$(patsubst %/Makefile,$$%/Makefile,$(LIBS))
LIBSCLEAN=$(patsubst %/Makefile,$$$$%/Makefile,$(LIBS))

$$$$%/Makefile: %/
	@$(MAKE) -C $< clean

$$%/Makefile: %/
	@$(MAKE) CC="$(CC)" CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)" -C $<

release: all
debug: all

all: $(LIBSBUILD)
	@echo Done building libraries

clean: $(LIBSCLEAN)
	@echo Done cleaning

install:
	echo "manually install them onto /opt/axe11 later"

distclean:
	@rm -rf build

.NOTPARALLEL:
