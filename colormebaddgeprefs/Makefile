include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ColorMeBaddgePrefs
ColorMeBaddgePrefs_FILES = $(wildcard *.m)
ColorMeBaddgePrefs_INSTALL_PATH = /Library/PreferenceBundles
ColorMeBaddgePrefs_FRAMEWORKS = UIKit
ColorMeBaddgePrefs_PRIVATE_FRAMEWORKS = Preferences
ColorMeBaddgePrefs_CFLAGS += -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ColorMeBaddgePrefs.plist$(ECHO_END)
