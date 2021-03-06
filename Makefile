# Makefile for OTP.

all: check

test: check
check:
	@./check.sh

# For a quick sanity check while developing, just run this.
quickcheck:
	@echo "### Encrypt and decrypt the README file, as a quick test -- ###"
	@echo "### (if README is printed below, onetime is still working). ###"
	@echo ""
	@./onetime -e -n -p tests/random-data-1 -o - README \
          | ./onetime -d -n -p tests/random-data-1 -o -

install:
	@install -m755 onetime $(DESTDIR)/usr/bin/

uninstall:
	@rm -v $(DESTDIR)/usr/bin/onetime

distclean: clean
clean:
	@rm -rf index.html test-msg.* *~ onetime-*.* onetime-*.tar.gz

dist:
	@git archive --format="tar.gz" -9                                   \
           --prefix="onetime-`./onetime --version | cut -f 3 -d " "`/"      \
                  -o onetime-`./onetime --version | cut -f 3 -d " "`.tar.gz \
           HEAD
	@git archive --format="zip" -9                                      \
           --prefix="onetime-`./onetime --version | cut -f 3 -d " "`/"      \
                  -o onetime-`./onetime --version | cut -f 3 -d " "`.zip    \
           HEAD

www: dist
	@./onetime --intro > intro.tmp
	@./onetime --help  > help.tmp
	@# Escape and indent the --intro and --help output.
	@sed -e 's/\&/\&amp;/g' < intro.tmp > intro.tmp.tmp
	@mv intro.tmp.tmp intro.tmp
	@sed -e 's/</\&lt;/g' < intro.tmp > intro.tmp.tmp
	@mv intro.tmp.tmp intro.tmp
	@sed -e 's/>/\&gt;/g' < intro.tmp > intro.tmp.tmp
	@mv intro.tmp.tmp intro.tmp
	@sed -e 's/^\(.*\)/   \1/g' < intro.tmp > intro.tmp.tmp
	@mv intro.tmp.tmp intro.tmp
	@sed -e 's/\&/\&amp;/g' < help.tmp > help.tmp.tmp
	@mv help.tmp.tmp help.tmp
	@sed -e 's/</\&lt;/g' < help.tmp > help.tmp.tmp
	@mv help.tmp.tmp help.tmp
	@sed -e 's/>/\&gt;/g' < help.tmp > help.tmp.tmp
	@mv help.tmp.tmp help.tmp
	@sed -e 's/^\(.*\)/   \1/g' < help.tmp > help.tmp.tmp
	@mv help.tmp.tmp help.tmp
	@cat index.html-top     \
             intro.tmp          \
             index.html-middle  \
             help.tmp           \
             index.html-bottom  \
           > index.html
	@# Substitute in the latest version number.
	@./onetime --version | cut -f 3 -d " " > version.tmp
	@sed -e "s/ONETIMEVERSION/`cat version.tmp`/g" \
           < index.html > index.html.tmp
	@mv index.html.tmp index.html
	@sed -e "s/ONETIMEVERSION/`cat version.tmp`/g" \
           < get.html-tmpl > get.html.tmp
	@mv get.html.tmp get.html
	@# Make the GPG link live.
	@sed -e 's/GnuPG,/<a href="http:\/\/www.gnupg.org\/">GnuPG<\/a>,/g' \
           < index.html > index.html.tmp
	@mv index.html.tmp index.html
	@# Make the Wikipedia link live.
	@sed -e 's| http://en.wikipedia.org/wiki/One-time_pad | <a href="http://en.wikipedia.org/wiki/One-time_pad">http://en.wikipedia.org/wiki/One-time_pad</a> |g' \
           < index.html > index.html.tmp
	@mv index.html.tmp index.html
	@# Make the SVN and CVS links live.
	@sed -e 's|Subversion or CVS,|<a href="http://subversion.tigris.org/">Subversion</a> or <a href="http://www.nongnu.org/cvs/">CVS</a>,|g' \
           < index.html > index.html.tmp
	@mv index.html.tmp index.html
	@# Make the author name link live.
	@sed -e 's|Karl Fogel|<a href="http://red-bean.com/kfogel">Karl Fogel</a>|g' \
           < index.html > index.html.tmp
	@mv index.html.tmp index.html
	@# Make the home page link live.
	@sed -e 's| http://www.red-bean.com/onetime/| <a href="http://www.red-bean.com/onetime/">http://www.red-bean.com/onetime/</a>|g' \
           < index.html > index.html.tmp
	@mv index.html.tmp index.html
	@# Make the license link live.
	@sed -e 's| LICENSE | <a href="LICENSE">LICENSE</a> |g' \
           < index.html > index.html.tmp
	@mv index.html.tmp index.html
	@rm intro.tmp help.tmp version.tmp

debian: deb
deb: dist
	(cd debian; ./make-deb.sh)
	@rm -rf onetime-1.*
