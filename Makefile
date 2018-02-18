include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ColorMeBaddge
ColorMeBaddge_FILES = Tweak.xm $(wildcard *.m)
ColorMeBaddge_CFLAGS += -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += colormebaddgeprefs

include $(THEOS_MAKE_PATH)/aggregate.mk
