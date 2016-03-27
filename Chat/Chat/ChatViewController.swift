//
//  ChatViewController.swift
//  Chat
//
//  Created by Александр Соломатов on 25.03.16.
//  Copyright © 2016 Александр Соломатов. All rights reserved.
//

import UIKit
//import SocketRocket

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PassTouchesScrollViewDelegate, SRWebSocketDelegate, UITextFieldDelegate {
    
    var nickname: String!
    var msgData = NSMutableArray()
    var aField: UITextField!
    var webSocket = SRWebSocket()
    
    @IBOutlet var scroll: PassTouchesScrollView!
    
    @IBOutlet var msgTable: UITableView!
    @IBOutlet var message: UITextField!
    @IBAction func msgSend(sender: UIButton) {
        self.sendMessage()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.translucent = false
        
        scroll.frame = UIScreen.mainScreen().bounds
        scroll.delegatePass = self
        scroll.clipsToBounds = true
        
        message.delegate = self
        
        msgTable.transform = CGAffineTransformMakeScale(1, -1)
        
        let tblView =  UIView(frame: CGRectZero)
        msgTable.tableFooterView = tblView
        msgTable.tableFooterView!.hidden = true
        
        msgTable.estimatedRowHeight = 43.0
        msgTable.rowHeight = UITableViewAutomaticDimension
        
        msgTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

        connectWebSocket()
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.webSocket.send("\(nickname) left chat")
    }
    
    func connectWebSocket(){
        self.webSocket.delegate = self
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        let urlString = "http://kraken-test-socksjs.herokuapp.com/echo/websocket"
        let newWebSocket = SRWebSocket(URL: NSURL(string: urlString))
        newWebSocket.delegate = self
        
        newWebSocket.open()
        self.title = "Opening Connection..."
    }
    
    func webSocketDidOpen(newWebSocket: SRWebSocket!) {
        webSocket = newWebSocket
        self.webSocket.send("\(nickname) joined chat...")
        self.title = "Connected"
    }
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        connectWebSocket()
        self.title = "Failed"
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceivePong pongPayload: NSData!) {
        //
    }
    
    func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        connectWebSocket()
        self.title = "Failed"
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        //msgData.addObject(message)
        msgData.insertObject(message, atIndex: 0)
        self.msgTable.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0) ], withRowAnimation: .Top)
        msgTable.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top,
                                         animated: true)
    }
    
    func sendMessage(){
        print(message.text!)
        if message.text!.characters.count > 0 {
            self.webSocket.send("\(nickname): \(message.text!)")
            message.text = ""
            message.resignFirstResponder()
        }
    }
    
    func keyboardWillShow(notification:NSNotification) {
        let userInfo = notification.userInfo!
        
        if let kbsize = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue
        {
            var contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbsize.height, 0.0);
            
            self.scroll.contentInset = contentInsets
            self.scroll.scrollIndicatorInsets = contentInsets
            
            var rect = self.view.frame
            rect.size.height -= kbsize.height
            
            if(aField != nil && aField!.frame.origin.y>=rect.height ){
                let scrollPoint = CGPointMake(0.0, kbsize.height);
                self.scroll.setContentOffset(scrollPoint, animated:false)
            } else {
                contentInsets = UIEdgeInsetsZero
                self.scroll.contentInset = contentInsets
                self.scroll.scrollIndicatorInsets = contentInsets
                
                
                self.scroll.setContentOffset(CGPointMake(0, 0), animated: true)
            }
        }
    }
    
    func keyboardWillHide(notification:NSNotification) {
        let contentInsets = UIEdgeInsetsZero
        self.scroll.contentInset = contentInsets
        self.scroll.scrollIndicatorInsets = contentInsets
        
        self.scroll.setContentOffset(CGPointMake(0, 0), animated: true)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        aField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        aField = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return msgData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell.transform = CGAffineTransformMakeScale(1, -1)
        
        cell.textLabel!.numberOfLines = 0
        cell.textLabel!.text = msgData.objectAtIndex(indexPath.row) as? String
        cell.textLabel!.sizeToFit()
        
        
        return cell
    }
    
    func touchScrollMoved() {
        print("touch moved")
    }
    
    func touchScrollBegan() {
        self.view.endEditing(true)
        self.msgTable.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.sendMessage()
        textField.resignFirstResponder()
        return true
    }

}
