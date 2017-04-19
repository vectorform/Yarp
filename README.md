# Yarp





Simple example to get started with Yarp


Initilize Yarp Object
```swift
let yarp: Yarp? = Yarp(hostName: "www.google.com")
yarp?.start()
```

Set up a call back block

```swift
yarp?.addHandler("key1", handler: { (yarp) in
    if let reachable = yarp.isReachable {
        print("block yarp has reachable-ness \(reachable)")
    }
})
```
