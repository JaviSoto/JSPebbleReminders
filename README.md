### JSPebbleReminders
This is my first watchapp for the [Pebble](http://getpebble.com/) using the [AppMessages API](http://developer.getpebble.com/sdkref/group___app_message.html). It allows you to read the reminders in your main reminder list using your Pebble.

## Components
- [**iOS App**](https://github.com/JaviSoto/JSPebbleReminders/tree/master/JSPebbleReminders): Simple app with no UI. It waits for a message from pebble, and replies with a dictionary containing the titles of the reminders on your main reminder list.
- [**Pebble App**](https://github.com/JaviSoto/JSPebbleReminders/blob/master/pebble_reminders_app/src/pebble_reminders_app.c): It sends a message to the iOS app via App Messages, and when it gets a response, it creates a `SimpleMenuLayer` to display the reminders.

## Picture

<img src="http://farm9.staticflickr.com/8406/8761699744_ec1a90a840_n.jpg" />

## How to compile
- **iOS App:**
  - [Install pebble toolkit](http://developer.getpebble.com/1/01_GetStarted/01_Step_2).
  - Update the submodules:
  
  ```sh
$ git submodule update --init
```
  - Open the Xcode project (`JSPebbleReminders.xcodeproj`) and you should be able to install on your iOS device (assuming you have the certificates, etc set up)

- **Pebble App:**
  - Use the Xcode project under `pebble_reminders_app/xcode/`
  - Navigate to the `pebble_reminders_app` folder.
  - Run:
  
  ```sh
  $ ./waf configure
  ```

  - You should see this output:
  
  ```sh
  Setting top to                           : /Users/JaviSoto/Documents/Projects/Pebble/JSPebbleReminders/pebble_reminders_app
  Setting out to                           : /Users/JaviSoto/Documents/Projects/Pebble/JSPebbleReminders/pebble_reminders_app/build
  Checking for program gcc,cc              : arm-none-eabi-gcc
  Checking for program ar                  : arm-none-eabi-ar
  'configure' finished successfully (0.114s)
  ```

  - Simply build the Xcode project pressing cmd+B.
  - Run this command to create an HTTP server in the pebble folder:
  
  ```sh
  $ python -m SimpleHTTPServer 8000
  ```

  - Open `http://<your_local_ip>:8000` using Safari on your iPhone and navigate to the `build` folder.
  - Open the file `pebble_reminders_app.pbw` and install with the Pebble app.
  
  - Alternatively, you can download the .pbw file compiled using [CloudPebble](https://cloudpebble.net) from [here](http://small.cat/pie) (at your own risk, I haven't tested this)

## Known issues:
- Because of the limited buffer size on the pebble app, you might see a "buffer overflow" error on your watch if you have too many reminders.
