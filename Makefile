default:
	@echo "Available targets:"
	@echo "  make install DESTDIR=/usr/local"
	@echo "  make clean"
	@echo "  make deb"


DESTDIR=usr

install:
	install -D -m 755 bin/bearmail-update                                                   $(DESTDIR)/usr/sbin/bearmail-update
	install -D -m 755 bin/bearmail-virus_send                                               $(DESTDIR)/usr/sbin/bearmail-virus_send
	install -D -m 755 bin/bearmail-virus_notify                                             $(DESTDIR)/usr/sbin/bearmail-virus_notify
	install -D -m 755 bin/bearmail-retrain_dspam                                            $(DESTDIR)/usr/sbin/bearmail-retrain_dspam
	install -D -m 755 bin/bearmail-dspam_cleaner	 					$(DESTDIR)/usr/sbin/bearmail-dspam_cleaner
	install -D -m 755 bin/bearmail-status		 					$(DESTDIR)/usr/sbin/bearmail-status
	#
	install -D -m 755 bin/bearmail_install.sh                                               $(DESTDIR)/usr/share/doc/bearmail/examples/bearmail_install.sh
	#install -D -m 755 bin/bearmail_uninstall.sh						$(DESTDIR)/usr/share/doc/bearmail/examples/bearmail_uninstall.sh
	#
	#install -D -m 644 conf/logrotate_mail							$(DESTDIR)/etc/logrotate.d/bearmail_mail
	#install -D -m 644 conf/mailmap                                                          $(DESTDIR)/etc/bearmail/mailmap
	#install -D -m 644 conf/my_fqdn                                                          $(DESTDIR)/etc/bearmail/extraconf/my_fqdn
