default:
	@echo "Available targets:"
	@echo "  make install DESTDIR=/usr/local"
	@echo "  make clean"
	@echo "  make deb"


DESTDIR=/usr

install:
	install -D -m 755 bin/bearmail-update        $(DESTDIR)/sbin/bearmail-update
	install -D -m 755 bin/bearmail-responder     $(DESTDIR)/bin/bearmail-responder
	install -D -m 755 bin/bearmail-virus_send    $(DESTDIR)/bin/bearmail-virus_send
	install -D -m 755 bin/bearmail-virus_notify  $(DESTDIR)/bin/bearmail-virus_notify
	install -D -m 755 bin/bearmail-retrain_dspam $(DESTDIR)/bin/bearmail-retrain_dspam
	#
	install -D -m 644 conf/mailmap               $(DESTDIR)/etc/bearmail/mailmap
	install -D -m 644 conf/dovecot.conf          $(DESTDIR)/etc/bearmail/dovecot.conf
	install -D -m 644 conf/postfix-main.cf       $(DESTDIR)/etc/bearmail/postfix-main.cf
	install -D -m 644 conf/postfix-master.cf     $(DESTDIR)/etc/bearmail/postfix-master.cf
	#
	install -D -m 644 README                     $(DESTDIR)/doc/bearmail/README
	install -D -m 644 COPYING                    $(DESTDIR)/doc/bearmail/COPYING
	install -D -m 644 doc/specifications.txt     $(DESTDIR)/doc/bearmail/specifications.txt

clean:
	rm -f *-stamp
	rm -f debian/bearmail.debhelper.log
	rm -f debian/files
	rm -fr debian/bearmail

deb:
	dpkg-buildpackage -rfakeroot -uc -us
