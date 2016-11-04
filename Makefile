# root directory of the project
APP_ROOT:=$(CURDIR)

APP_NAME:=Sundial

# list of source files
SRC_FILES:=Astro.mc DayTime.mc SundialView.mc SundialApp.mc

# list of resources files
REZ_FILES:=strings/strings.xml drawables/drawables.xml

#layouts/layout.xml

# developer key option
KEY_OPT:=-y "C:\apps\Garmin\developer_key.der"

# manifest option
MANIFEST:=-m $(APP_ROOT)/manifest.xml

# build the resource options
REZ_OPTS:=$(REZ_FILES:%=-z $(APP_ROOT)/resources/%)

# extra options
CC_OPTS:=--unit-test

# build full path to source files
SOURCES:=$(SRC_FILES:%=$(APP_ROOT)/source/%)

# Binary to be produced
TARGET:=$(APP_ROOT)/bin/$(APP_NAME).prg

# Type of watch to test (only for simulator run)
WATCH_TYPE:=fr230

# Where to install the program
INSTALL_DIR:=/g/GARMIN/APPS/

$(TARGET): $(SOURCES)
	monkeyc -w -o $@ $(KEY_OPT) $(CC_OPTS) $(MANIFEST) $(REZ_OPTS) $(SOURCES)

all: $(TARGET)

run: $(TARGET)
	monkeydo $(TARGET) fr230 -t

install: $(TARGET)
	@if [ -d $(INSTALL_DIR) ] ; then \
	  echo "Copy $(notdir $(TARGET)) to $(INSTALL_DIR)"; \
		cp -a $(TARGET) $(INSTALL_DIR); \
	else \
		echo "$(INSTALL_DIR) not present --> Cannot install $(notdir $(TARGET))!"; \
	fi

info:
	$(info APP_ROOT = $(APP_ROOT))
	$(info SRC_FILES = $(SRC_FILES))
	$(info SOURCES = $(SOURCES))