#	install -D -m 644 conf/default_language							$(DESTDIR)/etc/bearmail/extraconf/default_language
#
	install -D -m 644 conf/postfix-main.cf                                                  $(DESTDIR)/usr/share/bearmail/etc/postfix-main.cf
	install -D -m 644 conf/postfix-master.cf                                                $(DESTDIR)/usr/share/bearmail/etc/postfix-master.cf
	install -D -m 644 conf/dovecot.conf                                                     $(DESTDIR)/usr/share/bearmail/etc/dovecot.conf
	install -D -m 644 conf/clamsmtpd.conf                                                   $(DESTDIR)/usr/share/bearmail/etc/clamsmtpd.conf

	#install -D -m 644 conf/roundcube_main.inc.php                                           $(DESTDIR)/etc/bearmail/extraconf/roundcube_main.inc.php
	#install -D -m 644 conf/roundcube_apache.conf                                            $(DESTDIR)/etc/bearmail/extraconf/roundcube_apache.conf
	# dspam :
	install -D -m 644 conf/dspam/dspam.conf                                                 $(DESTDIR)/usr/share/bearmail/etc/dspam/dspam.conf
	install -D -m 644 conf/dspam/default.prefs                                              $(DESTDIR)/usr/share/bearmail/etc/dspam/default.prefs
	#install -D -m 744 conf/dspam/dspam_tricks/auth.cgi                                      $(DESTDIR)/usr/share/bearmail/etc/dspam/dspam_tricks/auth.cgi
	#install -D -m 744 conf/dspam/dspam_tricks/dspam_stats_wrapper.pl                        $(DESTDIR)/usr/share/bearmail/etc/dspam/dspam_tricks/dspam_stats_wrapper.pl
	#install -D -m 644 conf/dspam/dspam_tricks/nav_login.html                                $(DESTDIR)/usr/share/bearmail/etc/dspam/dspam_tricks/nav_login.html
	# install -D -m 644 conf/dspam/dspam_var/dspam/system.log					$(DESTDIR)/usr/share/bearmail/etc/dspam/dspam_var/dspam/system.log
	# install -D -m 644 conf/dspam/dspam_var/dspam/data/local/globaluser/globaluser.css	$(DESTDIR)/usr/share/bearmail/etc/dspam/dspam_var/dspam/data/local/globaluser/globaluser.css
	# install -D -m 644 conf/dspam/dspam_var/dspam/data/local/globaluser/globaluser.lock	$(DESTDIR)/usr/share/bearmail/etc/dspam/dspam_var/dspam/data/local/globaluser/globaluser.lock
	# install -D -m 644 conf/dspam/dspam_var/dspam/data/local/globaluser/globaluser.log	$(DESTDIR)/usr/share/bearmail/etc/dspam/dspam_var/dspam/data/local/globaluser/globaluser.log
	# install -D -m 644 conf/dspam/dspam_var/dspam/data/local/globaluser/globaluser.rstats	$(DESTDIR)/usr/share/bearmail/etc/dspam/dspam_var/dspam/data/local/globaluser/globaluser.rstats
	# install -D -m 644 conf/dspam/dspam_var/dspam/data/local/globaluser/globaluser.stats	$(DESTDIR)/usr/share/bearmail/etc/dspam/dspam_var/dspam/data/local/globaluser/globaluser.stats
	#install -D -m 755 conf/dspam/webfrontend.conf                                           $(DESTDIR)/usr/share/bearmail/etc/dspam/webfrontend.conf
	#install -D -m 744 conf/dspam/webfrontend/dspam/admin.cgi                                $(DESTDIR)/usr/share/bearmail/www/antispam/dspam/admin.cgi
	#install -D -m 744 conf/dspam/webfrontend/dspam/admingraph.cgi                           $(DESTDIR)/usr/share/bearmail/www/antispam/dspam/admingraph.cgi
	#install -D -m 744 conf/dspam/webfrontend/dspam/auth.cgi                                 $(DESTDIR)/usr/share/bearmail/www/antispam/dspam/auth.cgi
	#install -D -m 644 conf/dspam/webfrontend/dspam/base.css                                 $(DESTDIR)/usr/share/bearmail/www/antispam/dspam/base.css
	#install -D -m 744 conf/dspam/webfrontend/dspam/dspam.cgi                                $(DESTDIR)/usr/share/bearmail/www/antispam/dspam/dspam.cgi
	#install -D -m 644 conf/dspam/webfrontend/dspam/dspam-logo-small.gif                     $(DESTDIR)/usr/share/bearmail/www/antispam/dspam/dspam-logo-small.gif
	#install -D -m 744 conf/dspam/webfrontend/dspam/graph.cgi                                $(DESTDIR)/usr/share/bearmail/www/antispam/dspam/graph.cgi
	#install -D -m 644 conf/dspam/webfrontend/dspam/logout.gif                               $(DESTDIR)/usr/share/bearmail/www/antispam/dspam/logout.gif
	#install -D -m 644 conf/dspam/webfrontend/dspam-templates/nav_admin_error.html           $(DESTDIR)/usr/share/bearmail/www/antispam/dspam-templates/nav_admin_error.html
	#install -D -m 644 conf/dspam/webfrontend/dspam-templates/nav_admin_preferences.html     $(DESTDIR)/usr/share/bearmail/www/antispam/dspam-templates/nav_admin_preferences.html
	#install -D -m 644 conf/dspam/webfrontend/dspam-templates/nav_admin_status.html          $(DESTDIR)/usr/share/bearmail/www/antispam/dspam-templates/nav_admin_status.html
	#install -D -m 644 conf/dspam/webfrontend/dspam-templates/nav_admin_user.html            $(DESTDIR)/usr/share/bearmail/www/antispam/dspam-templates/nav_admin_user.html
	#install -D -m 644 conf/dspam/webfrontend/dspam-templates/nav_alerts.html                $(DESTDIR)/usr/share/bearmail/www/antispam/dspam-templates/nav_alerts.html
	#install -D -m 644 conf/dspam/webfrontend/dspam-templates/nav_analysis.html              $(DESTDIR)/usr/share/bearmail/www/antispam/dspam-templates/nav_analysis.html
	#install -D -m 644 conf/dspam/webfrontend/dspam-templates/nav_error.html                 $(DESTDIR)/usr/share/bearmail/www/antispam/dspam-templates/nav_error.html
	#install -D -m 644 conf/dspam/webfrontend/dspam-templates/nav_fragment.html              $(DESTDIR)/usr/share/bearmail/www/antispam/dspam-templates/nav_fragment.html
	#install -D -m 644 conf/dspam/webfrontend/dspam-templates/nav_history.html               $(DESTDIR)/usr/share/bearmail/www/antispam/dspam-templates/nav_history.html
	#install -D -m 644 conf/dspam/webfrontend/dspam-templates/nav_login.html                 $(DESTDIR)/usr/share/bearmail/www/antispam/dspam-templates/nav_login.html
	#install -D -m 644 conf/dspam/webfrontend/dspam-templates/nav_performance.html           $(DESTDIR)/usr/share/bearmail/www/antispam/dspam-templates/nav_performance.html
	#install -D -m 644 conf/dspam/webfrontend/dspam-templates/nav_preferences.html           $(DESTDIR)/usr/share/bearmail/www/antispam/dspam-templates/nav_preferences.html
	#install -D -m 644 conf/dspam/webfrontend/dspam-templates/nav_quarantine.html            $(DESTDIR)/usr/share/bearmail/www/antispam/dspam-templates/nav_quarantine.html
	#install -D -m 644 conf/dspam/webfrontend/dspam-templates/nav_viewmessage.html           $(DESTDIR)/usr/share/bearmail/www/antispam/dspam-templates/nav_viewmessage.html
	# domainkey / dkim / spf :
	# install -D -m 644 conf/dk-filter							$(DESTDIR)/usr/share/bearmail/etc/dk-filter
	# install -D -m 644 conf/dkim-filter							$(DESTDIR)/usr/share/bearmail/etc/dkim-filter
	# install -D -m 644 conf/dkim-filter.conf						$(DESTDIR)/usr/share/bearmail/etc/dkim-filter.conf
	# install -D -m 644 conf/postfix.key							$(DESTDIR)/etc/ssl/certs/postfix.key
	# install -D -m 644 conf/postfix.key							$(DESTDIR)/etc/bearmail/keys/postfix.key
	# install -D -m 644 conf/postfix.key							$(DESTDIR)/etc/ssl/private/postfix_private.key
	# install -D -m 644 conf/dkim-keylist							$(DESTDIR)/etc/bearmail/keys/dkim-keylist
	#
	install -D -m 644 README                                                                $(DESTDIR)/usr/share/doc/bearmail/README
