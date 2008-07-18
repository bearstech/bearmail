default:
	@echo "Available targets:"
	@echo "  make install DESTDIR=/usr/local"
	@echo "  make clean"
	@echo "  make deb"


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
