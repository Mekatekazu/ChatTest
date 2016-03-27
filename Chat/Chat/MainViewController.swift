//
//  ViewController.swift
//  Chat
//
//  Created by Александр Соломатов on 25.03.16.
//  Copyright © 2016 Александр Соломатов. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITextFieldDelegate, PassTouchesScrollViewDelegate {
    
    @IBOutlet var scrollView: PassTouchesScrollView!
    @IBOutlet var nameField: UITextField!
    
    var aField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.translucent = false
        self.title = "Chat"
        
        scrollView.frame = UIScreen.mainScreen().bounds
        scrollView.delegatePass = self
        scrollView.clipsToBounds = true
        
        nameField.delegate = self

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification:NSNotification) {
        let userInfo = notification.userInfo!
        
        if let kbsize = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue
        {
            var contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbsize.height, 0.0);
            
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
            var rect = self.view.frame
            rect.size.height -= kbsize.height
            
            let point = self.aField.convertPoint(aField.frame.origin, toView: self.scrollView)
            
            if(aField != nil && point.y>=rect.height ){
                let scrollPoint = CGPointMake(0.0, point.y-kbsize.height);
                self.scrollView.setContentOffset(scrollPoint, animated:false)
            } else {
                contentInsets = UIEdgeInsetsZero
                self.scrollView.contentInset = contentInsets
                self.scrollView.scrollIndicatorInsets = contentInsets
                
                
                self.scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
            }
        }
    }
    
    func keyboardWillHide(notification:NSNotification) {
        let contentInsets = UIEdgeInsetsZero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        self.scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        aField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        aField = nil
    }
    
    func touchScrollMoved() {
        print("touch moved")
    }
    
    func touchScrollBegan() {
        self.view.endEditing(true)
        self.scrollView.endEditing(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "showChat") {
            let viewController = segue.destinationViewController as! ChatViewController
            viewController.nickname = nameField.text!
            self.view.endEditing(true)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

