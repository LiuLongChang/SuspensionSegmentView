//
//  ArtChangeNavVC.swift
//  TestFreedom
//
//  Created by 刘隆昌 on 2017/5/21.
//  Copyright © 2017年 zzzsw. All rights reserved.
//

import UIKit


class ArtNavView: UIView {
    
    var leftBtn : UIButton! = nil
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureUI()
    }
    func configureUI(){
        //只是做一个简单示例  要加分割线或其它变化  自行扩展即可
        self.backgroundColor = UIColor.init(white: 1, alpha: 0)
        let btn = UIButton.init(type: .system)
        btn.frame = CGRect.init(x: 0, y: 22, width: 44, height: 44)
        let btnImage = UIImage.init(named: "barbuttonicon_back")
        btn.setImage(btnImage, for: .normal)
        btn.tintColor = UIColor.init(white: 0, alpha: 1)
        self.leftBtn = btn
        self.addSubview(btn);
    }
    func changeAlpha(alpha:CGFloat){
        self.backgroundColor = UIColor.init(white: 1, alpha: alpha)
        self.leftBtn.tintColor = UIColor.init(white: (1-alpha), alpha: 1);
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




extension ArtChangeNavVC:HorizontalPageViewDelegate{
    
    
    
    func numberOfSectionsInPageView(pageView: HorizontalPageView) -> Int {
        return 3;
    }
    
    func pageView(pageView: HorizontalPageView, viewAtIdx: Int) -> UIScrollView {
        let vc = ArtTabViewVC()
        self.addChildViewController(vc)
        vc.index = viewAtIdx;
        vc.fillHeight = self.pageView.segmentTopSpace + 36;
        return vc.view as! UIScrollView
    }

    func headerHeightInPageView(pageView: HorizontalPageView) -> CGFloat {
        return 250;
    }
    
    
    func headerViewInPageView(pageView: HorizontalPageView) -> UIView {
        let headerView = UIView();headerView.isUserInteractionEnabled = true;
        headerView.backgroundColor = UIColor.orange
        return headerView;
    }
    
    
    
    func btn1Click(){
        self.showText(str: "btn1Click")
    }
    
    func btn2Click(){
        self.showText(str: "btn2Click")
    }
    
    
    func segmentHeightInPageView(pageView: HorizontalPageView) -> CGFloat {
        return 36;
    }

    
    func segmentButtonsPageView(pageView: HorizontalPageView) -> [UIButton] {
        
        var btnArray : [UIButton]! = [UIButton]()
        for idx in 0..<3 {
            
                let segmentBtn = UIButton.init(type: .custom)
//            segmentBtn.setBackgroundImage(UIImage.init(named: "Home_title_line"), for: .normal)
//            segmentBtn.setBackgroundImage(UIImage.init(named: "Home_title_line_select"), for: .selected)
            let str = "view\(idx)";

            segmentBtn.backgroundColor = UIColor.init(red: CGFloat(Double(arc4random()%255)/255.0), green: CGFloat(Double(arc4random()%255)/255.0), blue: CGFloat(Double(arc4random()%255)/255.0), alpha: 1.0)

            segmentBtn.setTitle(str, for: .normal);
            segmentBtn.setTitleColor(UIColor.darkGray, for: .normal);
            segmentBtn.setTitleColor(UIColor.red, for: .selected)
            segmentBtn.adjustsImageWhenHighlighted = false;
            btnArray.append(segmentBtn);
        }
        return btnArray
    }
    
    
    
    
    func pageView(pageView: HorizontalPageView, segmentDidSelected item: UIButton, atIndex seledIndex: Int) {
        
        
        print("segmentDidSelected:   \(seledIndex)")
        
    }


    
    func pageView(pageView: HorizontalPageView, segmentDidSelectedSameItem item: UIButton, atIdx seledIdx: Int) {
        
        print("pageView(pageView: HorizontalPageView, segmentDidSelectedSameItem item: UIButton, atIdx seledIdx: Int)")
        
    }
    
    
    
    
    func pageView(pageView: HorizontalPageView, didSwitchIdx aIdx: Int, toIdx: Int) {
        print("pageView(pageView: HorizontalPageView, didSwitchIdx aIdx: Int, toIdx: Int)")
    }
    
    
    func pageViewScrollTop(pageView: HorizontalPageView, offset: CGFloat) {
        if offset >= -84 - 36 {
            return;
        }
        //let fm = self.pageView.pullOffset - 84.0 - 36;
        
        
        let fm = self.pageView.getThePullOffset() - 84.0 - 36;
        let fz = -84 - 36 - offset
        var al = 1.0 - fz / fm
        al = al <= 0.05 ? 0 : al;
        al = al >= 0.95 ? 1 : al;
        self.navView.changeAlpha(alpha: al)
    }

}


class ArtChangeNavVC: UIViewController {

    lazy var pageView : HorizontalPageView = {
        let size = UIScreen.main.bounds.size;
        let page = HorizontalPageView.init(frame: CGRect.init(x: 0, y: 0, width: size.width, height: size.height), delegate: self)
        page.segmentTopSpace = 84
        page.segmentView.backgroundColor = UIColor.init(red: 242.0/255, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        page.maxCacheCout = 5
        page.isGestureSimulate = true
        self.view.addSubview(page)
        return page;
    }()
    var navView : ArtNavView! = nil;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        self.edgesForExtendedLayout = UIRectEdge.all
        view.backgroundColor = UIColor.init(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        self.pageView.reload()
        
        
        /*
         需要设置self.edgesForExtendedLayout = UIRectEdgeNonw;  最好自定义导航栏
         在代理 scrollTopOffset
            作出对应处理来改变 背景色透明度
         */
        self.navView = ArtNavView()
        var size = UIScreen.main.bounds.size
        self.navView.frame = CGRect.init(x: 0, y: 0, width: size.width, height: 84)
        self.view.addSubview(self.navView)
        
        self.navView.leftBtn.addTarget(self, action: #selector(ArtChangeNavVC.back), for: .touchUpInside)
        
    }
    
    func back(){
        self.navigationController?.popViewController(animated: true);
    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    
    
    func showText(str:String){
    
    
    
    
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
