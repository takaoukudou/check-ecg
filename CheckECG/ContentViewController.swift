//
//  ContentViewController.swift
//  CheckECG
//
//  Created by 工藤貴央 on 2021/05/19.
//

import SwiftUI

struct ContentViewController: UIViewController {
    let view = ContentView()
    
    
    private func showAlert() {
        let alertController = UIAlertController(title: "アラート", message: "これはアラートです", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

