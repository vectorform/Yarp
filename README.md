[![Swift 3 Compatible](https://img.shields.io/badge/swift3-compatible-4BC51D.svg?style=flat)](https://developer.apple.com/swift)
[![Platform](https://img.shields.io/cocoapods/p/Yarp.svg?style=flat)](http://cocoadocs.org/docsets/Yarp)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Yarp.svg)](https://img.shields.io/cocoapods/v/Yarp.svg)


# Yarp
Created and maintained by Vectorform.

Yarp (Yet another reachability pod) is a reachability framework with a focus on reliability and simplicity. Yarp fully supports IPv6 and IPv4. Yarp allows you to observe changes in reachability using blocks or notifications.

# Initilize Yarp Object
Note: the IPv4 addresses in the below example can be switched out for their IPv6 counterparts.
```swift
//base init defaults to "0.0.0.0" which is Apple's special internet reachability address, Does NOT return an initial callback
let yarp: Yarp? = Yarp()

//Custom hostname init, DOES make an initial callback when first started
let yarp: Yarp? = Yarp(hostName: "www.google.com") //or "http://216.58.195.238" either will work

//Custom Address init, does NOT return an initial callback when started
let yarp: Yarp? = Yarp(hostAddress: "216.58.195.238")
yarp?.start()
```

# Listening Methods
### Handler Block
```swift
yarp?.addHandler("key1", handler: { (yarp) in
    if let reachable = yarp.isReachable {
        print("block yarp has reachable-ness: \(reachable)")
    }
})
```

### OR Notification Observer
you can listen for the notification sent from Yarp (if you have only one Yarp object you can safely set the object parameter to nil, but if you use more than one to monitor multiple hosts, then passing the object parameter into the addObserver function will make sure that you only get that objects reachability notifications)

```swift
//listen for ANY Yarp notification
NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: Yarp.StatusChangedNotification, object: nil)

// OR

//listen for a specific Yarp notification
NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: Yarp.StatusChangedNotification, object: yarpObject)
```

### Set Notification handlers

```swift
func reachabilityChanged(_ notification: Notification) {
        if let yarp = notification.object as? Yarp {
          //Note: isReachable will likely never be null here
            if let reachable = yarp.isReachable {
                defaultStatusLabel.text = "Default isReachable: \(reachable)"
            }
        }
    }
```

# Installation
### Cocoapods
Yarp can be added to your project using [CocoaPods](http://blog.cocoapods.org/Pod-Authors-Guide-to-CocoaPods-Frameworks/) by adding the following line to your `Podfile`:

```ruby
pod 'Yarp', '~> 0.1.0'
```
## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.


## Authors

Jeff Meador, jmeador@vectorform.com

Cory Bechtel, cbechtel@vectorform.com


## License

Yarp is available under the BSD license. See the [LICENSE](LICENSE) file for more info.
