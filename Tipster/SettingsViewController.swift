//
//  SettingsViewController.swift
//  Tipster
//
//  Created by Nisarg Mehta on 11/1/15.
//  Copyright © 2015 Open Source. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet weak var optionOneLabel: UILabel!
    @IBOutlet weak var optionTwoLabel: UILabel!
    @IBOutlet weak var optionThreeLabel: UILabel!
    
    @IBOutlet weak var firstStepper: UIStepper!
    @IBOutlet weak var secondStepper: UIStepper!
    @IBOutlet weak var thirdStepper: UIStepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "Settings"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let opt1 = UserDefaults.standard.double(forKey: OKSERVICEKEY)
        let opt2 = UserDefaults.standard.double(forKey: GOODSERVICEKEY)
        let opt3 = UserDefaults.standard.double(forKey: AWESOMESERVICEKEY)
        if opt3 != 0 {
            self.firstStepper.value = opt1;
            self.secondStepper.value = opt2;
            self.thirdStepper.value = opt3;
        }
        self.optionOneLabel.text = String(format: "%.f%%", self.firstStepper.value)
        self.optionTwoLabel.text = String(format: "%.f%%", self.secondStepper.value)
        self.optionThreeLabel.text = String(format: "%.f%%", self.thirdStepper.value)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set(self.firstStepper.value, forKey: OKSERVICEKEY)
        UserDefaults.standard.set(self.secondStepper.value, forKey: GOODSERVICEKEY)
        UserDefaults.standard.set(self.thirdStepper.value, forKey: AWESOMESERVICEKEY)
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        switch sender.tag {
        case 1:
            self.optionOneLabel.text = String(format: "%.f%%", sender.value)
        case 2:
            self.optionTwoLabel.text = String(format: "%.f%%", sender.value)
        case 3:
            self.optionThreeLabel.text = String(format: "%.f%%", sender.value)
        default:
            self.optionThreeLabel.text = ""
        }
    }

}
