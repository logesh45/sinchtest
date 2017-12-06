//
//  AppDelegate.swift
//  Sinch test
//
//  Created by Logesh R on 17/11/17.
//  Copyright © 2017 Logesh R. All rights reserved.
//

import UIKit
import CoreData
import CallKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SINClientDelegate, SINCallClientDelegate, SINManagedPushDelegate {
    
    
    
    
    var push: SINManagedPush!
    var callKitProvider: SINCallKitProvider!
    var client: SINClient!
    var window: UIWindow?
    
    //SINCallClient delegates
    func clientDidStart(_ client: SINClient!) {
        print("Sinch client started successfully (version: \(Sinch.version()) with userid \(client.userId)")
    }
    
    func clientDidFail(_ client: SINClient!, error: Error!) {
        print("Sinch client error: \(String(describing: error?.localizedDescription))")
    }
    
    
    func client(_ client: SINClient, willReceiveIncomingCall call: SINCall) {
        print("Will receive incoming call")
        callKitProvider?.reportNewIncomingCall(call)
    }
    
    
    func client(_ client: SINCallClient, didReceiveIncomingCall call: SINCall) {
        // Find MainViewController and present CallViewController from it.
        var top: UIViewController? = window?.rootViewController
        while ((top?.presentedViewController) != nil) {
            top = top?.presentedViewController
        }
        print("Got VC \(top)")
        top?.performSegue(withIdentifier: "toCallVC", sender: call)
    }
    
    func client(_ client: SINClient, logMessage message: String, area: String, severity: SINLogSeverity, timestamp: Date) {
        
            print("\(message)")
        
    }
    
    
    
    
    
    
    
    //SINManagedPushDelegate
    func managedPush(_ managedPush: SINManagedPush!, didReceiveIncomingPushWithPayload payload: [AnyHashable : Any]!, forType pushType: String!) {
        print("Got notification in managed push  \(payload)")


        handleRemoteNotification(payload)

    }
    

    
    
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        push = Sinch.managedPush(with: SINAPSEnvironment.development)
        push?.delegate = self
//        push?.setDesiredPushTypeAutomatically()
        push.setDesiredPushType(SINPushTypeVoIP)
        
        
        
        func onUserDidLogin(_ userId: String)  {
            self.push?.registerUserNotificationSettings()
            print("calling initSinch")
            self.initSinchClient(withUserId: userId)
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name("UserDidLoginNotification"), object: nil, queue: nil, using: {(_ note: Notification) -> Void in
            print("Got notification")
            let userId = note.userInfo!["userId"] as? String
            UserDefaults.standard.set(userId, forKey: "userId")
            UserDefaults.standard.synchronize()
            onUserDidLogin(userId!)
        })
        
        
        
        return true
    }
    
    func initSinchClient(withUserId userId: String) {
        
        if client == nil {
            print("initializing client 2")
            client = Sinch.client(withApplicationKey: "appkey",
                                  applicationSecret: "secretkey",
                                  environmentHost: "sandbox.sinch.com",
                                  userId: userId)
            client.delegate = self
            client.call().delegate = self
            client.setSupportCalling(true)
            client.enableManagedPushNotifications()
            client.start()
        
            callKitProvider = SINCallKitProvider(client: client)
        }
    }
    
    func handle2(payload:String){
        let userId = UserDefaults.standard.object(forKey: "userId") as? String
        if userId != nil {
            initSinchClient(withUserId: userId!)
        }
        print(payload)
        
        client.relayRemotePushNotificationPayload(payload)
        
    }
    func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) {
//         if client == nil {
        print("at \(#function) ")
            let userId = UserDefaults.standard.object(forKey: "userId") as? String
        
                print("No user")
                initSinchClient(withUserId: userId!)
            
//        }
        print("Userinfo \(userInfo)")
        
        client.start()
        client.delegate = self
        client.call().delegate = self
        var result = client.relayRemotePushNotification(userInfo)
        print(result?.isCall())
        print(result?.isMessage())
        
    }
    
    
    //Push delegates
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registered for push , token - \(deviceToken)")
        push?.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("Received notification userinfo \(userInfo)")
        push?.application(application, didReceiveRemoteNotification: userInfo)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error registering for notification")
        print("\(NSStringFromSelector(#function)):\(error)")
    }
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Sinch_test")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

