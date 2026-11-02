# More details

**Mac only: macOS 12 or later, Apple silicon or Intel.** Speech is in English in this version.

## Privacy and behavior

This independent app reads public data using the official Hacker News API at https://hacker-news.firebaseio.com/v0/. It cannot post, vote, or sign in. No password, API key, or AI subscription is needed.

The username is stored in the app's local settings and sent to the official API when checking the account. The last successful reading is saved locally at `~/Library/Application Support/HN Accessible Reader/last-reading.txt`.

Each Command + 1 press fetches a fresh result. There is no background polling. A network failure is spoken; an old saved reading is never presented as current. Points include the post's starting point. Deleted and dead comments are skipped.

## Keyboard shortcut

Keep the app running. Command + 1 works globally; Escape stops speech and cancels a check. No Accessibility or Input Monitoring permission is required. If another app reserves the shortcut, use Read latest post from the HN Reader menu. Quit releases Command + 1. Escape is reserved only while checking or reading.

Open the app again after restarting your Mac. For automatic startup, add it under System Settings > General > Login Items.

## First opening

This community app is ad-hoc signed, not Apple-notarized. Review the source before using it. macOS may require explicit first-open approval in System Settings > Privacy & Security. Do not disable Gatekeeper or remove quarantine protections. You can build from source instead.

## Build from source

Install Apple's Xcode Command Line Tools, then run this in the project folder:

```sh
bash build.command
```

The app and ZIP appear in `dist/`. No developer tools are needed for the ready-made download.

Run the offline self-test and optional live API check:

```sh
"dist/HN Accessible Reader.app/Contents/MacOS/HNAccessibleReader" --self-test
"dist/HN Accessible Reader.app/Contents/MacOS/HNAccessibleReader" --check-api
```

The API check needs internet.

## License

MIT. See LICENSE. This is not an official Hacker News application.
