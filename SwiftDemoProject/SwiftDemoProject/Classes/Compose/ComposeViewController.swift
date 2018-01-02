//
//  ComposeViewController.swift
//  WB
//
//  Created by Page on 2017/12/23.
//  Copyright © 2017年 Page. All rights reserved.
//

import UIKit
import SVProgressHUD

class ComposeViewController: UIViewController {
    
     // MARK:- 控件属性
    @IBOutlet weak var textView: PLTextView!
    @IBOutlet weak var picPickerView: PicPickerCollectionView!
    
    // MARK:- 懒加载属性
    fileprivate lazy var titleView : PLTitleView = PLTitleView()
    
    fileprivate lazy var images : [UIImage] = [UIImage]()
    
    fileprivate lazy var emoticonVc : EmoticonController = EmoticonController {[weak self] (emoticon) -> () in
        self?.textView.insertEmoticon(emoticon: emoticon)
        self?.textViewDidChange(self!.textView)
    }


    // MARK:- 约束的属性
    @IBOutlet weak var picPicerViewHCons: NSLayoutConstraint!
    @IBOutlet weak var toolBarBottomCons: NSLayoutConstraint!
    
    // MARK:- 系统回调函数
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置导航栏
        setupNavigationBar()
        // 监听通知
        setupNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textView.becomeFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}



// MARK:- 设置UI界面
extension ComposeViewController {
    fileprivate func setupNavigationBar() {
        // 1.设置左右的item
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(closeItemClick))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "发送", style: .plain, target: self, action: #selector(sendItemClick))
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        // 2.设置标题
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        navigationItem.titleView = titleView
    }
    
    fileprivate func setupNotifications() {
        // 监听键盘的弹出
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(note:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        // 监听添加照片的按钮的点击
        NotificationCenter.default.addObserver(self, selector: #selector(addPhotoClick), name: NSNotification.Name(rawValue: PicPickerAddPhotoNote), object: nil)
        
        // 监听删除照片的按钮的点击
        NotificationCenter.default.addObserver(self, selector: #selector(removePhotoClick(note:)), name: NSNotification.Name(rawValue: PicPickerRemovePhotoNote), object: nil)
    }

}


// MARK:- 事件监听函数
extension ComposeViewController {
    
    @objc fileprivate func closeItemClick() {
        // 0.键盘退出
        textView.resignFirstResponder()
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func sendItemClick() {
        // 0.键盘退出
        textView.resignFirstResponder()
        
        // 1.获取发送微博的微博正文
        let statusText = textView.getEmoticonString()
        
        // 2.定义回调的闭包
        let finishedCallback = { (isSuccess : Bool) -> () in
            if !isSuccess {
                SVProgressHUD.showError(withStatus: "发送微博失败")
                return
            }
            SVProgressHUD.showSuccess(withStatus: "发送微博成功")
            self.dismiss(animated: true, completion: nil)
        }
        
        // 3.获取用户选中的图片
        if let image = images.first {
            NetworkTool.shareInstance.sendStatus(statusText: statusText, image: image, isSuccess: finishedCallback)
        } else {
            NetworkTool.shareInstance.sendStatus(statusText: statusText, isSuccess: finishedCallback)
        }
    }
    
    @objc fileprivate func keyboardWillChangeFrame(note : NSNotification) {
        // 1.获取动画执行的时间
        let duration = note.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        // 2.获取键盘最终Y值
        let endFrame = (note.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let y = endFrame.origin.y
        
        // 3.计算工具栏距离底部的间距
        let margin = UIScreen.main.bounds.height - y
        
        // 4.执行动画
        toolBarBottomCons.constant = margin
        UIView.animate(withDuration: duration) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    
    @IBAction func picPickerBtnClick() {
        // 退出键盘
        textView.resignFirstResponder()
        
        // 执行动画
        picPicerViewHCons.constant = UIScreen.main.bounds.height * 0.65
        UIView.animate(withDuration: 0.5) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    
    @IBAction func emoticonBtnClick() {
        // 1.退出键盘
        textView.resignFirstResponder()
        
        // 2.切换键盘
        textView.inputView = textView.inputView != nil ? nil : emoticonVc.view
        
        // 3.弹出键盘
        textView.becomeFirstResponder()
    }

}

// MARK:- 添加照片和删除照片的事件
extension ComposeViewController {
    @objc fileprivate func addPhotoClick() {
        // 1.判断数据源是否可用
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            return
        }
        
        // 2.创建照片选择控制器
        let ipc = UIImagePickerController()
        
        // 3.设置照片源
        ipc.sourceType = .photoLibrary
        
        // 4.设置代理
        ipc.delegate = self
        
        // 弹出选择照片的控制器
        present(ipc, animated: true, completion: nil)
    }
    
    @objc fileprivate func removePhotoClick(note : NSNotification) {
        // 1.获取image对象
        guard let image = note.object as? UIImage else {
            return
        }
        
        // 2.获取image对象所在下标值
        guard let index = images.index(of: image) else {
            return
        }
        
        // 3.将图片从数组删除
        images.remove(at: index)
        
        // 4.重写赋值collectionView新的数组
        picPickerView.images = images
    }
}

// MARK:- UIImagePickerController的代理方法
extension ComposeViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // 1.获取选中的照片
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // 2.将选中的照片添加到数组中
        images.append(image)
        
        // 3.将数组赋值给collectionView,让collectionView自己去展示数据
        picPickerView.images = images
        
        // 4.退出选中照片控制器
        picker.dismiss(animated: true, completion: nil)
    }
    
}


// MARK:- UITextView的代理方法
extension ComposeViewController : UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.textView.placeHolderLabel.isHidden = textView.hasText
        navigationItem.rightBarButtonItem?.isEnabled = textView.hasText
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        textView.resignFirstResponder()
    }
}

