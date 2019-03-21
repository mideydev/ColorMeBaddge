include $(THEOS)/makefiles/common.mk

PREFS_PATH = colormebaddgeprefs

TWEAK_NAME = ColorMeBaddge
$(TWEAK_NAME)_FILES = $(wildcard *.xm *.m external/*/*.m) $(PREFS_PATH)/external/HRColorPicker/UIColor+HRColorPickerHexColor.m
$(TWEAK_NAME)_CFLAGS += -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += $(PREFS_PATH)

include $(THEOS_MAKE_PATH)/aggregate.mk
