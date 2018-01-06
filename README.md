# SwiftDemoProject 展示

## 模块-首页微博
- 显示微博页面, 正文微博和转发微博
- 点击图片, 以动画效果弹出高清大图
- 查看大图时, 点击保存, 保存到系统相册
- 左右滑动, 切换图片
- 下拉刷新, 上拉加载更多

![gif](https://github.com/PageStep/SwiftDemoProject/raw/master/Screenshots/1.gif)
![gif](https://github.com/PageStep/SwiftDemoProject/raw/master/Screenshots/2.gif)

## 模块-发布微博
- 点击发布按钮, 弹出发布微博界面
- 点击表情按钮, 弹出表情键盘
- 点击图片按钮, 可以选择系统相册中的图片
- 点击发布按钮, 发布微博

![gif](https://github.com/PageStep/SwiftDemoProject/raw/master/Screenshots/3.gif)


# SwiftDemoProject 设计思路

## 基本架构
- window.rootViewController -> UITabBarController
- tabBarController.viewControllers -> UINavigationController
- navigationController.rootViewController -> UITableViewController

- 1.AppDelegate中, 取出沙盒中的模型数据, 判断是否是登陆状态, 未登录, 显示未登录的界面, 已登陆, 显示首页微博
- 2.未登录时, 点击登录按钮, 弹出控制器进入新浪微博官方登录接口
  - 在微博开放平台注册, 创建应用, 获取App Key, App Secret, 回调地址
  - 按照微博开放平台API文档说明拼接官方登录界面的地址 (需要用到App Key, 回调地址)
  - 登录后, 在webView的代理方法中, 拦截到包含code的URL地址, 将code数据截取出来
  - 按照API文档说明拼接参数请求AccessToken (需要用到App Key, App Secret, 回调地址, code)
  - 用AccessToken请求用户信息, 把AccessToken和用户信息保存到模型中, 再存储到沙盒中
  - 根据模型中的用户信息, 弹出欢迎界面, 再显示首页微博


## 模块-首页微博
### 1.自定义模型
- 1.自定义model模型, 专门用来存储数据
- 2.自定义viewModel模型, 专门用来处理数据
  - 在viewModel模型中, 新增其它属性, 保存处理后的数据

### 2.首页微博控制器中 (UITableViewController)
- 1.设置UI界面
- 2.实现请求数据的方法
- 3.实现tableView数据源方法和代理方法(返回cell的height)

### 3.自定义UITableViewCell, 展示微博
- 1.新增viewModel属性, 在属性的监听中(didSet):
  - 根据模型数据确定是否隐藏cell中的视图控件
  - 把数据赋值给cell中视图控件
  - 计算cell的height

### 4.自定义UICollectionView, 展示cell中的微博图片
- 1.通过其父控件tableViewCell传递过来的数据, 实现UICollectionView的数据源方法, 展示图片
- 2.实现UICollectionView的代理方法, 监听collectionViewCell的点击, 发通知给tableViewController, 弹出浏览图片的控制器

### 5.自定义浏览图片的控制器 (UIViewController)
- 1.添加collectionView, 可以左右滑动来展示高清图
- 2.自定义collectionViewCell, cell中添加imageView, 监听imageView的点击, 退出当前控制器

### 6.自定义继承NSObject的Animator类, 实现动画效果
- 1.弹出浏览图片的控制器之前, 设置控制器的转场代理(transitioningDelegate)为该类
- 2.实现UIViewControllerTransitioningDelegate的方法, 在方法中返回self, 作为动画转场的代理对象
- 3.实现UIViewControllerAnimatedTransitioning(动画转场)的代理方法, 在对应的方法中, 做具体的动画实现


## 模块-发布微博
### 1.发布微博控制器 (UIViewController)
- 1.设置UI界面
- 2.输入文本框自定义UITextView实现, 监听textView中是否有文本内容, 决定是否可以点击发布微博
- 3.点击图片按钮, 弹出添加图片的view
- 4.点击表情按钮, 文字键盘切换为表情键盘, 再次点击切换为文字键盘
- 5.点击发布按钮, 获取textView和图片view中的内容, 发送给服务器


### 2.从相册中选择图片
- 1.弹出添加图片的view, 自定义UICollectionView实现
  - collectionView中新增images数组属性, 保存图片数据
  - 在images属性的didSet中监听属性的改变, 并刷新collectionView(reloadData)
- 2.监听collectionViewCell的点击
  - 监听添加按钮的点击, 发出通知给控制器, 弹出系统相册选择图片, 选择完毕后, 将选择的image添加到collectionView中的images数组属性中
  - 监听删除按钮的点击, 发出通知给控制器, 将该image从collectionView中的images数组中删除
  
### 3.表情键盘的封装
- 1.表情键盘封装为UIViewController, 添加collectionView来展示表情
- 2.collectionView用分组样式(sections), 来展示多组不同种类的表情
- 3.自定义表情模型, 保存从bundle资源加载的表情图片(emoticons)
- 4.实现collectionView的数据源方法, 展示表情图片
- 5.实现collectionView的代理方法, 监听表情item的点击
  - 将点击的表情插入最近分组中
  - 将点击的表情通过闭包(block)回调给发布微博控控制器(注意block和当前控制器的循环引用问题), 把emoticon表情插入到textView中(需要做图文混排)
- 6.将微博正文和转发微博的label中的text转换为属性字符串, string -> NSMutableAttributedString
  - 从服务器请求到的的数据中, 文字内容是string, 不能直接显示表情
  - 需要将表情文字通过正则表达式匹配出来, 再将对应的表情图片插入到属性字符串中, 在label中显示


## 其它
- Swift语言, 简洁自然, 逻辑严谨

- 用到的第三方框架
  - AFNetworking
  - SDWebImage
  - MJRefresh
  - SVProgressHUD
  - SnapKit

- 注意: 新浪开放平台已经把关于发布的接口, 升级切换为新的分享接口: statuses/share (第三方分享链接到微博)

