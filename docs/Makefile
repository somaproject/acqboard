
SOMATEX=tools/somatex/somatex.py
SOMATEXFLAGS=-s
BUILDIDR=BUILD

all: $(BUILDDIR)/acqboard.pdf

$(BUILDDIR)/acqboard.pdf: acqboard.tex
	$(SOMATEX) $(SOMATEXFLAGS) acqboard.tex

clean:
	rm -Rf $(BUILDDIR)

cleanall:
	rm -Rf `find . -name "BUILD" | xargs`
