//
//  EditNamesViewController.swift
//  Audio2TextSwiftDemo
//
//  Created by FanPengpeng on 2022/4/20.
//

import UIKit

class EditNamesViewController: UIViewController {

    @IBOutlet weak var name1TF: UITextField!
    @IBOutlet weak var name2TF: UITextField!
    @IBOutlet weak var name3TF: UITextField!
    @IBOutlet weak var name4TF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if KeyCenter.namesArray.count >= 3 {
            name1TF.text = KeyCenter.namesArray[0]
            name2TF.text = KeyCenter.namesArray[1]
            name3TF.text = KeyCenter.namesArray[2]
            name4TF.text = KeyCenter.namesArray[3]
        }else{
            name1TF.text = "self"
            name2TF.text = "broadcaster1"
            name3TF.text = "broadcaster2"
            name4TF.text = "broadcaster3"
        }
    }

    @IBAction func clickCancelBarItem(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickSaveBarItem(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
        KeyCenter.namesArray = [name1TF.text!,name2TF.text!,name3TF.text!,name4TF.text!]
    }
}
