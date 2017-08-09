//
//  ViewController.swift
//  Tipster
//
//  Created by Nisarg Mehta on 10/31/15.
//  Copyright © 2015 Open Source. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


// http://stackoverflow.com/questions/3073520/animate-text-change-in-uilabel
extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation:CATransition = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade
        animation.duration = duration
        self.layer.add(animation, forKey: kCATransitionFade)
    }
}

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate
{
    @IBOutlet weak var splitStepper: UIStepper!
    @IBOutlet weak var tipPicker: UIPickerView!
    @IBOutlet weak var splitTotalLabel: UILabel!
    @IBOutlet weak var noOfSplits: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var viewToShowOrHide: UIView!
    @IBOutlet weak var billAmount: UITextField!
    
    var arrayOfTips:[Int] = [];
    var formatter:NumberFormatter = NumberFormatter();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = colorWithHexString("#0B486B")
        viewToShowOrHide.isHidden = true
        self.tipPicker.delegate = self
        self.tipPicker.dataSource = self
        self.billAmount.delegate = self
        arrayOfTips = [10,15,20]
        
        formatter.locale = Locale.current
        formatter.numberStyle = NumberFormatter.Style.currency
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        
        self.billAmount.attributedPlaceholder = NSAttributedString(string:String(format: "%@",formatter.currencySymbol),
                                                                   attributes:[NSForegroundColorAttributeName: colorWithHexString("#79BD9A")])
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ViewController.onAppActive(_:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ViewController.onAppWillResign(_:)),
            name: NSNotification.Name.UIApplicationWillResignActive,
            object: nil)
        setBillAmountText()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.noOfSplits.text = String(format: "%d", Int(self.splitStepper.value))
        let opt1 = UserDefaults.standard.double(forKey: OKSERVICEKEY)
        let opt2 = UserDefaults.standard.double(forKey: GOODSERVICEKEY)
        let opt3 = UserDefaults.standard.double(forKey: AWESOMESERVICEKEY)
        if opt1 != 0 {
            arrayOfTips = [Int(opt1), Int(opt2), Int(opt3)]
            self.tipPicker.reloadAllComponents()
            if self.billAmount.text!.characters.count > 0 {
                CalculateTipChanges()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !self.billAmount.isFirstResponder {
            self.billAmount.becomeFirstResponder()
        }
    }
    
    func setBillAmountText() {
        if let lastDate = UserDefaults.standard.object(forKey: LASTDATE) {
            if Date().timeIntervalSince(lastDate as! Date) < 600 {
                let bill = UserDefaults.standard.object(forKey: LASTAMOUNT) as? String
                self.billAmount.text = bill
                self.viewToShowOrHide.isHidden = false
            }
        }
    }
    
    func onAppActive(_ notification: Notification) {
        setBillAmountText()
        if !self.billAmount.isFirstResponder {
            self.billAmount.becomeFirstResponder()
        }
    }
    
    func onAppWillResign(_ notification: Notification) {
        // save date and value
        if self.billAmount.text?.characters.count > 0 {
            UserDefaults.standard.set(Date(), forKey: LASTDATE)
            UserDefaults.standard.set(self.billAmount.text, forKey: LASTAMOUNT)
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func textDidChange(_ sender: AnyObject) {
        if billAmount.text?.characters.count > 0 {
            if self.viewToShowOrHide.isHidden {
                self.viewToShowOrHide.alpha = 0
                self.viewToShowOrHide.isHidden = false
                UIView.animate(withDuration: 0.5, animations: {
                    self.viewToShowOrHide.alpha = 1
                })
            }
            CalculateTipChanges()
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.viewToShowOrHide.alpha = 0
            }, completion: {
                (value: Bool) in
                self.viewToShowOrHide.isHidden = value
            })
        }
    }
    
    @IBAction func stepperValueChanged(_ sender: AnyObject) {
        self.noOfSplits.text = String(format: "%d", Int(self.splitStepper.value))
        CalculateSplit(Float(Int(self.billAmount.text!)!) + Float(Int(self.billAmount.text!)! * arrayOfTips[self.tipPicker.selectedRow(inComponent: 0)]) / 100)
    }
    
    @IBAction func onTap(_ sender: AnyObject) {
        if self.billAmount.isFirstResponder && self.billAmount.text?.characters.count > 0 {
            self.billAmount.resignFirstResponder()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if (range.length + range.location > textField.text?.characters.count )
        {
            return false;
        }
        let newLength = (textField.text?.characters.count)! + string.characters.count - range.length
        return newLength <= 10
    }
    
    // MARK: - PickerView
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30.0;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3;
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(format: "%d%%", arrayOfTips[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        CalculateTipChanges()
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: String(format: "%d%%", arrayOfTips[row]), attributes: [NSForegroundColorAttributeName:colorWithHexString("#A8DBA8")])
    }
    
    // MARK: - Calculations
    
    func CalculateTipChanges() {
        let tip = arrayOfTips[self.tipPicker.selectedRow(inComponent: 0)]
        let tipAmount:Float = Float(Int(self.billAmount.text!)! * tip) / 100
        self.tipLabel.fadeTransition(0.4)
        //        self.tipLabel.text = String(format: "%@%.2f",formatter.currencySymbol, tipAmount)
        self.tipLabel.text = formatter.string(from: NSNumber(value: tipAmount))
        let totalAmount:Float = Float(Int(self.billAmount.text!)!) + tipAmount
        self.totalLabel.fadeTransition(0.4)
        self.totalLabel.text = formatter.string(from: NSNumber(value:totalAmount))
        CalculateSplit(totalAmount)
    }
    
    func CalculateSplit(_ total: Float) {
        let noOfSplits = Int(self.noOfSplits.text!)!
        self.splitTotalLabel.fadeTransition(0.4)
        if noOfSplits == 1 {
            self.splitTotalLabel.text = String(format:"You Pay: %@",formatter.string(from: NSNumber(value:total))!)
        } else {
            self.splitTotalLabel.text = String(format: "Per person: %@",formatter.string(from: NSNumber(value: total / Float(noOfSplits)))!)
        }
    }
    
    func colorWithHexString (_ hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substring(from: 1)
        }
        
        if (cString.characters.count != 6) {
            return UIColor.gray
        }
        
        let rString = (cString as NSString).substring(to: 2)
        let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
}

