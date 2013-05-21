### JSPebbleReminders
This is my first watchapp for the [Pebble](http://getpebble.com/) using the [AppMessages API](http://developer.getpebble.com/sdkref/group___app_message.html).

### Components
- iOS App: Simple app with no UI. It waits for a message from pebble, and replies with a dictionary containing the titles of the reminders on your main reminder list.
- Pebble App: 

### Picture

<img src="http://farm9.staticflickr.com/8406/8761699744_ec1a90a840_n.jpg" />

### Known issues:
- Because of the limited buffer size on the pebble app, you might see a "buffer overflow" error on your watch if you have too many reminders.

### How to compile
- Install pebble toolkit: https://account.getpebble.com/sdk_releases
- cd folder
- ./waf configure