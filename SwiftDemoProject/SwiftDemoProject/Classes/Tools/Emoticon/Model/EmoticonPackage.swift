//
//  EmoticonPackage.swift
//  WB-封装表情键盘
//
//  Created by Page on 2017/12/25.
//  Copyright © 2017年 Page. All rights reserved.
//

import UIKit

class EmoticonPackage: NSObject {

    var emoticonItems : [EmoticonItem] = [EmoticonItem]()
    
    init(id : String) {
        
        super.init()
        
        // 1.最近分组
        if id == "" {
            addEmptyEmoticon(isRecently: true)
            return
        }
        
        // 2.根据id拼接info.plist的路径
        let plistPath = Bundle.main.path(forResource: "\(id)/info.plist", ofType: nil, inDirectory: "Emoticons.bundle")!
        
        // 3.根据plist文件的路径读取数据 [[String : String]]
        let array = NSArray(contentsOfFile: plistPath)! as! [[String : String]]
        
        // 4.遍历数组
        var index = 0
        for var dict in array {
            if let png = dict["png"] {
                dict["png"] = id + "/" + png
            }
            
            emoticonItems.append(EmoticonItem(dict: dict))
            index += 1
            
            if index == 20 {
                // 添加删除表情
                emoticonItems.append(EmoticonItem(isRemove: true))
                index = 0
            }
        }
        
        // 5.添加空白表情
        addEmptyEmoticon(isRecently: false)
    }
    
    private func addEmptyEmoticon(isRecently : Bool) {
        let count = emoticonItems.count % 21
        if count == 0 && !isRecently {
            return
        }
        
        for _ in count..<20 {
            emoticonItems.append(EmoticonItem(isEmpty: true))
        }
        
        emoticonItems.append(EmoticonItem(isRemove: true))
    }

}
