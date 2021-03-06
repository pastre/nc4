//
//  AppDelegate.swift
//  NC4
//
//  Created by Bruno Pastre on 03/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import UIKit
import GameKit
import Firebase
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    fileprivate func debugFonts() {

                for name in UIFont.familyNames {
                    print(name)
                    if let nameString = name as? String {
        //                print(UIFont.fontNames(forFamilyName: nameString))
                    }
                }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
                
        // Loads particles
        EnemyHitParticleLoader.load()
        
        
        // Configures firebase
        FirebaseApp.configure()
        
        // Configures ads 

        GADMobileAds.sharedInstance().start { (status) in
            print("Initialized ads!")
        }
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["16e43876ab970d8a769187172612033f" ]
        
        // Loads starting vc
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()!
        
        window?.rootViewController = vc
        
        // Loads IAP
        StoreManager.instance.fire()
        
        // Loads gamecenter
        GameCenterFacade.instance.auth()
        
        
        // Starts loading ads
        AdManager.instance.start()

        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }


}

