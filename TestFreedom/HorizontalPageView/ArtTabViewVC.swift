//
//  ArtTabViewVC.swift
//  TestFreedom
//
//  Created by 刘隆昌 on 2017/5/21.
//  Copyright © 2017年 zzzsw. All rights reserved.
//

import UIKit

extension ArtTabViewVC{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        let cell = UITableViewCell()

        cell.backgroundColor = UIColor.init(red: CGFloat(Double(arc4random()%255)/255.0), green: CGFloat(Double(arc4random()%255)/255.0), blue: CGFloat(Double(arc4random()%255)/255.0), alpha: 1.0)


        return cell;
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50;
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0;
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001;
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        //通过最后一个 Footer  来补高度
        if section == self.numberOfSections(in: tableView) - 1 {
            return self.automaticHeightForTableView(tableView: tableView)
        }
        
        return 0.01;
        
    }
    
    
    
    
    func automaticHeightForTableView(tableView:UITableView)->CGFloat{
        
        var height : CGFloat! = self.fillHeight
        let section = tableView.dataSource?.numberOfSections!(in: tableView)
        
        for idx in 0..<Int(section!) {
            
            let heightTemp : CGFloat! = tableView.delegate?.tableView!(tableView, heightForHeaderInSection: idx)
            height = height + heightTemp;
            
            
            let row = tableView.dataSource?.tableView(tableView, numberOfRowsInSection: idx)
            
            for j in 0..<Int(row!) {
                let idxPath = IndexPath.init(row: j, section: idx);
                let tempH : CGFloat! = tableView.delegate?.tableView!(tableView, heightForRowAt: idxPath);
                height = height + tempH;
                if height >= tableView.frame.size.height {
                    return 0.0001;
                }
            }
            
            
            if idx != section! - 1 {
                let heightTemp : CGFloat! = tableView.delegate?.tableView!(tableView, heightForFooterInSection: idx)
                height = height + heightTemp;
            }
            
        }
        
        
        if height >= tableView.frame.size.height {
            return 0.0001;
        }
        return tableView.frame.size.height - height;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    

}





class ArtTabViewVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var tabView : UITableView! = nil
    var index : Int! = nil
    var allowPullToRefresh : Bool! = false
    var pullOffset: CGFloat! = 0
    var fillHeight : CGFloat! = 0
    
    
    override func loadView() {
        self.tabView = UITableView.init(frame: .zero, style: .grouped)
        self.tabView.dataSource = self
        self.tabView.delegate = self
        self.tabView.separatorStyle = .none
        self.tabView.backgroundColor = UIColor.init(red: CGFloat((Double(arc4random()%255)/255.0)/255.0), green: CGFloat((Double(arc4random()%255)/255.0)/255.0), blue: CGFloat((Double(arc4random()%255)/255.0)/255.0), alpha: 1.0)
        self.view = self.tabView;
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if !self.allowPullToRefresh {
            return;
        }
        
        
        
        // Do any additional setup after loading the view.
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
