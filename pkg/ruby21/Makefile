# $NetBSD: Makefile,v 1.11 2015/03/08 15:52:51 taca Exp $
#

DISTNAME=	${RUBY_DISTNAME}
PKGNAME=	${DISTNAME}
CATEGORIES=	lang ruby
MASTER_SITES=	${MASTER_SITE_RUBY}

MAINTAINER=	taca@NetBSD.org
HOMEPAGE=	${RUBY_HOMEPAGE}
COMMENT=	Ruby ${RUBY_VERSION} release minimum base package
LICENSE=	${RUBY_LICENSE}

RUBY_VERSION_SUPPORTED=	21

USE_LANGUAGES=		c
USE_TOOLS+=		pax yacc
GNU_CONFIGURE=		yes
TEST_TARGET=		test
CONFIGURE_ARGS+=	--enable-shared
WRKSRC=			${RUBY_WRKSRC}

MAKE_DIRS=		${RUBY_SITEARCHLIB} ${RUBY_VENDORARCHLIB}

#
# Don't refrect pkgsrc's INSTALL macro since Ruby expect it could
# execute by unprivileged user.
#
CONFIGURE_ENV+=		INSTALL="${INSTALL} ${COPY}" \
			INSTALL_DATA= INSTALL_PROGRAM= INSTALL_SCRIPT=

.include "../../mk/compiler.mk"

.if !empty(PKGSRC_COMPILER:Msunpro)
LIBS.SunOS+=	-B static -lsunmath -B dynamic -lm
LDFLAGS.SunOS+=	-L${SUNWSPROBASE}/lib -Wl,-R${SUNWSPROBASE}/lib
CONFIGURE_ENV+=	LDSHARED="${CC} -G"
.else
LIBS.SunOS+=	-lm
.endif

.if ${OPSYS} == "SunOS"
CONFIGURE_ENV+=	OBJCOPY=:
CONFIGURE_ENV+=	ac_cv_prog_PKG_CONFIG=""
.endif

.if ${OPSYS} == "MirBSD"
# if present, an unsupported sysconf call is used
CONFIGURE_ENV+=	ac_cv_func_getgrnam_r=no
.endif

# bmake doesn't like the codesign/POSTLINK constructs for Darwin.
.if ${OPSYS} == "Cygwin" || ${OPSYS} == "Darwin"
USE_TOOLS+=	gmake
MAKE_FILE=	GNUmakefile
.endif

# Ruby build process depends on config.status's content
CONFIG_STATUS_OVERRIDE=	# empty

MAKE_DIRS+=	${RUBY_SITERIDIR}
FILES_SUBST+=	DATE=${DATE:Q}

REQD_DIRS+=	${GEM_HOME}/cache
REQD_DIRS+=	${GEM_HOME}/doc

SUBST_CLASSES+=		conf
SUBST_STAGE.conf=	pre-install
SUBST_FILES.conf=	lib/rubygems/config_file.rb
SUBST_SED.conf=		-e "s|@PKG_SYSCONFDIR@|${PKG_SYSCONFDIR}|g"
SUBST_MESSAGE.conf=	Fixing configuration files.

.include "options.mk"

.include "../../ruby/ruby/rubyversion.mk"

.if !empty(RUBY_SUFFIX)
CONFIGURE_ARGS+= --program-suffix=${RUBY_SUFFIX}
CONFIGURE_ARGS+= --with-soname=${RUBY_NAME}
CONFIGURE_ARGS+= --with-ruby-version=${RUBY_VER_DIR}
.endif
CONFIGURE_ARGS+= --with-ruby-pc="ruby-${RUBY_VERSION}.pc"

#
# Ruby 2.0 don't like Apple's builtin OpenSSL.
#
.if ${OPSYS} == "Darwin"
USE_BUILTIN.openssl=	no
.endif

#
# Win32 support (for Cygwin)
#
PLIST_VARS+=	win32
.if ${OPSYS} == "Cygwin"
PLIST.win32=	yes
.endif

#
# IRIX work around which should be fixed.
#
PLIST_VARS+=	io
.if ${OPSYS} != "IRIX"
PLIST.io=	yes
.endif

#
# Work around for getucontext(3)
#
.if ${OPSYS} == "DragonFly" && ${OS_VERSION} == "1.8.0"
CONFIGURE_ENV+=	ac_cv_header_ucontext_h=no
.endif

#
# prevent unwanted mkdir recorded in rbconfig.rb
#
CONFIGURE_ENV+=	MKDIR_P=${MKDIR:Q}

