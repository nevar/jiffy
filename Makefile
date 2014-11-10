PROJECT = jiffy

TEST_DEPS = proper

dep_proper = git git@github.com:manopapad/proper master

LDFLAGS = -lstdc++

TEST_ERLC_OPTS ?= +debug_info +warn_export_vars +warn_shadow_vars \
	+warn_obsolete_guard -DTEST=1 -DEXTRA=1 -DJIFFY_DEV

include erlang.mk

CFLAGS += -fno-strict-aliasing
