//
//  UserAccountViewModel.swift
//  WB
//
//  Created by Page on 2017/12/21.
//  Copyright © 2017年 Page. All rights reserved.
//

import Foundation

class UserAccountViewModel {
    
    // MARK:- 将类设计成单例
    static let shareIntance : UserAccountViewModel = UserAccountViewModel()
    
    // MARK:- 定义属性
    var accountItem : UserAccountItem?
    
    // MARK:- 计算属性
    var accountItemPath : String {
        let accountItemPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
//        print(accountItemPath)
        return (accountItemPath as NSString).appendingPathComponent("account.plist")
    }
    
    var isLogin : Bool {
        if accountItem == nil {
            return false
        }
        
        guard let expiresDate = accountItem?.expires_date else {
            return false
        }
        // 判断accessToken是否过期
        return expiresDate.compare(NSDate() as Date) == ComparisonResult.orderedDescending
    }
    
    // MARK:- 重写init()函数
    init () {
        // 1.从沙盒中读取中归档的信息
        accountItem = NSKeyedUnarchiver.unarchiveObject(withFile: accountItemPath) as? UserAccountItem
    }
}
