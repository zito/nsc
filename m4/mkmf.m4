dnl ###
dnl ### NSC -- Makefile Builder
dnl ### (c) 1997--2011 Martin Mares <mj@ucw.cz>
dnl ###
include(m4/dnslib.m4)

# Definition of primary domains; secondaries we needn't take care of

define(`PRIMARIES', `')

# Generate file name of reverse domain

define(`nsc_rev_to_ip4', `nsc_revaddr(patsubst(`$1', `\.in-addr\.arpa$', `'))')
define(`nsc_rev_to_ip6a', `ifelse($#, 1, `$1', `nsc_rev_to_ip6a(shift($@))$1')')
define(`nsc_rev_to_ip6g', `patsubst(patsubst(`$1', `....', `\&:'), `:$', `')')
define(`nsc_rev_to_ip6', `nsc_rev_to_ip6g(nsc_rev_to_ip6a(translit(`patsubst(`$1', `\.ip6\.arpa$', `')', `.', `,')))')
define(`nsc_rev_to_fwd', `ifelse(regexp(`$1', `\.arpa$'), -1, `$1',
    ifelse(regexp(`$1', `^\([0-9]+/\)?\([0-9]+\.\)+in-addr\.arpa'), 0, `nsc_rev_to_ip4(`$1')',
	regexp(`$1', `^\([0-9a-fA-F]\.\)+ip6.arpa'), 0, `nsc_rev_to_ip6(`$1')',
	`$1'))')

define(`nsc_quote_colon', `patsubst(`$1', `:', `\\:')')

define(`nsc_file_name_trans', ifelse(REVERSESOURCEMODE, `forward',
    ``nsc_rev_to_fwd(`$1')'',
    REVERSESOURCEMODE, `short',
    ``patsubst(`$1', `.\(ip6\|in-addr\).arpa$', `')'',
    ``$1''))

define(`nsc_file_name_src', `nsc_file_name(nsc_file_name_trans(`$1'))')
define(`nsc_src_files', `nsc_foreach(`F', `($@)', ` CFDIR/nsc_file_name_src(F)')')

define(`PRIMARY', `
pushdef(`_DEPS', nsc_quote(nsc_src_files($@)))
divert(0)ZONEDIR/nsc_gen_zone_fn(`$1'): Makefile dnl
nsc_quote_colon(esyscmd(`echo $(m4 -di -DHASHING m4/nsc.m4 '_DEPS` 2>&1 >/dev/null \
	    | sed -n "s/^m4debug: input read from //p;");
	    echo "generating dependencies for 'ZONEDIR/nsc_gen_zone_fn(`$1')`" >&2'))dnl
	@bin/genzone nsc_gen_zone_fn(`$1')`'nsc_quote_colon(_DEPS)`'ifdef(`NAMED_CHECKZONE_CMD', `
	@NAMED_CHECKZONE_CMD `$1' `$'@')

divert(-1)
popdef(`_DEPS')
define(`PRIMARIES', nsc_quote(PRIMARIES ZONEDIR/nsc_gen_zone_fn(`$1')))
')

define(`REVERSE', `PRIMARY(REV($1), shift($@))')

define(`BLACKHOLE', `define(`NEED_BLACKHOLE', 1)')
define(`CONFIG', `$1')	# for BLACKHOLE encapsulated in CONFIG...
define(`DNSSEC_MAINTAIN', `$1')
define(`DNSSEC_POLICY', `$2')
define(`VIEW', `define(`VIEWNAME', `$1')$2')

# Insertion of raw makefile material

define(`MAKEFILE', `divert(0)$1
divert(-1)')

# Last words

define(`nsc_cleanup', `
ifdef(`NEED_BLACKHOLE', `pushdev(`VIEWNAME')undefine(`VIEWNAME')PRIMARY(blackhole)popdef(`VIEWNAME')')

divert(0)dnl
VERSDIR/.version: CFDIR/domains ROOTCACHE`'PRIMARIES
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

all: VERSDIR/.version
m4wrap(`nsc_cleanup')
divert(-1)
