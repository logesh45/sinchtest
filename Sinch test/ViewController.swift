//
//  ViewController.swift
//  Sinch test
//
//  Created by Logesh R on 17/11/17.
//  Copyright © 2017 Logesh R. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let callViewController = segue.destination as? CallViewController
        callViewController?.call = sender as! SINCall
    }
}

