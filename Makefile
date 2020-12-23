# SPDX-License-Identifier: 0BSD
# -----------------------------------------------------------------------------

V_EXTRA =
VERSION = 0.1.0$(V_EXTRA)

-include .version.mk

man-y = act.1

all:

man: $(man-y)

clean:
	rm -f $(man-y)

distclean: clean
	rm -rf .version.mk

act.1: act.1.adoc
	asciidoctor -a manmanual="Act Manual" -a mansource="Act $(VERSION)" -b manpage -o $@ $<

.version.mk:
	if GIT_CEILING_DIRECTORIES="$${PWD%/*}" git rev-parse >/dev/null 2>&1; then \
		GIT_CEILING_DIRECTORIES="$${PWD%/*}" git describe --match "v[0-9]*" 2>/dev/null | sed 's/.*-/V_EXTRA = -/' >$@; \
	fi

.PHONY: all clean distclean
