// Copyright (c) 2016 Vectorform LLC
// http://www.vectorform.com/
// http://github.com/vectorform/Yarp
//
//  Yarp
//  Yarp.swift
//


import Foundation
import SystemConfiguration

// Callback function that receives change events of network connectivity
private func reachabilityCallback(_ reachability: SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) {
    
    // This function is called on a background thread so we'll need to move to the main thread.
    DispatchQueue.main.async {
        
        // Our instance of Yarp is passed through the info parameter. If it doesn't exist there's nothing we can do.
        guard let info = info else {
            return
        }
        
        // Extract the yarp instance from the info paramater and set the flags so they can be checked during the handler block
        let yarp = Unmanaged<Yarp>.fromOpaque(info).takeUnretainedValue()
        yarp.reachabilityFlags = flags
        
        yarp.notifyListenerOfChange()
    }
}

open class Yarp {
    
    // Notifications are sent out on reachability changes with this name.
    public static let StatusChangedNotification = NSNotification.Name("com.vectorform.yarp.statusChangedNotification")
    
    //if nil, means there has been no change in the status of your reachability
    public var isReachable : Bool? {
        if let flags = reachabilityFlags {
            return flags.contains(.reachable)
        }
        return nil
    }
    
    // In addition to notifications, closures can be used to observe changes.
    public typealias Handler = (Yarp) -> ()
    
    // Yarp will hold a dictionary of Handlers indexed by a token's key(string).
    fileprivate var handlers = [String : Handler]()
    
    fileprivate var reachability: SCNetworkReachability
    
    fileprivate var reachabilitySerialQueue: DispatchQueue?
    
    fileprivate let isUsingIPAddress: Bool
    
    //gets set once the reachability status changes for a given yarp object
    public var reachabilityFlags: SCNetworkReachabilityFlags?
    
    // Default init simply tests if there's an internet connection at all NOTE: does NOT shoot off an event upon starting
    public init?() {
        
        self.isUsingIPAddress = true
        
        // Reachability treats 0.0.0.0 as a special token to monitor general routing status for IPv4 and IPv6 (information gathered from Apple's reachability)
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let reachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return nil
        }
        
        self.reachability = reachability
    }
    
    //initialize with a custom hostname NOTE: DOES shoot off an event upon starting if you use a name (www.google.com), but does not if given the IP address ("http://216.58.195.238")
    public init?(hostName: String) {
        
        self.isUsingIPAddress = false
        
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, hostName) else {
            return nil
        }
        
        self.reachability = reachability
    }
    
    //initialize with a custom reachability address (ie. "216.58.195.238" or similar)
    public init?(hostAddress: String) {
        
        self.isUsingIPAddress = true
        
        var remoteAddress = sockaddr_in()
        var remoteIPv6Address = sockaddr_in6()
        
        if hostAddress.withCString({ cstring in inet_pton(AF_INET6, cstring, &remoteIPv6Address) }) == 1 {
             // IPv6
            
            remoteIPv6Address.sin6_len = UInt8(MemoryLayout.size(ofValue: remoteIPv6Address))
            remoteIPv6Address.sin6_family = sa_family_t(AF_INET6)
            
            guard let reachability = withUnsafePointer(to: &remoteIPv6Address, {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    SCNetworkReachabilityCreateWithAddress(nil, $0)
                }
            }) else {
                return nil
            }
        
            self.reachability = reachability
            
        } else if hostAddress.withCString({ cstring in inet_pton(AF_INET, cstring, &remoteAddress.sin_addr) }) == 1 {
            // IPv4
            
            remoteAddress.sin_len = UInt8(MemoryLayout.size(ofValue: remoteAddress))
            remoteAddress.sin_family = sa_family_t(AF_INET)
            
            guard let reachability = withUnsafePointer(to: &remoteAddress, {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    SCNetworkReachabilityCreateWithAddress(nil, $0)
                }
            }) else {
                return nil
            }
            
            self.reachability = reachability
        } else {
            return nil
        }
    }
    
    fileprivate func notifyListenerOfChange(){
        // Send out a notification
        NotificationCenter.default.post(name: Yarp.StatusChangedNotification, object: self)
        
        // Call any handlers.
        for (_, handler) in self.handlers {
            handler(self)
        }
    }
    
    // must call this in order to start listening for default reachability changes.  Can be called multiple times
    public func start() {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        
        // If we already have the queue setup to process reachability events then we are done
        if self.reachabilitySerialQueue != nil {
            return
        }
        
        let dispatchQueue = DispatchQueue(label: "com.vectorform.yarp.reachabilitySerialQueue", attributes: [])
        
        if !SCNetworkReachabilitySetDispatchQueue(self.reachability, dispatchQueue) {
            debugPrint( "Yarp: Unable to get default reachability route" )
            return
        }
        
        var context = SCNetworkReachabilityContext( version: 0, info: nil, retain: nil, release: nil, copyDescription: nil )
        context.info = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        if !SCNetworkReachabilitySetCallback(self.reachability, reachabilityCallback, &context) {
            debugPrint( "Yarp: Unable to setup reachability callback." )
            return
        }
        
        self.reachabilitySerialQueue = dispatchQueue
        
        if self.isUsingIPAddress {
            
            var flags = SCNetworkReachabilityFlags()
            SCNetworkReachabilityGetFlags(self.reachability, &flags)
            self.reachabilityFlags = flags
            
            self.notifyListenerOfChange()
        }
    }
    
    // Stops the current listening of Reachability Changes and optionally clears the handlers.
    public func stop(clearHandlers: Bool = false) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        
        if !SCNetworkReachabilitySetDispatchQueue(self.reachability, nil) {
            debugPrint( "Yarp: Unable to set default reachability route" )
        }
        if !SCNetworkReachabilitySetCallback(self.reachability, nil, nil) {
            debugPrint( "Yarp: Unable to setup nil reachability callback." )
        }
        if clearHandlers {
            self.handlers.removeAll()
        }
    }
    
    // Adds a listener
    @discardableResult public func addHandler(_ key: String?, handler: @escaping Handler) -> String {
        var token: String
        
        if let userKey = key {
            token = userKey
        } else {
            token = NSUUID().uuidString
        }
        
        self.handlers[token] = handler
        return token
    }
    
    // Remove a Specific Handler based on your key or the one generated for you in addHandler
    public func removeHandler(_ key: String) {
        self.handlers.removeValue(forKey: key)
    }
    
    // Removes all handlers, but does not stop the listening events
    public func removeAllHandlers() {
        self.handlers.removeAll()
    }
}
