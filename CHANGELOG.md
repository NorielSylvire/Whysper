# Whysper changelog

## v1.5.2
- Fixed a critical bug where hooking TextToSpeechFrame_MessageEventHandler caused taint issues with WoW 12.0's new Secret Values system. This was causing raid/party chat messages to not appear for some users when in combat inside instances (dungeons/raids). The TTS blocking mechanism now uses a different approach that avoids tainting Blizzard's execution path.
- Improved github workflow to publish new versions automatically.
- Extended changelog is not visible in Wago and CurseForge.

## v1.5.1
- Fixed a bug where you would send an additional "You are being ignored" message every time you /reload.

## v1.5
- Added a realm blacklist.
- From v1.4: Added WIM compatibility.

## v1.3
- Added an option to hide your own automated ignored message.
- Fixed the bug where TTS would read blocked DMs aloud.

## v1.2
- Added an option to be able to customize the automated ignored message.
- Started working on a bug where TTS would still read blocked messages aloud.

## v1.1
- Added automated "You are being ignored." message.

## v1.0
- Initial version.
- Filter which social group can send you DMs (friends, guildies, raid members, party members, strangers).
