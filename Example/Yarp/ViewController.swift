//
//  ViewController.swift
//  Yarp
//
//  Created by Jeff Meador on 11/22/16.
//  Copyright © 2016 Vectorform. All rights reserved.
//

import UIKit
import Yarp

class ViewController: UIViewController, UITextFieldDelegate { 

    let defaultYarp: Yarp? = Yarp() //  "http://8.8.8.8:80")
    let googleYarp: Yarp? = Yarp(hostName: "http://216.58.195.238")
    var customYarp: Yarp?
    
//    let hostAddressExample = Yarp(hostAddress: "216.58.195.238") 
    
    let customAddressField = UITextField(frame: CGRect(x: 20, y: 20, width: 200, height: 50))
    let reachabaleButton = UIButton(frame: CGRect(x: 20, y: 100, width: 200, height: 50))
    
    let defaultNameLabel = UILabel(frame: CGRect(x: 5, y: 150, width: 300, height: 25))
    let googleNameLabel =  UILabel(frame: CGRect(x: 5, y: 200, width: 300, height: 25))
    let customNameLabel =  UILabel(frame: CGRect(x: 5, y: 250, width: 300, height: 25))
    
    let defaultStatusLabel = UILabel(frame: CGRect(x: 20, y: 175, width: 300, height: 25))
    let googleStatusLabel =  UILabel(frame: CGRect(x: 20, y: 225, width: 300, height: 25))
    let customStatusLabel =  UILabel(frame: CGRect(x: 20, y: 275, width: 300, height: 150))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customAddressField.autocapitalizationType = .none
        customAddressField.borderStyle = .line
        customAddressField.returnKeyType = .done
        customAddressField.delegate = self
        
        reachabaleButton.layer.cornerRadius = 5
        reachabaleButton.clipsToBounds = true
        reachabaleButton.backgroundColor = UIColor.purple
        reachabaleButton.setTitle("Create New Yarp", for: .normal)
        reachabaleButton.addTarget(self, action: #selector(addCustomYarp), for: .touchUpInside)
        
        view.addSubview(customAddressField)
        view.addSubview(reachabaleButton)
        view.addSubview(customAddressField)
        
        defaultNameLabel.text = "Default Apple Reachability IP (0.0.0.0)"
        googleNameLabel.text = "Google Hostname (www.google.com)"
        customNameLabel.text = "Custom : ---"
        
        
        defaultYarp?.addHandler("key1", handler: { (yarp) in
            if let reachable = yarp.isReachable {
                print("default block yarp has reachable \(reachable)")
            }
        })
        
        googleYarp?.addHandler("key1", handler: { (yarp) in
            if let reachable = yarp.isReachable {
                print("google block yarp has reachable \(reachable)")
            }
        })
        
        defaultYarp?.start()
        googleYarp?.start()
        
        view.addSubview(defaultNameLabel)
        view.addSubview(googleNameLabel)
        view.addSubview(customNameLabel)
        
        customStatusLabel.numberOfLines = 0
        
        view.addSubview(defaultStatusLabel)
        view.addSubview(googleStatusLabel)
        view.addSubview(customStatusLabel)
        
    }
    
    //to fix apples not hiding textfields by default
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func addCustomYarp() {
        if customYarp == nil {
            var hostName = customAddressField.text!
            if !hostName.hasPrefix("http://") {
                hostName = "http://" + hostName
            }
            customYarp = Yarp(hostName: customAddressField.text!)
            if let customYarp = customYarp {
                customNameLabel.text = "Custom : " + hostName
                reachabaleButton.isHidden = true //only allow people to set it once for testing
                NotificationCenter.default.addObserver(self, selector: #selector(customReachabilityChanged(_:)), name: Yarp.StatusChangedNotification, object: customYarp)
            }
            customYarp?.start()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let defaultYarp = defaultYarp {
            NotificationCenter.default.addObserver(self, selector: #selector(defaultReachabilityChanged(_:)), name: Yarp.StatusChangedNotification, object: defaultYarp)
        }
        if let googleYarp = googleYarp {
            NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: Yarp.StatusChangedNotification, object: googleYarp)
        }
    }
    
    
    
    func defaultReachabilityChanged(_ notification: Notification) {
        if let yarp = notification.object as? Yarp {
            print(yarp.isReachable)
            if let reachable = yarp.isReachable {
                defaultStatusLabel.text = "Default isReachable: \(reachable)"
            }
        }
    }
    
    func reachabilityChanged(_ notification: Notification) {
        if let yarp = notification.object as? Yarp {
            print(yarp.isReachable)
            if let reachable = yarp.isReachable {
                googleStatusLabel.text = "Google isReachable: \(reachable)"
            }
        }
    }
    
    //example for if you need to see the flags more directly
    func customReachabilityChanged(_ notification: Notification) {
        if let yarp = notification.object as? Yarp {
            print(yarp.isReachable)
            if let reachable = yarp.isReachable {
                
                
                var output = "Custom isReachable: \(reachable)\n"
                output += "Reachable Flag: \(yarp.reachabilityFlags?.contains(.reachable))\n"
                output += "WWAN Flag: \(yarp.reachabilityFlags?.contains(.isWWAN))\n"
                output += "Is Direct Flag: \(yarp.reachabilityFlags?.contains(.isDirect))\n"
                output += "Is Local Flag: \(yarp.reachabilityFlags?.contains(.isLocalAddress))\n"
                
                customStatusLabel.text = output
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

