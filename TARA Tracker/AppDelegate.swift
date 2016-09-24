//
//  AppDelegate.swift
//  TARA Tracker
//
//  Created by Justin Wei on 8/25/16.
//  Copyright © 2016 Justin Wei. All rights reserved.
//

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Implement local notifications that repeat at 7 PM every day
        let notificationSettings = UIUserNotificationSettings(types: [.alert, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        self.createLocalNotification()
        return true
    }
    
    // creation of local notification
    func createLocalNotification() {
        let dateComp:NSDateComponents = NSDateComponents()
        dateComp.year = 2016;
        dateComp.month = 06;
        dateComp.day = 25;
        dateComp.hour = 19;
        dateComp.minute = 00;
        dateComp.timeZone = NSTimeZone.system
        let calender:NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let date:NSDate = calender.date(from: dateComp as DateComponents)! as NSDate
        
        let localNotification = UILocalNotification()
        localNotification.fireDate = date as Date
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.alertBody = "Remember to complete your practices! Every minute counts :)"
        localNotification.repeatInterval = NSCalendar.Unit.day
        UIApplication.shared.scheduleLocalNotification(localNotification)
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

