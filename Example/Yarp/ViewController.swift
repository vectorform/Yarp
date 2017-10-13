// Copyright (c) 2016 Vectorform LLC
// http://www.vectorform.com/
// http://github.com/vectorform/Yarp
//
//  Yarp Example
//  ViewController.swift
//

import UIKit
import Yarp

class ViewController: UIViewController, UITextFieldDelegate { 

    let defaultYarp: Yarp? = Yarp()
    let googleYarp: Yarp? = Yarp(hostName: "www.google.com")
    var customAddressYarp: Yarp?
    var customHostYarp: Yarp?
    
    var customAddressField: UITextField = {
        class SetHeightTextField: UITextField {
            override var intrinsicContentSize: CGSize {
                return CGSize(width: super.intrinsicContentSize.width, height:  40)
            }
        }
        return SetHeightTextField()
    }()
    let customAddressButton = UIButton()
    
    var customHostField: UITextField = {
        class SetHeightTextField: UITextField {
            override var intrinsicContentSize: CGSize {
                return CGSize(width: super.intrinsicContentSize.width, height:  40)
            }
        }
        return SetHeightTextField()
    }()
    let customHostButton = UIButton()
    
    let defaultNameLabel = UILabel()
    let defaultStatusLabel = UILabel()
    
    let googleNameLabel = UILabel()
    let googleStatusLabel = UILabel()
    
    let customAddressNameLabel = UILabel()
    let customAddressStatusLabel = UILabel()
    
    let customHostNameLabel = UILabel()
    let customHostStatusLabel = UILabel()
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.white
        
        let scrollView = UIScrollView()
        let stackView = UIStackView(arrangedSubviews:
            [UIView(),
             self.defaultNameLabel,
             self.defaultStatusLabel,
             UIView(),
             self.googleNameLabel,
             self.googleStatusLabel,
             UIView(),
             UIView(),
             self.customAddressField,
             self.customAddressButton,
             self.customAddressNameLabel,
             self.customAddressStatusLabel,
             UIView(),
             self.customHostField,
             self.customHostButton,
             self.customHostNameLabel,
             self.customHostStatusLabel])
        
        self.defaultNameLabel.backgroundColor = UIColor.red.withAlphaComponent(0.15)
        self.defaultStatusLabel.backgroundColor = UIColor.red.withAlphaComponent(0.15)
        
        self.googleNameLabel.backgroundColor = UIColor.blue.withAlphaComponent(0.15)
        self.googleStatusLabel.backgroundColor = UIColor.blue.withAlphaComponent(0.15)
        
        self.customAddressNameLabel.backgroundColor = UIColor.green.withAlphaComponent(0.15)
        self.customAddressStatusLabel.backgroundColor = UIColor.green.withAlphaComponent(0.15)
        
        self.customHostNameLabel.backgroundColor = UIColor.yellow.withAlphaComponent(0.15)
        self.customHostStatusLabel.backgroundColor = UIColor.yellow.withAlphaComponent(0.15)
        
        stackView.axis = .vertical
        stackView.spacing = 20
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        scrollView.delaysContentTouches = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        
        customAddressField.placeholder = "Enter IP Address"
        customAddressField.autocapitalizationType = .none
        customAddressField.borderStyle = .line
        customAddressField.returnKeyType = .done
        customAddressField.delegate = self
        
