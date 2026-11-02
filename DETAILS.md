# HN Accessible Reader

**Mac only — macOS 12 or later. Not for Windows, iPhone, Android, or Linux.**

A small talking shortcut for blind and low-vision Hacker News users.
Press **Command + 1** to hear your latest public post's title, points, comment count, and comments with replies. Press **Escape** to stop.

## Get started

1. Download **HN-Accessible-Reader-macOS.zip** from this repository's **Releases** page.
2. Unzip it. Move **HN Accessible Reader.app** to your Applications folder and open it.
3. Enter your **Hacker News username** and choose **Save username**. No password is needed.
4. Press **Command + 1** from any app to check your latest post.
5. Press **Escape** to stop reading or cancel a check.

Keep HN Accessible Reader running. Its menu-bar menu also has **Read latest post**, **Stop reading**, and **Quit**. Open the app again after restarting your Mac. To start it automatically, add it in System Settings → General → Login Items.

## What you need

- A Mac with macOS 12 or later, Apple silicon or Intel.
- Internet access and a public Hacker News username.
- Available system speech voices. Speech is in English in this version.

The ready-made app needs no developer tools. It uses standard macOS controls with accessibility labels. Command + 1 is reserved while the app runs. If another app already uses this global shortcut, quit that app or use **Read latest post** from the HN Reader menu.

## Important details

- This is an independent reader, not an official Hacker News app.
- It only reads public data through the [official Hacker News API](https://github.com/HackerNews/API). It cannot post, vote, or sign in.
- Points are the displayed score, including the post's starting point. They are not a count of unique voters.
- Each shortcut press fetches current data. No background polling or AI subscription is required. Deleted or dead posts are labelled when the API identifies them; deleted or dead comments are not spoken.
- The username stays in this app's local settings and is sent to the official API when checking the account. The last successful reading is saved on the Mac under `~/Library/Application Support/HN Accessible Reader/last-reading.txt`.
- Network failures are spoken. A previously saved reading is never announced as a fresh result.
- No Accessibility or Input Monitoring permission is required. Escape is reserved only while checking or reading.

## If macOS blocks the download

This community app is ad-hoc signed, not Apple-notarized. Review the source before using it. macOS may require an explicit first-open approval in System Settings → Privacy & Security. Do not disable Gatekeeper or remove quarantine protections. If you prefer, build the app yourself using the instructions below.

## Build from source

Developers need Apple's Xcode Command Line Tools. In Terminal, run:

```sh
./build.command
```

The app and ZIP appear in `dist/`. To run the checks:

```sh
"dist/HN Accessible Reader.app/Contents/MacOS/HNAccessibleReader" --self-test
"dist/HN Accessible Reader.app/Contents/MacOS/HNAccessibleReader" --check-api
```

The API check needs internet. The self-test does not.

## بالعربي — للماك فقط حالياً

1. نزّل ملف **HN-Accessible-Reader-macOS.zip** من قسم **Releases** وفك الضغط.
2. انقل التطبيق إلى **Applications** وافتحه.
3. اكتب اسم حسابك على Hacker News واضغط **Save username**. لا تحتاج كلمة سر.
4. اضغط **Command + 1** لسماع آخر منشور والنقاط والتعليقات. القراءة بالإنجليزية حالياً.
5. اضغط **Escape** لإيقاف القراءة. اترك التطبيق شغّال حتى يعمل الاختصار.

التطبيق مستقل، ومش تابع رسمياً لـHacker News. يعمل على أجهزة Mac فقط، وليس على Windows أو الهاتف.

## License

MIT. See [LICENSE](LICENSE).
