//
//  ChatViewController.swift
//  ChatApp
//
//  Created by 山本ののか on 2020/04/27.
//  Copyright © 2020 Nonoka Yamamoto. All rights reserved.
//

import UIKit
import ChameleonFramework
import Firebase

class ChatViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    //スクリーンサイズ
    let screenSize = UIScreen.main.bounds.size
    var chatArray = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        messageTextField.delegate = self
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "Cell")
        tableView.rowHeight = UITableView.automaticDimension
        //可変
        tableView.estimatedRowHeight = 75
        //キーボード
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
         //Firebaseからデータをfetchしてくる(取得)
        fetchChatData()
        tableView.separatorStyle = .none
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        
        let keyboardHeight = ((notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as Any) as AnyObject).cgRectValue.height
        messageTextField.frame.origin.y = screenSize.height - keyboardHeight - messageTextField.frame.height
        sendButton.frame.origin.y = screenSize.height - keyboardHeight - sendButton.frame.height
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        
        messageTextField.frame.origin.y = screenSize.height - messageTextField.frame.height
        guard let rect = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {return}
        UIView.animate(withDuration: duration) {
            let transform = CGAffineTransform(translationX: 0, y: 0)
            self.view.transform = transform
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        messageTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //メッセージの数
        return chatArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell
        cell.messageLabel.text = chatArray[indexPath.row].message
        cell.userNameLabel.text = chatArray[indexPath.row].sender
        cell.iconImageView.image = UIImage(named: "dogAvatarImage")
    if cell.userNameLabel.text == Auth.auth().currentUser?.email as! String {
        cell.messageLabel.backgroundColor = UIColor.flatGreen()
        cell.messageLabel.layer.cornerRadius = 20
        cell.messageLabel.layer.masksToBounds = true
    } else {
        cell.messageLabel.backgroundColor = UIColor.flatBlue()
        cell.messageLabel.layer.cornerRadius = 20
        cell.messageLabel.layer.masksToBounds = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100
    }
    
    @IBAction func sendAction(_ sender: Any) {
        
        messageTextField.endEditing(true)
        messageTextField.isEnabled = false
        sendButton.isEnabled = false
        if messageTextField.text!.count > 15 {
            print("15文字以上です。")
            return
        }
        let chatDB = Database.database().reference().child("chats")
        //キーバリュー型で内容を送信(Dictionary型
        let messageInfo = ["sender": Auth.auth().currentUser?.email, "message": messageTextField.text!]
        //chatDBに入れる
        chatDB.childByAutoId().setValue(messageInfo) { (error, result) in
            if error != nil {
                print("error")
            } else {
                print("送信完了")
                self.messageTextField.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextField.text = ""
            }
        }
    }
    
    //引っ張ってくる
    func fetchChatData() {
        
        //どこから引っ張ってくるのか
        let fetchDataRef = Database.database().reference().child("chats")
        //新しく更新があった時だけ取得したい
        fetchDataRef.observe(.childAdded) { (snapShot) in
            let snapShotData = snapShot.value as! AnyObject
            let text = snapShotData.value(forKey: "message")
            let sender = snapShotData.value(forKey: "sender")
            let message = Message()
            message.message = text as! String
            message.sender = sender as! String
            self.chatArray.append(message)
            self.tableView.reloadData()
        }
    }
}
