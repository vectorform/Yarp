[![Swift 4 Compatible](https://img.shields.io/badge/swift%204-compatible-4BC51D.svg?style=flat)](https://developer.apple.com/swift)
[![Platform](https://img.shields.io/cocoapods/p/Yarp.svg?style=flat)](http://cocoadocs.org/docsets/Yarp)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Yarp.svg)](https://img.shields.io/cocoapods/v/Yarp.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)


# Yarp
Created and maintained by Vectorform.

Yarp (Yet another reachability pod) is a reachability framework with a focus on reliability and simplicity. Yarp fully supports IPv6 and IPv4. Yarp allows you to observe changes in reachability using blocks or notifications.

# Requirements
- iOS 8.0+
- Xcode 9.0+
- Swift 4.0+

# Initilize Yarp Object
The IPv4 addresses in the below example can be switched out for their IPv6 counterparts.
In versions prior to Yarp 1.0.0, IP addresses would not perform an initial callback on init. In 1.0.0 they now return a callback.

```swift
//base init defaults to "0.0.0.0" which is Apple's special internet reachability address
let yarp: Yarp? = Yarp()

//Custom hostname init
let yarp: Yarp? = Yarp(hostName: "www.google.com") //or "http://216.58.195.238" either will work

//Custom Address init
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
You can listen for the notification sent from Yarp. If you have only one Yarp object you can safely set the object parameter to nil, but if you use more than one to monitor multiple hosts, then passing the object parameter into the addObserver function will make sure that you only get that objects reachability notifications.

```swift
//listen for ANY Yarp notification
NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged, name: Yarp.StatusChangedNotification, object: nil)

// OR

//listen for a specific Yarp notification
NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged, name: Yarp.StatusChangedNotification, object: yarpObject)
```

### Set Notification handlers

```swift
func reachabilityChanged(notification: Notification) {
        if let yarp = notification.object as? Yarp {
          //Note: isReachable will likely never be null here
            if let reachable = yarp.isReachable {
                defaultStatusLabel.text = "Default isReachable: \(reachable)"
            }
        }
    }
```

## Installation
### CocoaPods
[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:
```bash
$ gem install cocoapods
```

To integrate Yarp into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'Yarp', '~> 1.0.0'
end
```

Then, run the following command:

```bash
$ pod install
```

### Carthage
[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:
```bash
$ brew update
$ brew install carthage
```

To integrate Yarp into your Xcode project using Carthage, specify it in your `Cartfile`:
```ogdl
github "Vectorform/Yarp" ~> 1.0.0
```

Run `carthage update` to build the framework and drag the built `Yarp.framework` into your Xcode project.


### Manually
If you prefer not to use any of the listed dependency managers, you can integrate Yarp into your project manually.


## Authors

Jeff Meador, jmeador@vectorform.com

Cory Bechtel, cbechtel@vectorform.com


## License

Yarp is available under the BSD license. See the [LICENSE](LICENSE) file for more info.
