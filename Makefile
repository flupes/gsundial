# root directory of the project
APP_ROOT:=$(CURDIR)

APP_NAME:=Sundial

# list of source files
SRC_FILES:=DayTime.mc SundialView.mc SundialApp.mc

# list of resources files
REZ_FILES:=strings/strings.xml drawables/drawables.xml

#layouts/layout.xml

# developer key option
KEY_OPT:=-y "C:\apps\Garmin\developer_key.der"

# manifest option
MANIFEST:=-m $(APP_ROOT)/manifest.xml

# build the resource options
REZ_OPTS:=$(REZ_FILES:%=-z $(APP_ROOT)/resources/%)

# build full path to source files
SOURCES:=$(SRC_FILES:%=$(APP_ROOT)/source/%)

TARGET:=$(APP_ROOT)/bin/$(APP_NAME).prg


$(TARGET): $(SOURCES)
	monkeyc -w -o $@ $(KEY_OPT) $(MANIFEST) $(REZ_OPTS) $(SOURCES)

all: $(TARGETS)

info:
		$(info APP_ROOT = $(APP_ROOT))
		$(info SRC_FILES = $(SRC_FILES))
		$(info SOURCES = $(SOURCES))
