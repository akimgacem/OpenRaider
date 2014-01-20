###############################################################
# Mongoose <stu7440@westga.edu>
###############################################################
# + Cleaner clean
# + Add new include tree
# + Add new flags
# + Install/Uninstall
# + Debian and Redhat packaging
# + Lots of misc new features
###############################################################
BUILD_SELECT=debug

NAME=OpenRaider
NAME_TAR=openraider
MAJOR_VERSION=0
MINOR_VERSION=1
MICRO_VERSION=2
BUILD_ID=$(shell date "+%Y%m%d")
PRE=
VERSION=$(MAJOR_VERSION).$(MINOR_VERSION).$(MICRO_VERSION)$(PRE)
VERSION_DEB=$(MAJOR_VERSION).$(MINOR_VERSION).$(MICRO_VERSION).$(BUILD_ID)
BUILD_HOST=$(shell uname -s -n -r -m)
ARCH=$(shell uname -m -s | sed -e "s/ /-/g")
UNAME=$(shell uname -s)

###############################################################

# -DMULTITEXTURE			Add OpenGL multitexturing
# -DUNICODE_SUPPORT			Add unicode/internation keyboard support
# -DUSING_EMITTER_IN_GAME	Run particle test in game

BASE_DEFS=$(shell sdl-config --cflags) -Iinclude -DSDL_INTERFACE \
	-DUSING_OPENGL -DZLIB_SUPPORT -DUSING_EMITTER \
	-DUSING_OPENAL -DUSING_TGA -DUSING_PTHREADS \

BASE_LIBS=$(shell sdl-config --libs) -lz -lstdc++ \
	-lpthread -lSDL_ttf

# -DDEBUG_GL
DEBUG_DEFS=-DDEBUG -DEXPERIMENTAL
DEBUG_OBJ=

ifeq ($(UNAME),Darwin)
AUDIO_LIBS += -lalut
AUDIO_LIBS += -framework OpenAL
AUDIO_LIBS += -L/usr/local/lib
AUDIO_DEFS += -I/usr/local/include
GL_LIBS += -framework OpenGL
GL_LIBS += -L/opt/local/lib
GL_DEFS += -I/opt/local/include
else
AUDIO_LIBS += -lopenal
GL_LIBS += -lGL -lGLU
GL_LIBS += -L/usr/local/lib
GL_DEFS += -I/usr/local/include
endif

BASE_LIBS += $(AUDIO_LIBS)
BASE_LIBS += $(GL_LIBS)
BASE_DEFS += $(AUDIO_DEFS)
BASE_DEFS += $(GL_DEFS)

# libferit, File transfer via HTTP/FTP/etc support
LIBFERIT_LIB=/usr/local/lib/libferit.so
LIBFERIT=$(shell if test -e $(LIBFERIT_LIB) > /dev/null; then echo yes; fi)

ifeq ($(LIBFERIT), yes)
	BASE_DEFS += -DHAVE_LIBFERIT
	BASE_LIBS += -lferit
endif

###############################################################

TREE_DIR=OpenRaider
BUILD_DEBUG_DIR=bin/debug
BUILD_RELEASE_DIR=bin/release
BUILD_PROF_DIR=bin/prof
BUILD_TEST_DIR=bin/test
BUILD_MEM_DIR=bin/mem
BUILD_INSTALL_DIR=bin/$(BUILD_SELECT)
DEB_DIR=/tmp/$(NAME).deb

# Edited for Debian GNU/Linux.
DESTDIR =
INSTALL_BIN=$(DESTDIR)/usr/games
INSTALL_LIB=$(DESTDIR)/usr/lib
INSTALL_DOC=$(DESTDIR)/usr/share/doc/$(NAME)
INSTALL_SHARE=$(DESTDIR)/usr/share/$(NAME)
INSTALL_INCLUDE=$(DESTDIR)/usr/include

###############################################################
CC=gcc
WARNINGS=-Weverything -Wno-padded -Wno-packed -Wno-documentation
WARNINGS+=-Wno-documentation-unknown-command -Wno-format-nonliteral
WARNINGS+=-Wno-covered-switch-default -Wno-global-constructors
WARNINGS+=-Wno-exit-time-destructors -Wno-c++98-compat-pedantic
WARNINGS+=-Wno-disabled-macro-expansion -Wno-missing-variable-declarations
WARNINGS+=-Wno-missing-prototypes

WARNINGS+=-Wno-conversion -Wno-sign-conversion -Wno-shorten-64-to-32

FLAGS_ALL=-std=c++11

