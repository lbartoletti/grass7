# Created by: reg
# $FreeBSD$

PORTNAME=	grass
PORTVERSION=	7.2.1
CATEGORIES=	databases geography
MASTER_SITES=	http://grass.osgeo.org/%SUBDIR%/ \
		http://grass.cict.fr/%SUBDIR%/ \
		http://grass.fbk.eu/%SUBDIR%/ \
		http://grass.gis-lab.info/%SUBDIR%/ \
		http://grass.meteo.uni.wroc.pl/%SUBDIR%/ \
		http://grass.polytechnic.edu.na/%SUBDIR%/ \
		http://grass.unibuc.ro/%SUBDIR%/ \
		http://mirrors.ibiblio.org/grass/%SUBDIR%/ \
		http://pinus.gntech.ac.kr/grass/%SUBDIR%/ \
		http://wgbis.ces.iisc.ernet.in/grass/%SUBDIR%/ \
		http://wgrass.media.osaka-cu.ac.jp/grassh/%SUBDIR%/
MASTER_SITE_SUBDIR=	grass72/source

MAINTAINER=	lbartoletti@tuxfamily.org
COMMENT=	Open source Geographical Information System (GIS)

LICENSE=	GPLv2+
LICENSE_FILE=	${WRKSRC}/GPL.TXT

BUILD_DEPENDS=	${PYTHON_PKGNAMEPREFIX}numpy>=1.2:math/py-numpy \
		${LOCALBASE}/bin/python:lang/python
RUN_DEPENDS=	${LOCALBASE}/bin/python:lang/python
LIB_DEPENDS=	libgdal.so:graphics/gdal \
		libpng.so:graphics/png \
		libproj.so:graphics/proj \
		libtiff.so:graphics/tiff \
		libfftw3.so:math/fftw3 \
		libfontconfig.so:x11-fonts/fontconfig \
		libfreetype.so:print/freetype2

USES=	fortran gettext gmake iconv jpeg pkgconfig python:2 \
		readline shebangfix
