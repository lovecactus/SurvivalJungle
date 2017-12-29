//
//  AppDelegate.swift
//  Survival
//
//  Created by YANGWEI on 19/09/2017.
//  Copyright © 2017 GINOFF. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        //test
//        var allCreatures:[Creature] = []
//        var allCreatureDict:[CreatureUniqueID:Creature] = [:]
//        for index in 1...10000 {
//            let newBorn = GenericSpecies.init(familyName: "Generic",
//                                              givenName: String(index),
//                                              methodology: Methodology.randomMethodGenerator(),
//                                              age: Int(arc4random_uniform(50)))
//            allCreatures.append(newBorn)
//            allCreatureDict["Tester Creature"+String(index)] = newBorn
//        }
//
//
//        for _ in 1...Int.max {
//            let creatureIndex = "Tester Creature"+String(arc4random_uniform(UInt32(allCreatures.count)))
//            let _ = allCreatures.findCreatureBy(uniqueID: creatureIndex)
//            let _ = allCreatureDict[creatureIndex]
//        }
        return true
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
        // Override point for customization after application launch.
        let statisticsVC = LineChartStaticsViewController(Statistic: [])
        self.window?.rootViewController = statisticsVC
        DispatchQueue.global(qos: .default).async {
            let jungle = SurvivalJungle(totalResource: 10000, averageCreatureNumber: 500)
            for _ in 1...INT_MAX {
                let survivalStatic = jungle.Run(10)
                DispatchQueue.main.async {
                    statisticsVC.updateStaticsData(survivalStatic)
                }
                
                if (jungle.allCreatures.count < 30){
                    print("Creature extinction!")
                }
                print("Survived:"+String(jungle.allCreatures.count))
                print("Died:"+String(jungle.diedCreatures.count))
                print("Check statics")
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

