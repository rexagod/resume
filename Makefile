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
preview: build
	mupdf $(OUTDIR)/$(PDF)

## watch: Auto-rebuild whenever the .tex or .cls file changes (requires entr)
watch:
	@echo "Watching $(TEX) and $(CLS) for changes… (Ctrl-C to stop)"
	ls $(TEX) $(CLS) | entr -c $(MAKE) build

## clean: Remove build artifacts
clean:
	rm -rf $(OUTDIR)

## install-deps: Install required tools via Homebrew
install-deps:
	brew install tectonic mupdf entr texlive
