//
//  EmoticonManager.swift
//  WB-封装表情键盘
//
//  Created by Page on 2017/12/25.
//  Copyright © 2017年 Page. All rights reserved.
//

import UIKit

class EmoticonManager {
    
    var packages : [EmoticonPackage] = [EmoticonPackage]()
    
    init () {
        // 1.添加最近表情的包
        packages.append(EmoticonPackage(id: ""))
        
        // 2.添加默认表情的包
        packages.append(EmoticonPackage(id: "com.sina.default"))
        
        // 3.添加emoji表情的包
        packages.append(EmoticonPackage(id: "com.apple.emoji"))
        
        // 4.添加浪小花表情的包
        packages.append(EmoticonPackage(id: "com.sina.lxh"))
    }


}
