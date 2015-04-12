//
//  AppDelegate.swift
//  SwiftySequencer
//
//  Created by Ariel Elkin on 10/04/2015.
//  Copyright (c) 2015 Ariel. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var audioManager = AudioManager()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let viewController = ViewController(nibName: nil, bundle: nil)
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        audioManager.stop()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        audioManager.start()
    }
}

