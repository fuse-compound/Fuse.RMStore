# Fuse.RMStore

A wrapper for the frankly delightful RMStore library

To build the example:
- make sure you have followed the official guides thoroughly when setting up your test users, purchases, App ID, etc
- run `uno build -t=ios -DCOCOAPODS -d`
- Wait. The first build has the pull in and compile the dependencies from CocoaPods, this can take 15mins in some cases. Don't worry, this is only for the first build.
- In the 'App Capabilities' turn on 'In App Purchases' (this will be done automatically in future)
