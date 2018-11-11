//
//  TimerViewController.swift
//  DirectMarketingApp
//
//  Created by Megumi Mimura on 2018/11/11.
//  Copyright © 2018 三村恵. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController {
    
    var timer:Timer = Timer()                                                      //追加
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(timeInterval: 5.0,                            //
            target: self,                   //
            selector: Selector(("changeView")),         //
            userInfo: nil,                  //
            repeats: false)                 //追加
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeView() {                                                                //
        self.performSegue(withIdentifier: "toGreen", sender: nil)                        //
    }
}
