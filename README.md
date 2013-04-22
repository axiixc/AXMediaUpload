# AXMediaUpload

Support easy image and video uploads within your app.

**NOT READY FOR PRIMETIME JUST YET**

I'm currently working to pull out some useful components from scraped app ideas I've had. As such this still is a bit of a WIP, and will take some TLC to remove any extraneous dependencies it one had on other code.

The code requires AFNetworking, which I'd recommend you install via CocoaPods (which is what I'm doing locally). I plan to package this up a bit nicer one I stop editing it so heavily.

# Want to run it anyways?

Currently only a [Cloud App](http://getcloudapp.com) account is supported. To use yours just go edit `-[AXAppDemoViewController uploadController:credentialsForServiceClass:]` to return your username and password (and then be sure to not commit it back to Github or anything), and you should be good to go.
