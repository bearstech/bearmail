default:
	@echo "Available targets:"
	@echo "  make install DESTDIR=/usr/local"
	@echo "  make clean"
	@echo "  make deb"


DESTDIR=usr

install:
	install -D -m 755 bin/bearmail-update                                                   $(DESTDIR)/usr/sbin/bearmail-update

	install -D -m 755 bin/bearmail_install.sh                                               $(DESTDIR)/usr/share/doc/bearmail/examples/bearmail_install.sh

	install -D -m 644 conf/postfix-main.cf                                                  $(DESTDIR)/usr/share/bearmail/etc/postfix-main.cf
	install -D -m 644 conf/postfix-master.cf                                                $(DESTDIR)/usr/share/bearmail/etc/postfix-master.cf
	install -D -m 644 conf/dovecot.conf                                                     $(DESTDIR)/usr/share/bearmail/etc/dovecot.conf

	install -D -m 644 README                                                                $(DESTDIR)/usr/share/doc/bearmail/README

	install -D -m 644 doc/man/bearmail-update.8.gz                                          $(DESTDIR)/usr/share/man/man8/bearmail-update.8.gz


clean:
	rm -f *-stamp
	rm -f debian/bearmail.debhelper.log
	rm -f debian/files
	rm -fr debian/bearmail

deb:
	dpkg-buildpackage -rfakeroot -uc -us
