//
//  CheckECGApp.swift
//  CheckECG WatchKit Extension
//
//  Created by 工藤貴央 on 2021/05/15.
//

import SwiftUI

@main
struct CheckECGApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
