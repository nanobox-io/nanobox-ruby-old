# $NetBSD: gem-vars.mk,v 1.1 2015/03/08 14:41:12 taca Exp $
#
# This Makefile fragment defines various make(1) variables for Ruby gems
# support.
#
.if !defined(_RUBYGEM_VARS_MK)
_RUBYGEM_VARS_MK=	# defined

# Specify GEM_PATH
GEM_PATH?=	${PREFIX}/${GEM_HOME}

# Base directory for Gems
MAKE_ENV+=	GEM_PATH=${GEM_PATH}

RUBYGEM_LANG?=	en_US.UTF-8
RUBYGEM_ENV?=	LANG=${RUBYGEM_LANG} LC_CTYPE=${RUBYGEM_LANG}

FIND_PREFIX+=	RUBY_PREFIX=${RUBY_BASE}
.include "../../mk/find-prefix.mk"
RUBYGEM=	${RUBY_PREFIX}/bin/${RUBYGEM_NAME}

RUBY_GEMS_VERSION?=	${RUBY_GEMS_PKGSRC_VERS}

_RUBYGEMS_MAJOR=	${RUBY_GEMS_VERSION:C/\.[0-9\.]+$//}
_RUBYGEMS_MINORS=	${RUBY_GEMS_VERSION:C/^([0-9]+)\.*//}

.if ${RUBY_VER} == "18"
BUILD_DEPENDS+=	${RUBY_PKGPREFIX}-rubygems>=1.1.0:../../ruby/rubygems
DEPENDS+=	${RUBY_PKGPREFIX}-rubygems>=1.0.1:../../ruby/rubygems
.endif # !ruby18

.if ${_RUBYGEMS_MAJOR} >= 2 && ${_RUBYGEMS_MINORS} >= 2 && exists(${RUBYGEM})
GEM_EXTSDIR_NEEDS_SUBDIR?=	yes
RUBY_GEM_ARCH!=	${RUBYGEM} environment platform | ${SED} -e 's|.*:||'

.if !empty(GEM_EXTSDIR_NEEDS_SUBDIR:M[nB][oO])
GEM_EXTSDIR=	${GEM_HOME}/extensions/${RUBY_GEM_ARCH}/${RUBY_VER_DIR}
.else
GEM_EXTSDIR=	${GEM_HOME}/extensions/${RUBY_GEM_ARCH}/${RUBY_VER_DIR}/${GEM_NAME}
.endif

.endif

.if !empty(GEM_EXTSDIR)
PLIST_SUBST+=		GEM_EXTSDIR=${GEM_EXTSDIR}
.else
PLIST_SUBST+=		GEM_EXTSDIR="@comment "
.endif

.endif
