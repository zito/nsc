dnl ###
dnl ### NSC -- Makefile Builder
dnl ### (c) 1997--2011 Martin Mares <mj@ucw.cz>
dnl ###
include(m4/dnslib.m4)

# Definition of primary domains; secondaries we needn't take care of

define(`PRIMARIES', `')

define(`nsc_prepend_cf_one', ` 'CFDIR/`nsc_file_name($1)')
define(`nsc_prepend_cf_multi', `nsc_iterate(`nsc_prepend_cf_one', $@)')
define(`PRIMARY', `divert(0)ZONEDIR/nsc_file_name($1):nsc_prepend_cf_multi($@) $(DDEPS)
	@bin/genzone nsc_file_name($1)`'nsc_prepend_cf_multi($@)

divert(-1)
define(`PRIMARIES', PRIMARIES ZONEDIR/nsc_file_name($1))
')

define(`REVERSE', `PRIMARY(nsc_if_v6($1,`nsc_revblock6($1)',`nsc_revaddr($1)'), shift($@))')

define(`BLACKHOLE', `define(`NEED_BLACKHOLE', 1)')
define(`CONFIG', `$1')	# for BLACKHOLE encapsulated in CONFIG...

# Insertion of raw makefile material

define(`MAKEFILE', `divert(0)$1
divert(-1)')

# Last words

define(`nsc_cleanup', `
ifdef(`NEED_BLACKHOLE', `PRIMARY(blackhole)')

divert(0)dnl
VERSDIR/.version: CFDIR/domains ROOTCACHE`'PRIMARIES`'ifdef(`NEED_BLACKHOLE',` ZONEDIR/blackhole')
	NAMED_RESTART_CMD
	touch VERSDIR/.version

clean:
	find BAKDIR ZONEDIR HASHDIR -maxdepth 1 -type f | xargs rm -f

clobber: clean
	rm -f Makefile named.conf bin/genzone

distclean: clobber
	find VERSDIR -maxdepth 1 -type f | xargs rm -f
')

divert(0)dnl
`#'
`#'	Nameserver Configuration Makefile
`#'	Generated by NSCVER (mkmf.m4) on CURRENT_DATE
`#'	Please don't edit manually
`#'

DDEPS=m4/nsc.m4 m4/dnslib.m4 cf/config

all: VERSDIR/.version
m4wrap(`nsc_cleanup')
divert(-1)
