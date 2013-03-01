default:
	@echo "Available targets:"
	@echo "  make install DESTDIR=/usr/local"
	@echo "  make clean"
	@echo "  make deb"


install: install-bearmail install-antivirus
install-bearmail:
	install -D -m 755 bin/bearmail-update                               $(DESTDIR)/usr/sbin/
	install -D -m 755 bin/bearmail-switch                               $(DESTDIR)/usr/sbin/
	install -D -m 755 bin/bearmail-sieve_*                              $(DESTDIR)/usr/sbin/
	install -D -m 644 conf/postfix/*                                    $(DESTDIR)/etc/bearmail/postfix/
	install -D -m 644 conf/dovecot/*                                    $(DESTDIR)/etc/bearmail/dovecot/
	install -D -m 644 lib/BearMail/Backend.pm                           $(DESTDIR)/usr/share/perl5/BearMail/
	install -D -m 644 lib/BearMail/Backend/Files.pm                     $(DESTDIR)/usr/share/perl5/BearMail/Backend/
	install -D -m 644 doc/man/bearmail-update.8                         $(DESTDIR)/usr/share/man/man8/
	install -D -m 644 doc/man/bearmail-switch.8                         $(DESTDIR)/usr/share/man/man8/
	install -D -m 644 doc/man/bearmail-sieve_*                          $(DESTDIR)/usr/share/man/man8/
install-antivirus:
	install -D -m 644 conf/clamav/default                               $(DESTDIR)/etc/bearmail/clamav/default
	install -D -m 644 conf/clamav/freshclam.conf                        $(DESTDIR)/etc/bearmail/clamav/freshclam.conf
	install -D -m 644 conf/clamav/clamd.conf                            $(DESTDIR)/etc/bearmail/clamav/clamd.conf
	install -D -m 644 conf/clamav/clamav-milter.conf                    $(DESTDIR)/etc/bearmail/clamav/clamav-milter.conf

clean:
	rm -f *-stamp
	rm -f debian/bearmail.debhelper.log
	rm -f debian/files
	rm -fr debian/bearmail
	rm -fr debian/bearmail-antivirus

deb:
	dpkg-buildpackage -rfakeroot -uc -us -A
