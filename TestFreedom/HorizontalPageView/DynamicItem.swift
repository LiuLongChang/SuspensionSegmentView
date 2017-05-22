//
//  DynamicItem.swift
//  TestFreedom
//
//  Created by zzzsw on 2017/5/18.
//  Copyright © 2017年 zzzsw. All rights reserved.
//

import Foundation
import UIKit

class DynamicItem: NSObject {


    var center : CGPoint! = nil
    var bounds : CGRect! {
        return CGRect.init(x: 0, y: 0, width: 1, height: 1)
    }


    var transform : CGAffineTransform! = nil

    

}