#	install -D -m 644 COPYING                                                               $(DESTDIR)/usr/share/doc/bearmail/COPYING
#	install -D -m 644 doc/specifications.txt                                                $(DESTDIR)/usr/share/doc/bearmail/specifications.txt
#	install -D -m 644 doc/mail-clients/fr/img/mail.0.png                                    $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/mail.0.png
#	install -D -m 644 doc/mail-clients/fr/img/mail.1.png                                    $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/mail.1.png
#	install -D -m 644 doc/mail-clients/fr/img/mail.2.png                                    $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/mail.2.png
#	install -D -m 644 doc/mail-clients/fr/img/mail.3.png                                    $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/mail.3.png
#	install -D -m 644 doc/mail-clients/fr/img/mail.4.png                                    $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/mail.4.png
#	install -D -m 644 doc/mail-clients/fr/img/outlook.1.png                                 $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/outlook.1.png
#	install -D -m 644 doc/mail-clients/fr/img/outlook.2.png                                 $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/outlook.2.png
#	install -D -m 644 doc/mail-clients/fr/img/outlook.3.png                                 $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/outlook.3.png
#	install -D -m 644 doc/mail-clients/fr/img/outlook.4.png                                 $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/outlook.4.png
#	install -D -m 644 doc/mail-clients/fr/img/outlook.5.png                                 $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/outlook.5.png
#	install -D -m 644 doc/mail-clients/fr/img/outlook.6.png                                 $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/outlook.6.png
#	install -D -m 644 doc/mail-clients/fr/img/outlook.7.png                                 $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/outlook.7.png
#	install -D -m 644 doc/mail-clients/fr/img/outlook_express.1.png                         $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/outlook_express.1.png
#	install -D -m 644 doc/mail-clients/fr/img/outlook_express.2.png                         $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/outlook_express.2.png
#	install -D -m 644 doc/mail-clients/fr/img/outlook_express.3.png                         $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/outlook_express.3.png
#	install -D -m 644 doc/mail-clients/fr/img/outlook_express.4.png                         $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/outlook_express.4.png
#	install -D -m 644 doc/mail-clients/fr/img/outlook_express.5.png                         $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/outlook_express.5.png
#	install -D -m 644 doc/mail-clients/fr/img/outlook_express.6.png                         $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/outlook_express.6.png
#	install -D -m 644 doc/mail-clients/fr/img/outlook_express.7.png                         $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/outlook_express.7.png
#	install -D -m 644 doc/mail-clients/fr/img/outlook_express.8.png                         $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/outlook_express.8.png
#	install -D -m 644 doc/mail-clients/fr/img/outlook_express.9.png                         $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/outlook_express.9.png
#	install -D -m 644 doc/mail-clients/fr/img/outlook_express.10.png                        $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/outlook_express.10.png
#	install -D -m 644 doc/mail-clients/fr/img/outlook_express.11.png                        $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/outlook_express.11.png
#	install -D -m 644 doc/mail-clients/fr/img/thunderbird.1.png                             $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/thunderbird.1.png
#	install -D -m 644 doc/mail-clients/fr/img/thunderbird.2.png                             $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/thunderbird.2.png
#	install -D -m 644 doc/mail-clients/fr/img/thunderbird.3.png                             $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/thunderbird.3.png
#	install -D -m 644 doc/mail-clients/fr/img/thunderbird.4.png                             $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/thunderbird.4.png
#	install -D -m 644 doc/mail-clients/fr/img/thunderbird.5.png                             $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/thunderbird.5.png
#	install -D -m 644 doc/mail-clients/fr/img/thunderbird.6.png                             $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/thunderbird.6.png
#	install -D -m 644 doc/mail-clients/fr/img/thunderbird.7.png                             $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/thunderbird.7.png
#	install -D -m 644 doc/mail-clients/fr/img/thunderbird.8.png                             $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/thunderbird.8.png
#	install -D -m 644 doc/mail-clients/fr/img/thunderbird.9.png                             $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/thunderbird.9.png
#	install -D -m 644 doc/mail-clients/fr/img/thunderbird.10.png                            $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/thunderbird.10.png
#	install -D -m 644 doc/mail-clients/fr/img/thunderbird.11.png                            $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/thunderbird.11.png
#	install -D -m 644 doc/mail-clients/fr/img/thunderbird.12.png                            $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/thunderbird.12.png
#	install -D -m 644 doc/mail-clients/fr/img/thunderbird.13.png                            $(DESTDIR)/usr/share/bearmail/www/doc/fr/img/thunderbird.13.png
	#
	install -D -m 644 doc/man/bearmail-retrain_dspam.1.gz                                   $(DESTDIR)/usr/share/man/man1/bearmail-retrain_dspam.1.gz
	install -D -m 644 doc/man/bearmail-update.8.gz                                          $(DESTDIR)/usr/share/man/man8/bearmail-update.8.gz
	install -D -m 644 doc/man/bearmail-virus_notify.1.gz                                    $(DESTDIR)/usr/share/man/man1/bearmail-virus_notify.1.gz
	install -D -m 644 doc/man/bearmail-virus_send.1.gz                                      $(DESTDIR)/usr/share/man/man1/bearmail-virus_send.1.gz
	install -D -m 644 doc/man/bearmail-dspam_cleaner.1.gz                                   $(DESTDIR)/usr/share/man/man1/bearmail-dspam_cleaner.1.gz
	install -D -m 644 doc/man/bearmail-status.1.gz                                   $(DESTDIR)/usr/share/man/man1/bearmail-status.1.gz

clean:
	rm -f *-stamp
	rm -f debian/bearmail.debhelper.log
	rm -f debian/files
	rm -fr debian/bearmail

deb:
	dpkg-buildpackage -rfakeroot -uc -us
