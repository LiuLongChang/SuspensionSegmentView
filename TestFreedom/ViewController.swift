//
//  ViewController.swift
//  TestFreedom
//
//  Created by zzzsw on 2017/5/18.
//  Copyright © 2017年 zzzsw. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let nav = ArtChangeNavVC();
        
        self.navigationController?.pushViewController(nav, animated: true);
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

