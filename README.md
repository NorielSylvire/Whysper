# Whysper — Intelligent Whisper & Privacy Filter

Tired of gold sellers, random guild invites, and unsolicited messages cluttering your chat frames while you’re trying to focus on a mythic key, raid, or solo run?

Whysper is a lightweight, zero-bloat privacy addon built for WoW Midnight (12.0.7) that gives you complete control over who can slide into your DMs. Instead of a blunt "block everything" tool, Whysper handles communication via an intelligent Waterfall Priority Filter to ensure you never miss a message that actually matters.

---

## 🛡️ Core Features

Intelligent Priority Matrix: Whysper automatically evaluates incoming whisperers using a sequential, ordered hierarchy: Friends > Guildies > Raid Members > Party Members > Strangers.
Granular Control: Toggle communication from any of these 5 social groups completely independently. Want to hear from friends and literal strangers, but block players in your guild? Done.
Stealth Auto-Reply: Blocked users can optionally receive a clean, system-style notice: "You are currently being ignored by the user."
Built-in Loop Protection: Features smart internal message throttling to prevent dangerous infinite auto-reply loops if you encounter another player using a similar responder addon.
Modern Settings UI: Fully integrated into WoW’s native Options > AddOns canvas layout panel. No clunky, custom configuration frames anchoring to your screen.

## ⚙️ How the Priority Order Works

Because players often occupy multiple social circles, Whysper always grants the most favorable clearance possible based on your toggles:

Friends: If they are on your Battle.net or Character friends list, they bypass all other criteria.
Guildies: Evaluated if they share a guild with you but aren't explicitly on your friend list.
Raid/Party: Group members are temporarily elevated above stranger status so you can coordinate smoothly during pugs.
Strangers: The ultimate fallback catch-all layer.

## 💬 Slash Commands

/why stranger — Instantly toggles whispers from strangers on/off.
/why friend / /why guild / /why party / /why raid — Swiftly flips specific group access.
/why reply — Toggles the automated rejection notification message.
