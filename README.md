# ColorMeBaddge

Compatible with iOS 8.4 - 12.1.2

Sex up your badges with icon-based colors that feel so right it can't be wrong!

## App Badge Color

Colorize your app badges using a variety of colorization algorithms: Fixed Color, [ColorCube], [LEColorPicker], [Boover], [ColorBadges] (if installed), [Chameleon], or Random Colors

You can adjust the generated badge color before it is used. This can be handy if, for instance, you don't like that some badges blend in with their icon. Applying one of the adjustment options will help the badge stand out from the icon.

## App Badge Text Color

Set a custom color, use a color provided by the chosen colorization algorithm, or let it be chosen black or white based on badge color brightness (see Brightness Settings below).

You can adjust the generated text color before it is used. This can be handy if, for instance, you inverted the badge color, and want to invert the text color as well to maintain contrast.

## Folder Badge Color

Give your folder badges a fixed color, the color of one of its contained badges (lowest / highest / first / last / random badge), an average color of all contained badges (normal or weighted), or simply use random colors. You can even have the color chosen from the folder icon minigrid as if it were an app icon, according to your app badge color preferences.

## Folder Badge Text Color

Set a custom color, use the color of the contained badge (if applicable), or let it be chosen black or white based on badge color brightness (see Brightness Settings below).

## Special Badges

Some badges are not numeric and act more as alerts, such as the Messages delivery failure "!" badge. If desired, you can assign custom colors for these badges so that they stand out.

## Shape Settings

You can grow or shrink your badges to reasonable sizes, and adjust the roundness of the badge corners.

## Border Settings

You can choose to have borders on your badges, and color them using a fixed color, the color of the badge text, a shaded or tinted version of the badge color, or let it be chosen black or white based on badge color brightness (see Brightness Settings below).

Additionally, you can choose your preferred border width from a modest selection of values.

## Brightness Settings

For badge text colors chosen by brightness, you can choose the color space used for brightness calculations (RGB or CIELAB), and the brightness threshold above which black text is chosen over white text.

If you prefer to always have white or black text, you can choose to have badge colors darkened or lightened just past your chosen brightness threshold (if necessary), so that your desired text color is chosen.

## Miscellaneous Settings

You can choose to use unmasked app icons, so that app badge color algorithms can access pixels that are normally not visible on the screen due to icon masking. This may affect the chosen color for some icons when using certain algorithms.

If you're enjoying the splashes of color want to see as many badges as possible, you can choose to allow all app icons to display their badges, even if disabled in Notifications.

If you miss the ability to see badges in the app switcher that was present in earlier versions of iOS, you can now choose to have badges shown on the icons in the app switcher (iOS 9/10).

If you use ColorBanners, you can choose to have it colorize banners according to your app badge background settings, instead of using its built-in algorithm. This feature requires either [ColorBanners] or [ColorBanners 2] to be installed.

If you have badges that contain emojis, they will be left alone by default.  You can opt to colorize them with the badge text color, effectively creating an emoji silhouette.

## KNOWN ISSUES

The third-party color picker used in this tweak doesn't work well in landscape mode. To work around this, please pick colors in portrait mode.

Configure options from Settings.

## Screenshots

Algorithm colorization examples:

| ColorCube | LEColorPicker | LEColorPicker (text + borders) |
| --- | --- | --- |
| <img width="250" heigth="283" alt="ColorCube example" src="../assets/screenshots/ColorCube.png"> | <img width="250" heigth="283" alt="LEColorPicker example" src="../assets/screenshots/LEColorPicker.png"> | <img width="250" heigth="283" alt="LEColorPicker with foreground colors and borders example" src="../assets/screenshots/LEColorPicker+foreground+borders.png"> |

| Boover | ColorBadges | Chameleon |
| --- | --- | --- |
| <img width="250" heigth="283" alt="Boover example" src="../assets/screenshots/Boover.png"> | <img width="250" heigth="283" alt="ColorBadges example" src="../assets/screenshots/ColorBadges.png"> | <img width="250" heigth="283" alt="Chameleon example" src="../assets/screenshots/Chameleon.png"> |

Preferences:

| Main | App Badges | Folder Badges |
| --- | --- | --- |
| <img width="250" heigth="445" alt="Main Preferences" src="../assets/screenshots/Preferences-0-main.png"> | <img width="250" heigth="445" alt="App Badge Preferences" src="../assets/screenshots/Preferences-1-apps.png"> | <img width="250" heigth="445" alt="Folder Badge Preferences" src="../assets/screenshots/Preferences-2-folders.png"> |

| Special Badges | Border Settings |
| --- | --- |
| <img width="250" heigth="445" alt="Special Badge Preferences" src="../assets/screenshots/Preferences-3-special.png"> | <img width="250" heigth="445" alt="Border Preferences" src="../assets/screenshots/Preferences-4-borders.png"> |

[ColorCube]: https://github.com/pixelogik/ColorCube
[LEColorPicker]: https://github.com/luisespinoza/LEColorPicker
[Boover]: http://cydia.saurik.com/package/com.jontelang.boover/
[ColorBadges]: http://cydia.saurik.com/package/org.thebigboss.colorbadges/
[Chameleon]: https://github.com/ViccAlexander/Chameleon
[ColorBanners]: http://cydia.saurik.com/package/com.golddavid.colorbanners/
[ColorBanners 2]: http://cydia.saurik.com/package/com.golddavid.colorbanners2/