DOCS=		COPYING COPYING.ja ChangeLog NEWS README \
		README.EXT README.EXT.ja README.ja \
		doc/ChangeLog-1.8.0 doc/ChangeLog-1.9.3 doc/ChangeLog-YARV \
		doc/NEWS-1.8.7 doc/NEWS-1.9.1 doc/NEWS-1.9.2 doc/NEWS-1.9.3 \
		doc/etc.rd.ja doc/forwardable.rd.ja doc/globals.rdoc \
		doc/irb/irb-tools.rd.ja doc/irb/irb.rd.ja \
		doc/pty/README.expect.ja doc/pty/README.ja  doc/shell.rd.ja
EXT_DOCS=	syslog/syslog.txt

BIGDECIMAL_EXAMPLES=	linear.rb nlsolve.rb pi.rb
OPENSSL_EXAMPLES=	c_rehash.rb cert2text.rb certstore.rb cipher.rb \
			crlstore.rb echo_cli.rb echo_svr.rb gen_csr.rb \
			smime_read.rb smime_write.rb wget.rb

REPLACE_RUBY=		bin/erb bin/gem bin/irb bin/rake bin/rdoc \
			bin/ri bin/testrb
REPLACE_RUBY_DIRS=	ext lib sample
INSTALLATION_DIRS=	bin ${PKGMANDIR}/man1 \
			${RUBY_DOC}/irb ${RUBY_DOC}/pty ${RUBY_DOC}/ripper \
			${RUBY_DOC}/stringio \
			${RUBY_EG}/bigdecimal ${RUBY_EG}/pty
# ${RUBY_ARCHINC} ${RUBY_ARCHLIB}
EMPTY_DIRS=		generator/template markup/simple_markup

post-extract:
	${CP} ${FILESDIR}/AddTrustExternalCARoot-2048.pem \
		${WRKSRC}/lib/rubygems/ssl_certs

pre-configure:
	${RM} -f ${WRKSRC}/ext/gdbm/extconf.rb
	${RM} -f ${WRKSRC}/ext/fiddle/extconf.rb
	${RM} -f ${WRKSRC}/ext/readline/extconf.rb
	${RM} -f ${WRKSRC}/ext/tk/extconf.rb

pre-install:
	cd ${WRKSRC}/lib; \
		${FIND} . \( -name '*.orig' -o -name '*.orig_dist' \) \
		-exec ${RM} -f {} \;
.for f in ${EMPTY_DIRS}
	${RMDIR} ${WRKSRC}/lib/rdoc/${f} 2>/dev/null || ${TRUE}
.endfor

post-install:
.for f in ${DOCS}
	${INSTALL_DATA} ${WRKSRC}/${f} ${DESTDIR}${PREFIX}/${RUBY_DOC}/${f:C/^doc\///}
.endfor
.for f in ${EXT_DOCS}
	${INSTALL_DATA} ${WRKSRC}/ext/${f} ${DESTDIR}${PREFIX}/${RUBY_DOC}
.endfor
	cd ${WRKSRC}/ext/ripper; ${PAX} -rw README ${DESTDIR}${PREFIX}/${RUBY_DOC}/ripper
	cd ${WRKSRC}/ext/stringio; ${PAX} -rw README ${DESTDIR}${PREFIX}/${RUBY_DOC}/stringio
	cd ${WRKSRC}/sample; ${PAX} -rw . ${DESTDIR}${PREFIX}/${RUBY_EG}
.for f in ${BIGDECIMAL_EXAMPLES}
	${INSTALL_DATA} ${RUBY_WRKSRC}/ext/bigdecimal/sample/${f} \
		${DESTDIR}${PREFIX}/${RUBY_EG}/bigdecimal
.endfor
.for f in ${OPENSSL_EXAMPLES}
	${INSTALL_DATA} ${RUBY_WRKSRC}/sample/openssl/${f} \
		${DESTDIR}${PREFIX}/${RUBY_EG}/openssl
.endfor
	${RUBY_GENERATE_PLIST}

.include "../../mk/bdb.buildlink3.mk"
.include "../../converters/libiconv/buildlink3.mk"
.include "../../devel/zlib/buildlink3.mk"
.include "../../security/openssl/buildlink3.mk"
.include "../../textproc/libyaml/buildlink3.mk"
.include "../../ruby/ruby/Makefile.common"
.include "../../mk/bsd.pkg.mk"
