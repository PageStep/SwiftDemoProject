//
//  PicPickerViewCell.swift
//  WB
//
//  Created by Page on 2017/12/25.
//  Copyright © 2017年 Page. All rights reserved.
//

import UIKit

class PicPickerViewCell: UICollectionViewCell {
    
    // MARK:- 控件的属性
    @IBOutlet weak var addPhotoBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var removePhotoBtn: UIButton!
    
    // MARK:- 定义属性
    var image : UIImage? {
        didSet {
            if image != nil {
                imageView.image = image
                addPhotoBtn.isUserInteractionEnabled = false
                removePhotoBtn.isHidden = false
            } else {
                imageView.image = nil
                addPhotoBtn.isUserInteractionEnabled = true
                removePhotoBtn.isHidden = true
            }
        }
    }

    // MARK:- 事件监听
    @IBAction func addPhotoClick() {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: PicPickerAddPhotoNote), object: nil)

    }
    
    @IBAction func removePhotoClick() {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: PicPickerRemovePhotoNote), object: imageView.image)
        
    }
    
}
