//
//  UIBarButtonItem+Extension.swift
//  WB
//
//  Created by Page on 2017/12/18.
//  Copyright © 2017年 Page. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    /*
     convenience init(imageName : String) {
     self.init()
     
     let btn = UIButton()
     btn.setImage(UIImage(named: imageName), forState: .Normal)
     btn.setImage(UIImage(named: imageName + "_highlighted"), forState: .Highlighted)
     btn.sizeToFit()
     
     self.customView = btn
     }
     */
    
    convenience init(imageName : String) {
        
        let btn = UIButton()
        btn.setImage(UIImage(named: imageName), for: .normal)
        btn.setImage(UIImage(named: imageName + "_highlighted"), for: .highlighted)
        btn.sizeToFit()
        
        self.init(customView : btn)
    }
}

