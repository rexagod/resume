TEX    := rexagod_resume-openfont.tex
PDF    := rexagod_resume-openfont.pdf
CLS    := rexagod-resume-openfont.cls
OUTDIR := build

# Linter flags: suppress common false-positives in resume templates
CHKTEX_FLAGS := -n1 -n2 -n8 -n11 -n36

.PHONY: all build lint preview watch clean install-deps

all: build

## build: Compile the document with tectonic (XeLaTeX-compatible)
build:
	@mkdir -p $(OUTDIR)
	tectonic --outdir $(OUTDIR) --keep-logs $(TEX)

## lint: Run chktex on the document
lint:
	chktex $(CHKTEX_FLAGS) $(TEX)

## preview: Build then open PDF in mupdf (lightweight terminal-adjacent viewer)
VIEWER := $(or $(shell command -v mupdf-gl 2>/dev/null), \
               $(shell command -v mupdf-x11 2>/dev/null), \
               $(shell command -v mupdf 2>/dev/null), \
               $(shell command -v xdg-open 2>/dev/null))

# Dark mode: invert all colors. Override: make preview DARK=0
DARK ?= 1
VIEWER_FLAGS = $(if $(filter 1,$(DARK)),-I)

preview: build
	@test -n "$(VIEWER)" || (echo "No PDF viewer found. Run: make install-deps"; exit 1)
	$(VIEWER) $(VIEWER_FLAGS) $(OUTDIR)/$(PDF)

VIEWER_PID := /tmp/.resume-viewer.pid

## watch: Auto-rebuild+preview on change; reuses the viewer window instead of stacking new ones
watch:
	@echo "Watching $(TEX) and $(CLS) for changes… (Ctrl-C to stop)"
	@test -n "$(VIEWER)" || (echo "No PDF viewer found. Run: make install-deps"; exit 1)
	@ls $(TEX) $(CLS) | entr -c -s '\
		$(MAKE) build && \
		{ [ -f $(VIEWER_PID) ] && kill $$(cat $(VIEWER_PID)) 2>/dev/null; true; } && \
		{ $(VIEWER) $(VIEWER_FLAGS) $(OUTDIR)/$(PDF) & echo $$! > $(VIEWER_PID); }'

## clean: Remove build artifacts
clean:
	rm -rf $(OUTDIR)

## install-deps: Install required tools via Homebrew
install-deps:
	brew install tectonic mupdf entr texlive
