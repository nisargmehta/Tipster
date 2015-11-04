//
//  ViewController.swift
//  Tipster
//
//  Created by Nisarg Mehta on 10/31/15.
//  Copyright © 2015 Open Source. All rights reserved.
//

import UIKit

// http://stackoverflow.com/questions/3073520/animate-text-change-in-uilabel
extension UIView {
    func fadeTransition(duration:CFTimeInterval) {
        let animation:CATransition = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade
        animation.duration = duration
        self.layer.addAnimation(animation, forKey: kCATransitionFade)
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
    var formatter:NSNumberFormatter = NSNumberFormatter();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = colorWithHexString("#0B486B")
        viewToShowOrHide.hidden = true
        self.tipPicker.delegate = self
        self.tipPicker.dataSource = self
        self.billAmount.delegate = self
        arrayOfTips = [10,15,20]
        
        formatter.locale = NSLocale.currentLocale()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        
        self.billAmount.attributedPlaceholder = NSAttributedString(string:String(format: "%@",formatter.currencySymbol),
            attributes:[NSForegroundColorAttributeName: colorWithHexString("#79BD9A")])
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "onAppActive:",
            name: UIApplicationDidBecomeActiveNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "onAppWillResign:",
            name: UIApplicationWillTerminateNotification,
            object: nil)
        setBillAmountText()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(animated: Bool) {
        if !self.billAmount.isFirstResponder() {
            self.billAmount.becomeFirstResponder()
        }
        self.noOfSplits.text = String(format: "%d", Int(self.splitStepper.value))
        let opt1 = NSUserDefaults.standardUserDefaults().doubleForKey(OKSERVICEKEY)
        let opt2 = NSUserDefaults.standardUserDefaults().doubleForKey(GOODSERVICEKEY)
        let opt3 = NSUserDefaults.standardUserDefaults().doubleForKey(AWESOMESERVICEKEY)
        if opt1 != 0 {
            arrayOfTips = [Int(opt1), Int(opt2), Int(opt3)]
            self.tipPicker.reloadAllComponents()
            if self.billAmount.text?.characters.count > 0 {
                CalculateTipChanges()
            }
        }
    }

    func setBillAmountText() {
        if let lastDate = NSUserDefaults.standardUserDefaults().objectForKey(LASTDATE) {
            if NSDate().timeIntervalSinceDate(lastDate as! NSDate) < 600 {
                self.billAmount.text = NSUserDefaults.standardUserDefaults().objectForKey(LASTAMOUNT) as? String
                self.viewToShowOrHide.hidden = false
            }
        }
    }
    
    func onAppActive(notification: NSNotification) {
        setBillAmountText()
    }
    
    func onAppWillResign(notification: NSNotification) {
        // save date and value
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: LASTDATE)
        NSUserDefaults.standardUserDefaults().setObject(self.billAmount.text, forKey: LASTAMOUNT)
    }
    
    // MARK: - IBActions
    
    @IBAction func textDidChange(sender: AnyObject) {
        if billAmount.text?.characters.count > 0 {
            if self.viewToShowOrHide.hidden {
                self.viewToShowOrHide.alpha = 0
                self.viewToShowOrHide.hidden = false
                UIView.animateWithDuration(0.5, animations: {
                    self.viewToShowOrHide.alpha = 1
                })
            }
            CalculateTipChanges()
        } else {
            UIView.animateWithDuration(0.5, animations: {
                self.viewToShowOrHide.alpha = 0
                }, completion: {
                    (value: Bool) in
                    self.viewToShowOrHide.hidden = value
            })
        }
    }
    
    @IBAction func stepperValueChanged(sender: AnyObject) {
        self.noOfSplits.text = String(format: "%d", Int(self.splitStepper.value))
        CalculateSplit(Float(Int(self.billAmount.text!)!) + Float(Int(self.billAmount.text!)! * arrayOfTips[self.tipPicker.selectedRowInComponent(0)]) / 100)
    }
    
    @IBAction func onTap(sender: AnyObject) {
        if self.billAmount.isFirstResponder() && self.billAmount.text?.characters.count > 0 {
            self.billAmount.resignFirstResponder()
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        if (range.length + range.location > textField.text?.characters.count )
        {
            return false;
        }
        let newLength = (textField.text?.characters.count)! + string.characters.count - range.length
        return newLength <= 10
    }
    
    // MARK: - PickerView
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30.0;
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3;
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(format: "%d%%", arrayOfTips[row])
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        CalculateTipChanges()
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: String(format: "%d%%", arrayOfTips[row]), attributes: [NSForegroundColorAttributeName:colorWithHexString("#A8DBA8")])
    }
    
    // MARK: - Calculations
    
    func CalculateTipChanges() {
        let tip = arrayOfTips[self.tipPicker.selectedRowInComponent(0)]
        let tipAmount:Float = Float(Int(self.billAmount.text!)! * tip) / 100
        self.tipLabel.fadeTransition(0.4)
//        self.tipLabel.text = String(format: "%@%.2f",formatter.currencySymbol, tipAmount)
        self.tipLabel.text = formatter.stringFromNumber(tipAmount)
        let totalAmount:Float = Float(Int(self.billAmount.text!)!) + tipAmount
        self.totalLabel.fadeTransition(0.4)
        self.totalLabel.text = formatter.stringFromNumber(totalAmount)
        CalculateSplit(totalAmount)
    }
    
    func CalculateSplit(total: Float) {
        let noOfSplits = Int(self.noOfSplits.text!)!
        self.splitTotalLabel.fadeTransition(0.4)
        if noOfSplits == 1 {
            self.splitTotalLabel.text = String(format:"You Pay: %@",formatter.stringFromNumber(total)!)
        } else {
            self.splitTotalLabel.text = String(format: "Per person: %@",formatter.stringFromNumber(total / Float(noOfSplits))!)
        }
    }
    
    func colorWithHexString (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }
        
        if (cString.characters.count != 6) {
            return UIColor.grayColor()
        }
        
        let rString = (cString as NSString).substringToIndex(2)
        let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
}

