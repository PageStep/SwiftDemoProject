//
//  AppDelegate.swift
//  SwiftDemoProject
//
//  Created by Page on 2018/1/3.
//  Copyright © 2018年 Page. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var defaultViewController : UIViewController? {
        let isLogin = UserAccountViewModel.shareIntance.isLogin
        return isLogin ? WelcomeViewController() : UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // 设置全局的tabBar的tintColor
        UITabBar.appearance().tintColor = UIColor.orange
        // 设置全局的navBar的tintColor
        UINavigationBar.appearance().tintColor = UIColor.orange
        
        // 创建window
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = defaultViewController
        window?.makeKeyAndVisible()
        
        
        return true
    }
    
}

