//
//  GoalViewController.swift
//  Commotion
//
//  Created by Ashley Isles on 9/30/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//

import UIKit

class GoalViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var set_goal: UITextField!
    @IBOutlet weak var step_label: UILabel!
    @IBOutlet weak var prev_step_goal: UILabel!
    
    
    
    var steps:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GoalViewController.dismissKeyboard))
        
        
        view.addGestureRecognizer(tap)
        
        set_goal.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        step_label.text = textField.text
        steps = Int(textField.text!)!
        prev_step_goal.text = textField.text
        UserDefaults.standard.set(steps!, forKey: "step_goal")
        
    }
    
    //MARK: - Actions

    func dismissKeyboard() {
        view.endEditing(true)
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
