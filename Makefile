default:
	@echo "Available targets:"
	@echo "  make install DESTDIR=/usr/local"
	@echo "  make clean"
	@echo "  make deb"


install: install-bearmail install-antispam install-antivirus install-web
install-bearmail:
	install -D -m 755 bin/bearmail-update                               $(DESTDIR)/usr/sbin/
	install -D -m 755 bin/bearmail-switch                               $(DESTDIR)/usr/sbin/
	install -D -m 755 bin/bearmail-sieve_*                              $(DESTDIR)/usr/sbin/
	install -D -m 644 conf/bearmail.conf                                $(DESTDIR)/etc/bearmail/
	install -D -m 644 conf/postfix/*                                    $(DESTDIR)/etc/bearmail/postfix/
	install -D -m 644 conf/dovecot/*                                    $(DESTDIR)/etc/bearmail/dovecot/
	install -D -m 644 lib/BearMail/Backend.pm                           $(DESTDIR)/usr/share/perl5/BearMail/Backend.pm
	install -D -m 644 lib/BearMail/Backend/Files.pm                     $(DESTDIR)/usr/share/perl5/BearMail//Backend/Files.pm
#	install -D -m 644 README                                            $(DESTDIR)/usr/share/doc/bearmail/README
	install -D -m 644 doc/man/bearmail-update.8.gz                      $(DESTDIR)/usr/share/man/man8/bearmail-update.8.gz
	install -D -m 644 doc/man/bearmail-switch.8.gz                      $(DESTDIR)/usr/share/man/man8/bearmail-switch.8.gz
	install -D -m 644 doc/man/bearmail-sieve_*                          $(DESTDIR)/usr/share/man/man8/
install-antivirus:
	install -D -m 755 bin/bearmail-virus*                               $(DESTDIR)/usr/lib/bearmail/
	install -D -m 644 conf/clamsmtpd.conf                               $(DESTDIR)/etc/bearmail/clamsmtp/clamsmtpd.conf
install-antispam:
	install -D -m 755 bin/bearmail-retrain_dspam                        $(DESTDIR)/usr/lib/bearmail/
	install -D -m 755 bin/bearmail-dspam_cleaner                        $(DESTDIR)/usr/sbin/
	install -D -m 644 conf/dspam/*.conf                                 $(DESTDIR)/etc/bearmail/dspam/
	install -D -m 755 conf/dspam/webfrontend.pl                         $(DESTDIR)/etc/bearmail/dspam/webfrontend.conf
	install -D -m 644 conf/dspam/*.prefs                                $(DESTDIR)/etc/bearmail/dspam/
	install -D -m 644 conf/bearmail-dspam_incoming                      $(DESTDIR)/etc/bearmail/postfix/
	install -D -m 744 conf/dspam/dspam_tricks/*.cgi                     $(DESTDIR)/etc/bearmail/dspam/dspam_tricks/
	install -D -m 744 conf/dspam/dspam_tricks/*.pl                      $(DESTDIR)/etc/bearmail/dspam/dspam_tricks/
	install -D -m 644 conf/dspam/dspam_tricks/*.html                    $(DESTDIR)/etc/bearmail/dspam/dspam_tricks/
	install -D -m 644 conf/dspam/webfrontend/dspam/*.css                $(DESTDIR)/usr/share/bearmail/dspam-webfrontend/dspam/
	install -D -m 744 conf/dspam/webfrontend/dspam/*.cgi                $(DESTDIR)/usr/share/bearmail/dspam-webfrontend/dspam/
	install -D -m 644 conf/dspam/webfrontend/dspam/*.gif                $(DESTDIR)/usr/share/bearmail/dspam-webfrontend/dspam/
	install -D -m 644 conf/dspam/webfrontend/dspam-templates/*          $(DESTDIR)/usr/share/bearmail/dspam-webfrontend/upstream-templates/
	install -D -m 644 doc/man/bearmail-dspam_cleaner.8.gz               $(DESTDIR)/usr/share/man/man8/
install-web:
	install -D -m 644 doc/mail-clients/fr/img/*                         $(DESTDIR)/usr/share/bearmail/htdoc/fr/img/
	install -D -m 644 doc/mail-clients/fr/*html                         $(DESTDIR)/usr/share/bearmail/htdoc/fr/


clean:
	rm -f *-stamp
	rm -f debian/bearmail.debhelper.log
	rm -f debian/files
	rm -fr debian/bearmail
	rm -fr debian/bearmail-antivirus
	rm -fr debian/bearmail-antispam
	rm -fr debian/bearmail-web

deb:
	dpkg-buildpackage -rfakeroot -uc -us


CPAN_MODULES= \
    http://search.cpan.org/CPAN/authors/id/M/MA/MARKSTOS/CGI-Application-4.31.tar.gz \
    http://search.cpan.org/CPAN/authors/id/M/MA/MARKSTOS/CGI-Application-Dispatch-2.17.tar.gz \
    http://search.cpan.org/CPAN/authors/id/T/TH/THILO/CGI-Application-Plugin-AutoRunmode-0.16.tar.gz \
    http://search.cpan.org/CPAN/authors/id/M/MA/MARKSTOS/CGI-Application-Plugin-ConfigAuto-1.31.tar.gz \
    http://search.cpan.org/CPAN/authors/id/W/WO/WONKO/CGI-Application-Plugin-ViewCode-1.02.tar.gz \
    http://search.cpan.org/CPAN/authors/id/C/CE/CEESHEK/CGI-Application-Plugin-Redirect-1.00.tar.gz \
    http://search.cpan.org/CPAN/authors/id/C/CE/CEESHEK/CGI-Application-Plugin-Session-1.03.tar.gz \
    http://search.cpan.org/CPAN/authors/id/N/NE/NEKOKAK/CGI-Application-Plugin-DebugScreen-0.06.tar.gz \
    http://search.cpan.org/CPAN/authors/id/M/MS/MSCHWERN/UNIVERSAL-require-0.13.tar.gz \
    http://search.cpan.org/CPAN/authors/id/D/DR/DROLSKY/Exception-Class-1.29.tar.gz \
    http://search.cpan.org/CPAN/authors/id/D/DA/DAGOLDEN/Exception-Class-TryCatch-1.12.tar.gz \
    http://search.cpan.org/CPAN/authors/id/T/TM/TMTM/Class-Data-Inheritable-0.08.tar.gz \
    http://search.cpan.org/CPAN/authors/id/D/DR/DROLSKY/Devel-StackTrace-1.22.tar.gz \
    http://search.cpan.org/CPAN/authors/id/M/MA/MARKSTOS/CGI-Session-4.42.tar.gz \
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
	cd CGI-Application-Plugin-AutoRunmode-0.16 && \
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