BASE_CFLAGS=$(FLAGS_ALL) $(BASE_DEFS) \
	-DVERSION=\"\\\"$(NAME)-$(VERSION)-$(BUILD_ID)\\\"\" \
	-DBUILD_HOST=\"\\\"$(BUILD_HOST)\\\"\"

LD_FLAGS=-L/usr/X11/lib -lXmu -lXt -lSM -lICE -lXext -lX11 -lXi \
	 -lm $(BASE_LIBS)

RELEASE_CFLAGS=$(BASE_CFLAGS) -ffast-math -funroll-loops \
	-fomit-frame-pointer -O2 -Wall

DEBUG_CFLAGS=$(BASE_CFLAGS) -g -O0 $(DEBUG_DEFS) $(WARNINGS)

################################################################

DO_CC=$(CC) $(CFLAGS) -o $@ -c $<
DO_SHLIB_CC=$(CC) $(CFLAGS) $(SHLIBCFLAGS) -o $@ -c $<

TARGETS=$(BUILDDIR)/$(NAME)

################################################################
auto: $(BUILD_SELECT)

run: $(BUILD_SELECT)
	bin/$(BUILD_SELECT)/OpenRaider

targets: $(TARGETS)

bundle: release
	mac_dist/bundle.sh
	mac_dist/plist.sh $(NAME) $(VERSION) $(BUILD_ID) > bin/OpenRaider.app/Contents/Info.plist
	mac_dist/frameworks.sh

bundle-image: bundle
	mac_dist/image.sh

bundle-archive: bundle
	mac_dist/archive.sh

all: debug release prof

debug:
	@-mkdir -p $(BUILD_DEBUG_DIR)
	$(MAKE) targets BUILDDIR=$(BUILD_DEBUG_DIR) \
	CFLAGS="$(DEBUG_CFLAGS)" \
	LD_FLAGS="$(LD_FLAGS)"

prof:
	@-mkdir -p $(BUILD_PROF_DIR)
	$(MAKE) targets BUILDDIR=$(BUILD_PROF_DIR) \
	CFLAGS="$(DEBUG_CFLAGS) -pg" \
	LD_FLAGS="$(LD_FLAGS) -pg"

release:
	@-mkdir -p $(BUILD_RELEASE_DIR)
	$(MAKE) targets BUILDDIR=$(BUILD_RELEASE_DIR) \
	CFLAGS="$(RELEASE_CFLAGS)" \
	LD_FLAGS="$(LD_FLAGS)"

#####################################

ded:
	@-mkdir -p $(BUILD_DEBUG_DIR)/ded
	$(MAKE) targets BUILDDIR=$(BUILD_DEBUG_DIR)/ded \
	CFLAGS="$(DEBUG_CFLAGS) -DDEDICATED_SERVER" \
	LD_FLAGS="$(LD_FLAGS)"

# -DDEBUG_MEMORY_VERBOSE
# -DDEBUG_MEMORY
memory:
	@-mkdir -p $(BUILD_MEM_DIR)
	$(MAKE) targets BUILDDIR=$(BUILD_MEM_DIR) \
	DEBUG_OBJ="$(BUILD_MEM_DIR)/memory_test.o" \
	CFLAGS="$(DEBUG_CFLAGS) -DDEBUG_MEMORY" \
	LD_FLAGS="$(LD_FLAGS)"

depend:
	@-echo "Making deps..."
	@-echo "# Autogenerated dependency file" > depend
	@-find ./src -name "*.cpp" -exec ./deps.sh $(BASE_DEFS) {} \; >> depend
	@-echo "[DONE]"

################################################################

OBJS = \
	$(DEBUG_OBJ) \
	$(BUILDDIR)/Camera.o \
	$(BUILDDIR)/Emitter.o \
	$(BUILDDIR)/GLString.o \
	$(BUILDDIR)/MatMath.o \
	$(BUILDDIR)/Matrix.o \
	$(BUILDDIR)/Network.o \
	$(BUILDDIR)/OpenGLMesh.o \
	$(BUILDDIR)/OpenRaider.o \
	$(BUILDDIR)/Particle.o \
	$(BUILDDIR)/Quaternion.o \
	$(BUILDDIR)/Render.o \
	$(BUILDDIR)/SDLSystem.o \
	$(BUILDDIR)/SkeletalModel.o \
	$(BUILDDIR)/Sound.o \
	$(BUILDDIR)/System.o \
	$(BUILDDIR)/Texture.o \
	$(BUILDDIR)/TGA.o \
	$(BUILDDIR)/TombRaider.o \
	$(BUILDDIR)/Vector3d.o \
	$(BUILDDIR)/ViewVolume.o \
	$(BUILDDIR)/World.o


