default:
	@echo "Available targets:"
	@echo "  make install BMMAIN=/usr/local"
	@echo "  make clean"
	@echo "  make deb"


BMMAIN=usr
BMDSPAM=usr
BMWEB=usr
BMCLAMAV=usr

install:
	## bearmail
	# main
	install -D -m 755 bin/bearmail-update                                                   $(BMMAIN)/usr/sbin/bearmail-update
	install -D -m 755 bin/bearmail-switch                                                   $(BMMAIN)/usr/sbin/bearmail-switch
	install -D -m 644 conf/bearmail.conf                                                    $(BMMAIN)/etc/bearmail/bearmail.conf
	# postfix
	install -D -m 644 conf/postfix-main.cf                                                  $(BMMAIN)/etc/bearmail/postfix/main.cf
	install -D -m 644 conf/postfix-master.cf                                                $(BMMAIN)/etc/bearmail/postfix/master.cf
	install -D -m 644 conf/bearmail-client_access                                           $(BMMAIN)/etc/bearmail/postfix/bearmail-client_access
	install -D -m 644 conf/bearmail-helo_access                                             $(BMMAIN)/etc/bearmail/postfix/bearmail-helo_access
	# dovecot
	install -D -m 644 conf/dovecot.conf                                                     $(BMMAIN)/etc/bearmail/dovecot/dovecot.conf
	# doc
	install -D -m 644 README                                                                $(BMMAIN)/usr/share/doc/bearmail/README
	install -D -m 644 doc/man/bearmail-update.8.gz                                          $(BMMAIN)/usr/share/man/man8/bearmail-update.8.gz
	install -D -m 644 doc/man/bearmail-switch.8.gz                                          $(BMMAIN)/usr/share/man/man8/bearmail-switch.8.gz

	## bermail-clamav
	# postfix
	install -D -m 755 bin/bearmail-virus_send                                               $(BMCLAMAV)/usr/bin/bearmail-virus_send
	# clamsmtp
	install -D -m 755 bin/bearmail-virus_notify                                             $(BMCLAMAV)/usr/bin/bearmail-virus_notify
	install -D -m 644 conf/clamsmtpd.conf                                                   $(BMCLAMAV)/etc/bearmail/clamsmtp/clamsmtpd.conf
	# doc
	install -D -m 644 doc/man/bearmail-virus_send.1.gz                                      $(BMCLAMAV)/usr/share/man/man1/bearmail-virus_send.1.gz
	install -D -m 644 doc/man/bearmail-virus_notify.1.gz                                    $(BMCLAMAV)/usr/share/man/man1/bearmail-virus_notify.1.gz

	## bearmail-dspam
	# bin
	install -D -m 755 bin/bearmail-retrain_dspam                                            $(BMDSPAM)/usr/bin/bearmail-retrain_dspam
	install -D -m 755 bin/bearmail-dspam_cleaner                                            $(BMDSPAM)/usr/bin/bearmail-dspam_cleaner
	# conf
	install -D -m 644 conf/dspam/dspam.conf                                                 $(BMDSPAM)/etc/bearmail/dspam/dspam.conf
	install -D -m 644 conf/dspam/default.prefs                                              $(BMDSPAM)/etc/bearmail/dspam/default.prefs
	install -D -m 744 conf/dspam/dspam_tricks/auth.cgi                                      $(BMDSPAM)/etc/bearmail/dspam/dspam_tricks/auth.cgi
	install -D -m 744 conf/dspam/dspam_tricks/dspam_stats_wrapper.pl                        $(BMDSPAM)/etc/bearmail/dspam/dspam_tricks/dspam_stats_wrapper.pl
	install -D -m 644 conf/dspam/dspam_tricks/nav_login.html                                $(BMDSPAM)/etc/bearmail/dspam/dspam_tricks/nav_login.html
	# doc
	install -D -m 644 doc/man/bearmail-retrain_dspam.1.gz                                   $(BMDSPAM)/usr/share/man/man1/bearmail-retrain_dspam.1.gz
	install -D -m 644 doc/man/bearmail-dspam_cleaner.1.gz                                   $(BMDSPAM)/usr/share/man/man1/bearmail-dspam_cleaner.1.gz

	## bearmail-web
	# dspam-conf
	install -D -m 755 conf/dspam/webfrontend.conf                                           $(BMWEB)/etc/bearmail/dspam/webfrontend.conf
	install -D -m 744 conf/dspam/dspam_tricks/auth.cgi                                      $(BMWEB)/etc/bearmail/dspam/dspam_tricks/auth.cgi
	install -D -m 744 conf/dspam/dspam_tricks/dspam_stats_wrapper.pl                        $(BMWEB)/etc/bearmail/dspam/dspam_tricks/dspam_stats_wrapper.pl
	install -D -m 644 conf/dspam/dspam_tricks/nav_login.html                                $(BMWEB)/etc/bearmail/dspam/dspam_tricks/nav_login.html
	# dspam-webfrontconf
	install -D -m 744 conf/dspam/webfrontend/dspam/admin.cgi                                $(BMWEB)/usr/share/bearmail/dspam-webfrontend/dspam/admin.cgi
	install -D -m 744 conf/dspam/webfrontend/dspam/admingraph.cgi                           $(BMWEB)/usr/share/bearmail/dspam-webfrontend/dspam/admingraph.cgi
	install -D -m 744 conf/dspam/webfrontend/dspam/auth.cgi                                 $(BMWEB)/usr/share/bearmail/dspam-webfrontend/dspam/auth.cgi
	install -D -m 644 conf/dspam/webfrontend/dspam/base.css                                 $(BMWEB)/usr/share/bearmail/dspam-webfrontend/dspam/base.css
	install -D -m 744 conf/dspam/webfrontend/dspam/dspam.cgi                                $(BMWEB)/usr/share/bearmail/dspam-webfrontend/dspam/dspam.cgi
	install -D -m 644 conf/dspam/webfrontend/dspam/dspam-logo-small.gif                     $(BMWEB)/usr/share/bearmail/dspam-webfrontend/dspam/dspam-logo-small.gif
	install -D -m 744 conf/dspam/webfrontend/dspam/graph.cgi                                $(BMWEB)/usr/share/bearmail/dspam-webfrontend/dspam/graph.cgi
	install -D -m 644 conf/dspam/webfrontend/dspam/logout.gif                               $(BMWEB)/usr/share/bearmail/dspam-webfrontend/dspam/logout.gif
	install -D -m 644 conf/dspam/webfrontend/dspam-templates/nav_admin_error.html           $(BMWEB)/usr/share/bearmail/dspam-webfrontend/upstream-templates/nav_admin_error.html
	install -D -m 644 conf/dspam/webfrontend/dspam-templates/nav_admin_preferences.html     $(BMWEB)/usr/share/bearmail/dspam-webfrontend/upstream-templates/nav_admin_preferences.html
	install -D -m 644 conf/dspam/webfrontend/dspam-templates/nav_admin_status.html          $(BMWEB)/usr/share/bearmail/dspam-webfrontend/upstream-templates/nav_admin_status.html
	install -D -m 644 conf/dspam/webfrontend/dspam-templates/nav_admin_user.html            $(BMWEB)/usr/share/bearmail/dspam-webfrontend/upstream-templates/nav_admin_user.html
	install -D -m 644 conf/dspam/webfrontend/dspam-templates/nav_alerts.html                $(BMWEB)/usr/share/bearmail/dspam-webfrontend/upstream-templates/nav_alerts.html
	install -D -m 644 conf/dspam/webfrontend/dspam-templates/nav_analysis.html              $(BMWEB)/usr/share/bearmail/dspam-webfrontend/upstream-templates/nav_analysis.html
	install -D -m 644 conf/dspam/webfrontend/dspam-templates/nav_error.html                 $(BMWEB)/usr/share/bearmail/dspam-webfrontend/upstream-templates/nav_error.html
	install -D -m 644 conf/dspam/webfrontend/dspam-templates/nav_fragment.html              $(BMWEB)/usr/share/bearmail/dspam-webfrontend/upstream-templates/nav_fragment.html
	install -D -m 644 conf/dspam/webfrontend/dspam-templates/nav_history.html               $(BMWEB)/usr/share/bearmail/dspam-webfrontend/upstream-templates/nav_history.html
	install -D -m 644 conf/dspam/webfrontend/dspam-templates/nav_login.html                 $(BMWEB)/usr/share/bearmail/dspam-webfrontend/upstream-templates/nav_login.html
	install -D -m 644 conf/dspam/webfrontend/dspam-templates/nav_performance.html           $(BMWEB)/usr/share/bearmail/dspam-webfrontend/upstream-templates/nav_performance.html
	install -D -m 644 conf/dspam/webfrontend/dspam-templates/nav_preferences.html           $(BMWEB)/usr/share/bearmail/dspam-webfrontend/upstream-templates/nav_preferences.html
	install -D -m 644 conf/dspam/webfrontend/dspam-templates/nav_quarantine.html            $(BMWEB)/usr/share/bearmail/dspam-webfrontend/upstream-templates/nav_quarantine.html
	install -D -m 644 conf/dspam/webfrontend/dspam-templates/nav_viewmessage.html           $(BMWEB)/usr/share/bearmail/dspam-webfrontend/upstream-templates/nav_viewmessage.html
	# doc
	install -D -m 644 doc/mail-clients/fr/img/mail.0.png                                    $(BMWEB)/usr/share/bearmail/doc/fr/img/mail.0.png
	install -D -m 644 doc/mail-clients/fr/img/mail.1.png                                    $(BMWEB)/etc/bearmail/doc/fr/img/mail.1.png
	install -D -m 644 doc/mail-clients/fr/img/mail.2.png                                    $(BMWEB)/etc/bearmail/doc/fr/img/mail.2.png
	install -D -m 644 doc/mail-clients/fr/img/mail.3.png                                    $(BMWEB)/etc/bearmail/doc/fr/img/mail.3.png
	install -D -m 644 doc/mail-clients/fr/img/mail.4.png                                    $(BMWEB)/etc/bearmail/doc/fr/img/mail.4.png
	install -D -m 644 doc/mail-clients/fr/img/outlook.1.png                                 $(BMWEB)/etc/bearmail/doc/fr/img/outlook.1.png
	install -D -m 644 doc/mail-clients/fr/img/outlook.2.png                                 $(BMWEB)/etc/bearmail/doc/fr/img/outlook.2.png
	install -D -m 644 doc/mail-clients/fr/img/outlook.3.png                                 $(BMWEB)/etc/bearmail/doc/fr/img/outlook.3.png
	install -D -m 644 doc/mail-clients/fr/img/outlook.4.png                                 $(BMWEB)/etc/bearmail/doc/fr/img/outlook.4.png
	install -D -m 644 doc/mail-clients/fr/img/outlook.5.png                                 $(BMWEB)/etc/bearmail/doc/fr/img/outlook.5.png
	install -D -m 644 doc/mail-clients/fr/img/outlook.6.png                                 $(BMWEB)/etc/bearmail/doc/fr/img/outlook.6.png
	install -D -m 644 doc/mail-clients/fr/img/outlook.7.png                                 $(BMWEB)/etc/bearmail/doc/fr/img/outlook.7.png
	install -D -m 644 doc/mail-clients/fr/img/outlook_express.1.png                         $(BMWEB)/etc/bearmail/doc/fr/img/outlook_express.1.png
	install -D -m 644 doc/mail-clients/fr/img/outlook_express.2.png                         $(BMWEB)/etc/bearmail/doc/fr/img/outlook_express.2.png
	install -D -m 644 doc/mail-clients/fr/img/outlook_express.3.png                         $(BMWEB)/etc/bearmail/doc/fr/img/outlook_express.3.png
	install -D -m 644 doc/mail-clients/fr/img/outlook_express.4.png                         $(BMWEB)/etc/bearmail/doc/fr/img/outlook_express.4.png
	install -D -m 644 doc/mail-clients/fr/img/outlook_express.5.png                         $(BMWEB)/etc/bearmail/doc/fr/img/outlook_express.5.png
	install -D -m 644 doc/mail-clients/fr/img/outlook_express.6.png                         $(BMWEB)/etc/bearmail/doc/fr/img/outlook_express.6.png
	install -D -m 644 doc/mail-clients/fr/img/outlook_express.7.png                         $(BMWEB)/etc/bearmail/doc/fr/img/outlook_express.7.png
	install -D -m 644 doc/mail-clients/fr/img/outlook_express.8.png                         $(BMWEB)/etc/bearmail/doc/fr/img/outlook_express.8.png
	install -D -m 644 doc/mail-clients/fr/img/outlook_express.9.png                         $(BMWEB)/etc/bearmail/doc/fr/img/outlook_express.9.png
	install -D -m 644 doc/mail-clients/fr/img/outlook_express.10.png                        $(BMWEB)/etc/bearmail/doc/fr/img/outlook_express.10.png
	install -D -m 644 doc/mail-clients/fr/img/outlook_express.11.png                        $(BMWEB)/etc/bearmail/doc/fr/img/outlook_express.11.png
	install -D -m 644 doc/mail-clients/fr/img/thunderbird.1.png                             $(BMWEB)/etc/bearmail/doc/fr/img/thunderbird.1.png
	install -D -m 644 doc/mail-clients/fr/img/thunderbird.2.png                             $(BMWEB)/etc/bearmail/doc/fr/img/thunderbird.2.png
	install -D -m 644 doc/mail-clients/fr/img/thunderbird.3.png                             $(BMWEB)/etc/bearmail/doc/fr/img/thunderbird.3.png
	install -D -m 644 doc/mail-clients/fr/img/thunderbird.4.png                             $(BMWEB)/etc/bearmail/doc/fr/img/thunderbird.4.png
	install -D -m 644 doc/mail-clients/fr/img/thunderbird.5.png                             $(BMWEB)/etc/bearmail/doc/fr/img/thunderbird.5.png
	install -D -m 644 doc/mail-clients/fr/img/thunderbird.6.png                             $(BMWEB)/etc/bearmail/doc/fr/img/thunderbird.6.png
	install -D -m 644 doc/mail-clients/fr/img/thunderbird.7.png                             $(BMWEB)/etc/bearmail/doc/fr/img/thunderbird.7.png
	install -D -m 644 doc/mail-clients/fr/img/thunderbird.8.png                             $(BMWEB)/etc/bearmail/doc/fr/img/thunderbird.8.png
	install -D -m 644 doc/mail-clients/fr/img/thunderbird.9.png                             $(BMWEB)/etc/bearmail/doc/fr/img/thunderbird.9.png
	install -D -m 644 doc/mail-clients/fr/img/thunderbird.10.png                            $(BMWEB)/etc/bearmail/doc/fr/img/thunderbird.10.png                       
	install -D -m 644 doc/mail-clients/fr/img/thunderbird.11.png                            $(BMWEB)/etc/bearmail/doc/fr/img/thunderbird.11.png
	install -D -m 644 doc/mail-clients/fr/img/thunderbird.12.png                            $(BMWEB)/etc/bearmail/doc/fr/img/thunderbird.12.png
	install -D -m 644 doc/mail-clients/fr/img/thunderbird.13.png                            $(BMWEB)/etc/bearmail/doc/fr/img/thunderbird.13.png



clean:
	rm -f *-stamp
	rm -f debian/bearmail.debhelper.log
	rm -f debian/files
	rm -fr debian/bearmail

deb:
	dpkg-buildpackage -rfakeroot -uc -us


CPAN_MODULES= \
    http://search.cpan.org/CPAN/authors/id/M/MA/MARKSTOS/CGI-Application-4.31.tar.gz \
    http://search.cpan.org/CPAN/authors/id/M/MA/MARKSTOS/CGI-Application-Dispatch-2.16.tar.gz \
    http://search.cpan.org/CPAN/authors/id/T/TH/THILO/CGI-Application-Plugin-AutoRunmode-0.16.tar.gz \
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