SHEBANG_FILES=	gui/*/*/*.py \
gui/scripts/*.py \
lib/init/grass.py \
tools/g.html2man/g.html2man.py \
scripts/*/*.py \
temporal/*/*.py

USE_XORG=	sm ice x11 xext xi xmu xrender xt
USE_GL=		gl glu
USE_GNOME=	cairo
USE_WX=		3.0
WX_COMPS=	wx:build python:run
USE_GCC=	yes
GNU_CONFIGURE=	yes
CONFIGURE_ARGS=	--with-includes=${LOCALBASE}/include \
		--with-libs=${LOCALBASE}/lib \
		--with-tcltk-includes="${TCL_INCLUDEDIR} ${TK_INCLUDEDIR}" \
		--with-opengl-includes=${LOCALBASE}/include/ \
		--with-opengl-libs=${LOCALBASE}/lib/ \
		--with-freetype \
		--with-freetype-includes=${LOCALBASE}/include/freetype2 \
		--with-blas \
		--with-lapack \
		--with-cairo \
		--with-nls \
		--with-cxx \
		--with-readline \
		--with-curses \
		--enable-largefile \
		--with-python=${PYTHON_CMD}-config \
		--with-wxwidgets=${WX_CONFIG} \
		--with-proj-share=${LOCALBASE}/share/proj
ALL_TARGET=default
USE_LDCONFIG=	${PREFIX}/${GRASS_INST_DIR}/lib
MAKE_JOBS_UNSAFE=yes
MAKE_ENV+=		TARGET="${CONFIGURE_TARGET}"

PLIST_SUB=	GRASS_INST_DIR="${GRASS_INST_DIR}" \
		VERSION="${PORTVERSION}" \
		VER="${PORTVERSION:R:C/\.//}"

#BROKEN_sparc64=		Does not configure on sparc64

OPTIONS_DEFINE=		ATLAS FFMPEG MOTIF
OPTIONS_MULTI=		DB
OPTIONS_MULTI_DB=	MYSQL ODBC PGSQL SQLITE
OPTIONS_DEFAULT=	SQLITE
OPTIONS_SUB=		yes

ATLAS_DESC=		Use ATLAS for BLAS and LAPACK
ATLAS_USES=		blaslapack:atlas
ATLAS_USES_OFF=		blaslapack
DB_DESC=		Database support
FFMPEG_LIB_DEPENDS=	libavcodec.so:multimedia/ffmpeg
FFMPEG_CONFIGURE_ON=	--with-ffmpeg \
			--with-ffmpeg-includes="${LOCALBASE}/include/libavcodec \
			 ${LOCALBASE}/include/libavformat \
			 ${LOCALBASE}/include/libavutil \
			 ${LOCALBASE}/include/libswscale" \
			--with-ffmpeglibs=${LOCALBASE}/lib
MOTIF_USES=		motif
MOTIF_USE=		GL=glw
MOTIF_CONFIGURE_ON=	--with-motif --with-glw
MYSQL_USE=		MYSQL=yes
MYSQL_CONFIGURE_ON=	--with-mysql \
			--with-mysql-includes=${LOCALBASE}/include/mysql \
			--with-mysql-libs=${LOCALBASE}/lib/mysql
ODBC_LIB_DEPENDS=	libodbc.so:databases/unixODBC
ODBC_CONFIGURE_ON=	--with-odbc
PGSQL_USES=		pgsql
PGSQL_CONFIGURE_ON=	--with-postgres
SQLITE_USES=		sqlite
SQLITE_CONFIGURE_ON=	--with-sqlite
SQLITE_RUN_DEPENDS=	${PYTHON_PKGNAMEPREFIX}sqlite3>0:databases/py-sqlite3

.include <bsd.port.options.mk>

.if !defined (GRASS_INST_DIR)
GRASS_INST_DIR=	${PORTNAME}-${PORTVERSION}
.endif

MANDIRS=	${PREFIX}/grass-7.2.0/docs/man/man1

post-extract:
	${MKDIR} ${WRKSRC}/etc
	${TOUCH} ${WRKSRC}/etc/fontcap

post-patch:
#	@${REINPLACE_CMD} -e \
#		's|= python|= ${PYTHON_CMD:T}|' ${WRKSRC}/include/Make/Platform.make.in
#	@${REINPLACE_CMD} -e \
#		"s|'make'|'gmake'|g" ${WRKSRC}/scripts/g.extension/g.extension.py
	@${REINPLACE_CMD} -e \
		's|$$(ARCH)|$$(TARGET)|g' ${WRKSRC}/include/Make/Grass.make

post-install:
#	@${MKDIR} ${STAGEDIR}${PREFIX}/${GRASS_INST_DIR}
	# Manual install
#	@${CP} -r ${WRKSRC}/dist.*/* ${STAGEDIR}${PREFIX}/${GRASS_INST_DIR}/

	@${RM} -rf ${STAGEDIR}${PREFIX}/${GRASS_INST_DIR}/demolocation/PERMANENT/.tmp/
#
	@${STRIP_CMD} ${STAGEDIR}${PREFIX}/${GRASS_INST_DIR}/bin/*
	@${STRIP_CMD} ${STAGEDIR}${PREFIX}/${GRASS_INST_DIR}/driver/db/*
.for i in clean_temp current_time_s_ms echo i.find lock run
	@${STRIP_CMD} ${STAGEDIR}${PREFIX}/${GRASS_INST_DIR}/etc/${i}
.endfor
	@${STRIP_CMD} ${STAGEDIR}${PREFIX}/${GRASS_INST_DIR}/etc/lister/*
	@${STRIP_CMD} ${STAGEDIR}${PREFIX}/${GRASS_INST_DIR}/lib/libgrass_*.so
	@${STRIP_CMD} ${STAGEDIR}${PREFIX}/${GRASS_INST_DIR}/tools/g.echo
#
#post-install-MOTIF-on:
#	@${STRIP_CMD} ${STAGEDIR}${PREFIX}/${GRASS_INST_DIR}/bin/xganim

.include <bsd.port.mk>