$(BUILDDIR)/$(NAME) : $(OBJS)
	$(CC) $(CFLAGS) $(LD_FLAGS) -o $@ $(OBJS)

#################################################################

clean: clean-small clean-dep clean-doc

clean-small: clean-build clean-test clean-obj 
	@-rm -rf bin/OpenRaider.app
	@-rm -rf bin/OpenRaider.dmg
	@-rm -rf bin/OpenRaider.zip

clean-dep:
	@-echo "Cleaning dependencies"
	@-rm -f depend
	@-echo "[DONE]"

clean-test:
	@-echo "Cleaning test builds"
	@-rm -f $(BUILD_TEST_DIR)/*.o
	@-rm -rf $(BUILD_TEST_DIR)/*.dSYM
	@-rm -f $(BUILD_TEST_DIR)/*.test
	@-rm -rf $(BUILD_TEST_DIR)/*.build
	@-echo "[DONE]"

clean-obj:
	@-echo "Cleaning objects"
	@-rm -f $(BUILD_PROF_DIR)/*.o
	@-rm -f $(BUILD_DEBUG_DIR)/*.o
	@-rm -f $(BUILD_RELEASE_DIR)/*.o
	@-rm -f $(BUILD_TEST_DIR)/*.o
	@-rm -f $(BUILD_MEM_DIR)/*.o
	@-echo "[DONE]"

clean-build:
	@-echo "Cleaning builds"
	@-rm -f $(BUILD_PROF_DIR)/$(NAME)
	@-rm -f $(BUILD_DEBUG_DIR)/$(NAME)
	@-rm -f $(BUILD_RELEASE_DIR)/$(NAME)
	@-rm -f $(BUILD_MEM_DIR)/$(NAME)
	@-echo "[DONE]"

clean-doc:
	@-echo "Cleaning docs"
	@-rm -rf doc
	@-echo "[DONE]"


#################################################################

-include depend

#################################################################

ifneq ($(UNAME),Darwin)

install:
	mkdir -p $(INSTALL_SHARE)/data
	cp setup.sh $(INSTALL_SHARE)
	cp data/* $(INSTALL_SHARE)/data
	mkdir -p $(INSTALL_DOC)
	cp README.md README.old ChangeLog
	mkdir -p $(INSTALL_BIN)
	cp bin/$(BUILD_SELECT)/OpenRaider $(INSTALL_BIN)

bin-tarball: clean-build clean-test clean-obj $(BUILD_SELECT)
	@-cd .. && tar zcvf $(NAME_TAR)-$(VERSION_DEB)-$(ARCH).tar.gz \
		$(TREE_DIR)/Makefile $(TREE_DIR)/data \
		$(TREE_DIR)/bin/$(BUILD_SELECT)/OpenRaider \
		$(TREE_DIR)/README.md $(TREE_DIR)/ChangeLog

endif

#################################################################
# Unit Test builds
#################################################################
TEST_FLAGS=$(FLAGS_ALL) -g -O0 -DDEBUG -lstdc++ -Iinclude

TEST_MAP_TR5=~/.OpenRaider/paks/tr5/demo.trc
TEST_MAP_TR4=~/.OpenRaider/paks/tr4/angkor1.tr4
TEST_MAP_TR3=~/.OpenRaider/paks/tr3/scotland.tr2
TEST_MAP_TR2=~/.OpenRaider/paks/tr2/unwater.tr2
TEST_MAP_TR1=~/.OpenRaider/paks/tr1/level1.phd

test.build: Matrix.test Math.test Memory.test Network.test Sound.test TGA.test GLString.test TombRaider.test

test: test.build
	@-echo "================================================="
	@-echo "Running Memory unit test"
	$(BUILD_TEST_DIR)/memory_test.test
	@-echo "================================================="
	@-echo "Running Matrix unit test"
	$(BUILD_TEST_DIR)/Matrix.test
	@-echo "================================================="
	@-echo "Running Math unit test"
	$(BUILD_TEST_DIR)/Math.test
	@-echo "================================================="
	@-echo "Running Sound unit test"
	$(BUILD_TEST_DIR)/Sound.test
	@-echo "================================================="
	@-echo "Running TGA unit test"
	$(BUILD_TEST_DIR)/TGA.test
	@-echo "================================================="
	@-echo "Running GLString unit test"
	$(BUILD_TEST_DIR)/GLString.test
	@-echo "================================================="
	@-echo "Running TombRaider unit test"
	$(BUILD_TEST_DIR)/TombRaider.test load $(TEST_MAP_TR1)

TombRaider.reg_test:
	$(MAKE) TombRaider.test
	$(BUILD_TEST_DIR)/TombRaider.test load $(TEST_MAP_TR1) > /tmp/log.tr1
	$(BUILD_TEST_DIR)/TombRaider.test load $(TEST_MAP_TR2) > /tmp/log.tr2
	$(BUILD_TEST_DIR)/TombRaider.test load $(TEST_MAP_TR3) > /tmp/log.tr3
	$(BUILD_TEST_DIR)/TombRaider.test load $(TEST_MAP_TR4) > /tmp/log.tr4
	$(BUILD_TEST_DIR)/TombRaider.test load $(TEST_MAP_TR5) > /tmp/log.tr5

TR_FLAGS = -D__TEST_TR5_DUMP_TGA -D__TEST_32BIT_TEXTILES -DDEBUG_MEMORY

TombRaider.test:
	@-mkdir -p $(BUILD_TEST_DIR)
	$(CC) $(FLAGS_ALL) $(WARNINGS) -Iinclude $(TR_FLAGS) -o $(BUILD_TEST_DIR)/TombRaiderTest.o -c test/TombRaider.cpp
	$(MAKE) targets NAME=TombRaider.test BUILDDIR=$(BUILD_TEST_DIR) \
	OBJS="$(BUILD_TEST_DIR)/TombRaiderTest.o $(BUILD_TEST_DIR)/TombRaider.o $(BUILD_TEST_DIR)/TGA.o $(BUILD_TEST_DIR)/memory_test.o" \
	CFLAGS="$(BASE_CFLAGS) -g $(TR_FLAGS)" \
	LD_FLAGS="-lz -lstdc++"

#################################################################

GLString.test:
	mkdir -p $(BUILD_TEST_DIR)
	$(CC) $(FLAGS_ALL) $(WARNINGS) -Iinclude \
	$(shell sdl-config --cflags) $(shell sdl-config --libs) \
	$(GL_LIBS) $(GL_DEFS) -lSDL_ttf -lm -lstdc++ \
	src/Texture.cpp src/GLString.cpp \
	test/GLString.cpp -o $(BUILD_TEST_DIR)/GLString.test

#################################################################

Matrix.test:
	@-echo "Building Matrix unit test"
	mkdir -p $(BUILD_TEST_DIR)
	$(CC) $(FLAGS_ALL) $(WARNINGS) -g -lm -lstdc++ -Iinclude \
	src/Matrix.cpp src/Quaternion.cpp src/Vector3d.cpp \
	test/Matrix.cpp -o $(BUILD_TEST_DIR)/Matrix.test

Math.test:
	@-echo "Building Math unit test"
	mkdir -p $(BUILD_TEST_DIR)
	$(CC) $(FLAGS_ALL) $(WARNINGS) -g -lm -lstdc++ -Iinclude \
	src/MatMath.cpp src/Vector3d.cpp test/MatMath.cpp -o $(BUILD_TEST_DIR)/Math.test

#################################################################

Memory.test:
	mkdir -p $(BUILD_TEST_DIR)
	$(CC) $(FLAGS_ALL) $(WARNINGS) -g -lstdc++ -Iinclude \
	-DDEBUG_MEMORY -DDEBUG_MEMORY_ERROR \
	src/memory_test.cpp test/memory_test.cpp -o $(BUILD_TEST_DIR)/memory_test.test

#################################################################

Network.test:
	mkdir -p $(BUILD_TEST_DIR)
	$(CC) $(TEST_FLAGS) $(WARNINGS) \
	src/Network.cpp test/Network.cpp -o $(BUILD_TEST_DIR)/Network.test

#################################################################

Sound.test:
	mkdir -p $(BUILD_TEST_DIR)
	$(CC) $(TEST_FLAGS) $(WARNINGS) \
		-DUSING_OPENAL $(AUDIO_LIBS) $(AUDIO_DEFS) \
		src/Sound.cpp test/Sound.cpp -o $(BUILD_TEST_DIR)/Sound.test

#################################################################

TGA.test:
	mkdir -p $(BUILD_TEST_DIR)
	$(CC) $(TEST_FLAGS) $(WARNINGS) \
		src/TGA.cpp test/TGA.cpp -o $(BUILD_TEST_DIR)/TGA.test

#################################################################