        customAddressButton.clipsToBounds = true
        customAddressButton.setTitleColor(UIColor.black, for: .normal)
        customAddressButton.backgroundColor =  UIColor.green.withAlphaComponent(0.75)
        customAddressButton.setTitle("Monitor New IP Address", for: .normal)
        customAddressButton.addTarget(self, action: #selector(customAddressButtonPressed), for: .touchUpInside)
        
        
        customHostField.placeholder = "Enter Host Name"
        customHostField.autocapitalizationType = .none
        customHostField.borderStyle = .line
        customHostField.returnKeyType = .done
        customHostField.delegate = self
        
        customHostButton.clipsToBounds = true
        customHostButton.setTitleColor(UIColor.black, for: .normal)
        customHostButton.backgroundColor = UIColor.yellow.withAlphaComponent(0.75)
        customHostButton.setTitle("Monitor New Host", for: .normal)
        customHostButton.addTarget(self, action: #selector(customHostButtonPressed), for: .touchUpInside)
        
        defaultNameLabel.text = "Default Apple Reachability IP: 0.0.0.0"
        googleNameLabel.text = "Google Hostname: www.google.com"
        customAddressNameLabel.text = "Custom Address: ---"
        customHostNameLabel.text = "Custom Host: ---"
    }

    //to fix apples not hiding textfields by default
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func customAddressButtonPressed() {
        if customAddressYarp == nil {
            self.view.endEditing(true)
            let address = customAddressField.text!
            customAddressYarp = Yarp(hostAddress: address)
            if let customAddressYarp = customAddressYarp {
                customAddressNameLabel.text = "Custom Address: " + address
                UIView.animate(withDuration: 0.3,
                               animations: {
                                self.customAddressField.isHidden = true
                                self.customAddressButton.isHidden = true //only allow people to set it once for testing
                })
                NotificationCenter.default.addObserver(self, selector: #selector(customAddressReachabilityChanged), name: Yarp.StatusChangedNotification, object: customAddressYarp)
            }
            customAddressYarp?.start()
        }
    }
    
    @objc func customHostButtonPressed() {
        if customHostYarp == nil {
            self.view.endEditing(true)
            let hostName = customHostField.text!
            customHostYarp = Yarp(hostName: customHostField.text!)
            if let customHostYarp = customHostYarp {
                customHostNameLabel.text = "Custom Host: " + hostName
                UIView.animate(withDuration: 0.3, animations: {
                    self.customHostField.isHidden = true
                    self.customHostButton.isHidden = true //only allow people to set it once for testing
                })
                NotificationCenter.default.addObserver(self, selector: #selector(customHostReachabilityChanged), name: Yarp.StatusChangedNotification, object: customHostYarp)
            }
            customHostYarp?.start()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        
        if let defaultYarp = defaultYarp {
            NotificationCenter.default.addObserver(self, selector: #selector(defaultReachabilityChanged), name: Yarp.StatusChangedNotification, object: defaultYarp)
        }
        if let googleYarp = googleYarp {
            NotificationCenter.default.addObserver(self, selector: #selector(googleReachabilityChanged), name: Yarp.StatusChangedNotification, object: googleYarp)
        }
        
        defaultYarp?.start()
        googleYarp?.start()
    }
    
    @objc func defaultReachabilityChanged(notification: Notification) {
        if let yarp = notification.object as? Yarp {
            if let reachable = yarp.isReachable {
                print("default reachability changed: \(reachable)")
                defaultStatusLabel.text = "Default isReachable: \(reachable)"
            }
        }
    }
    
    @objc func googleReachabilityChanged(notification: Notification) {
        if let yarp = notification.object as? Yarp {
            if let reachable = yarp.isReachable {
                print("reachability changed: \(reachable)")
                googleStatusLabel.text = "Google isReachable: \(reachable)"
            }
        }
    }
    
    //example for if you need to see the flags more directly
    @objc func customAddressReachabilityChanged(notification: Notification) {
        if let yarp = notification.object as? Yarp {
            if let reachable = yarp.isReachable {
                print("custom reachability changed: \(reachable)")
                
                if let reachabilityFlags = yarp.reachabilityFlags {
                    var output = "Custom isReachable: \(reachable)\n"
                    output += "Reachable Flag: \(reachabilityFlags.contains(.reachable))\n"
                    output += "WWAN Flag: \(reachabilityFlags.contains(.isWWAN))\n"
                    output += "Is Direct Flag: \(reachabilityFlags.contains(.isDirect))\n"
                    output += "Is Local Flag: \(reachabilityFlags.contains(.isLocalAddress))\n"
                    
                    customAddressStatusLabel.text = output
                }
            }
        }
    }
    
    //example for if you need to see the flags more directly
    @objc func customHostReachabilityChanged(notification: Notification) {
        if let yarp = notification.object as? Yarp {
            if let reachable = yarp.isReachable {
                print("custom reachability changed: \(reachable)")
                
                if let reachabilityFlags = yarp.reachabilityFlags {
                    var output = "Custom isReachable: \(reachable)\n"
                    output += "Reachable Flag: \(reachabilityFlags.contains(.reachable))\n"
                    output += "WWAN Flag: \(reachabilityFlags.contains(.isWWAN))\n"
                    output += "Is Direct Flag: \(reachabilityFlags.contains(.isDirect))\n"
                    output += "Is Local Flag: \(reachabilityFlags.contains(.isLocalAddress))\n"
                    
                    customHostStatusLabel.text = output
                }
            }
        }
    }
}
