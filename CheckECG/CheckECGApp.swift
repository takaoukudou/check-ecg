//
//  CheckECGApp.swift
//  CheckECG
//
//  Created by 工藤貴央 on 2021/05/15.
//

import SwiftUI
import HealthKit

@main
struct CheckECGApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    let myHealthStore = HKHealthStore()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        self.requestAuthorization()
        return true
    }
    
    //     Healthデータへのアクセスを申請.
    private func requestAuthorization(){
        let types = Set(arrayLiteral:
                            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
                        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
                        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.oxygenSaturation)!
        )
        // HealthStoreへのアクセス承認をおこなう.
        myHealthStore.requestAuthorization(toShare: types, read: types, completion: { (success, error) in
            if let e = error {
                print("Error: \(e.localizedDescription)")
            }
            print(success ? "Success" : "Failure")
        })
    }
}
