# Reverse-Dynamic
.dylib built with UIKit to view process memory, function listing, file segment inspector &amp; more

# Features

- Real time memory exploration of the host app
- Process listing and metadata viewing
- Function listing and address inspection
- Memory mapping region with permissions and offsets
- Hex viewer for raw memory bytes
- Snapshots of memory state
- Draggable & floatable GUI
- Built in full Swift

# IPC

Internal IPC system which allows different modules of Reverse Dynamic to exchange data & memory and perform other actions safely within the app process.

> [!CAUTION]
> This tool is to be only used by developers or reverse engineers.

# .dylib injection

There are several ways to inject .dylib's into applications.

- **TrollFools:** This requires TrollStore to be installed. TrollFools can inject .dylib's into any installed application.
- **KSign:** You can inject .dylib's, .deb's & other frameworks into .ipa's.

And a lot of other ways I will not cover.

**NOTICE:** If you are not jailbroken or have TrollStore installed, **you cannot install this tweak into existing applications.** All apps you want to debug must come in the form of an ipa unless you are jailbroken or have TrollStore, of course.

# Building (Github Actions)

1. Fork this repo.
2. Tap Actions.
3. Tap on Run workflows.
4. Tap the first one and wait.

Building won't work because this tool is still in development.
