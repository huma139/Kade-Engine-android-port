My attempt to port Kade Engine on Android. At first it was for one of my mod but since I tried too hard to figure it out how it all works (yes im dumb) and it works so im just gonna upload to github for archive.

i want this to be compatiple with both windows, html5 and android

Note that this is version 1.5.2 of KE, newer version got more wacky stuff so i cant figure it out yet

# Build instruction
[follow this lul](https://github.com/luckydog7/Funkin-android)

when compiling, you can do `lime test android` with your android phone through usb cable

you can do these below if you wanna make sure that your phone can do this

 - download [platform tool](https://developer.android.com/studio/releases/platform-tools)
 - extract it to anywhere u want
 - plug in ur android phone via usb
 - in the phone, enable USB Debug mode (probably in the develop options / developer mode in the setting depends on which phone u're using lol)
 - back to computer, open cmd in platform tools directory (or open cmd and type `cd "<platform-tools directory folder>"`)
 - run command `adb devices`
 - check if there's any phone that recognize (it will list the device code when it got recognize), if it does then you're good to go

or you can do `lime test android -emulator` to run it on emulator device. (you have to install a device on avd manager on android studio first)

# Credits
### Friday Night Funkin'
 - [ninjamuffin99](https://twitter.com/ninja_muffin99) - Programming
 - [PhantomArcade3K](https://twitter.com/phantomarcade3k) and [Evilsk8r](https://twitter.com/evilsk8r) - Art
 - [Kawai Sprite](https://twitter.com/kawaisprite) - Music

### Kade Engine
- [KadeDeveloper](https://twitter.com/KadeDeveloper)

### Most of the code for Android I yoinked from these guys's code (99% of it lol)
- [luckydog7](https://www.youtube.com/channel/UCeHXKGpDKo2eqYKVkqCUdaA) - Original Android code
- [KlavierGaming](https://www.youtube.com/channel/UCcaaRaMVhZulqORqfbr17zw) - Some Android code for Kade Engine
