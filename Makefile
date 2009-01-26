default:
	@echo "Available targets:"
	@echo "  make install DESTDIR=/usr/local"
	@echo "  make clean"
	@echo "  make deb"
	@echo "  make cpan_update"


DESTDIR=usr

install:
	install -D -m 755 bin/bearmail-update        $(DESTDIR)/usr/sbin/bearmail-update
	#install -D -m 755 bin/bearmail-responder     $(DESTDIR)/usr/bin/bearmail-responder
	install -D -m 755 bin/bearmail-virus_send    $(DESTDIR)/usr/bin/bearmail-virus_send
	install -D -m 755 bin/bearmail-virus_notify  $(DESTDIR)/usr/bin/bearmail-virus_notify
	install -D -m 755 bin/bearmail-retrain_dspam $(DESTDIR)/usr/bin/bearmail-retrain_dspam
	#
	install -D -m 644 conf/mailmap               $(DESTDIR)/etc/bearmail/mailmap
	install -D -m 644 conf/dovecot.conf          $(DESTDIR)/etc/bearmail/dovecot.conf
	install -D -m 644 conf/postfix-main.cf       $(DESTDIR)/etc/bearmail/postfix-main.cf
	install -D -m 644 conf/postfix-master.cf     $(DESTDIR)/etc/bearmail/postfix-master.cf
	#
	install -D -m 644 README                     $(DESTDIR)/usr/share/doc/bearmail/README
#	install -D -m 644 COPYING                    $(DESTDIR)/usr/share/doc/bearmail/COPYING
	install -D -m 644 doc/specifications.txt     $(DESTDIR)/usr/share/doc/bearmail/specifications.txt
	#
	install -D -m 644 doc/man/bearmail-retrain_dspam.1.gz	$(DESTDIR)/usr/share/man/man1/bearmail-retrain_dspam.1.gz
	install -D -m 644 doc/man/bearmail-update.8.gz		$(DESTDIR)/usr/share/man/man8/bearmail-update.8.gz
	install -D -m 644 doc/man/bearmail-virus_notify.1.gz	$(DESTDIR)/usr/share/man/man1/bearmail-virus_notify.1.gz
	install -D -m 644 doc/man/bearmail-virus_send.1.gz	$(DESTDIR)/usr/share/man/man1/bearmail-virus_send.1.gz

clean:
	rm -f *-stamp
	rm -f debian/bearmail.debhelper.log
	rm -f debian/files
	rm -fr debian/bearmail

deb:
	dpkg-buildpackage -rfakeroot -uc -us


CPAN_MODULES= \
  http://search.cpan.org/CPAN/authors/id/M/MA/MARKSTOS/CGI-Application-4.21.tar.gz \
  http://search.cpan.org/CPAN/authors/id/M/MA/MARKSTOS/CGI-Application-Dispatch-2.15.tar.gz \
  http://search.cpan.org/CPAN/authors/id/T/TH/THILO/CGI-Application-Plugin-AutoRunmode-0.15.tar.gz \
  http://search.cpan.org/CPAN/authors/id/W/WO/WONKO/CGI-Application-Plugin-ViewCode-1.02.tar.gz \
  http://search.cpan.org/CPAN/authors/id/C/CE/CEESHEK/CGI-Application-Plugin-Redirect-1.00.tar.gz \
  http://search.cpan.org/CPAN/authors/id/C/CE/CEESHEK/CGI-Application-Plugin-Session-1.03.tar.gz \
  http://search.cpan.org/CPAN/authors/id/N/NE/NEKOKAK/CGI-Application-Plugin-DebugScreen-0.06.tar.gz \
  http://search.cpan.org/CPAN/authors/id/M/MS/MSCHWERN/UNIVERSAL-require-0.11.tar.gz \
  http://search.cpan.org/CPAN/authors/id/D/DR/DROLSKY/Exception-Class-1.26.tar.gz \
  http://search.cpan.org/CPAN/authors/id/D/DA/DAGOLDEN/Exception-Class-TryCatch-1.12.tar.gz \
  http://search.cpan.org/CPAN/authors/id/T/TM/TMTM/Class-Data-Inheritable-0.08.tar.gz \
  http://search.cpan.org/CPAN/authors/id/D/DR/DROLSKY/Devel-StackTrace-1.20.tar.gz \
  http://search.cpan.org/CPAN/authors/id/M/MA/MARKSTOS/CGI-Session-4.40.tar.gz \
  http://search.cpan.org/CPAN/authors/id/S/SA/SAMTREGAR/HTML-Template-2.9.tar.gz

cpan_fetch:
	mkdir -p .cache
	cd .cache; \
	for url in $(CPAN_MODULES); do test -e `basename $$url` || wget -nv -c $$url; done

cpan_unpack: cpan_fetch
	cd .cache; \
	for mod in *.tar.gz; do test -d $${mod/.tar.gz/} || tar xzf $$mod; done

cpan_fixes: cpan_unpack
	cd .cache; \
	cd CGI-Application-Plugin-AutoRunmode-0.15 && \
		mkdir -p lib/CGI/Application/Plugin && \
		mv AutoRunmode* lib/CGI/Application/Plugin 2>/dev/null; true
	cd .cache; \
	cd HTML-Template-2.9 && \
		mkdir -p lib/HTML && \
		mv Template* lib/HTML 2>/dev/null; true

cpan_update: cpan_fixes
	cd .cache; \
	for mod in */lib; do cp -rf $$mod/* ../lib; done

cpan_clean:
	rm -fr .cache
