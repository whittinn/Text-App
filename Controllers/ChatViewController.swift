//
//  ChatViewController.swift
//  MessangerProject
//
//  Created by Nathaniel Whittington on 2/23/22.
//

import UIKit
import MessageKit



struct Message : MessageType {
    var sender : SenderType
    var messageId: String
    var sentDate: Date
    var kind : MessageKind
    
}

struct Sender : SenderType {
    var photoURL : String
    var senderId: String
    var displayName: String
}


class ChatViewController: MessagesViewController {
private var message = [Message]()
  private let selfSender = Sender(photoURL: "", senderId: "1", displayName: "Joe")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        message.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Hello world")))
        message.append(Message(sender: selfSender, messageId: "2", sentDate: Date(), kind: .text("Hello world")))
        view.backgroundColor = .systemPink
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    

}

extension ChatViewController : MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return message[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return message.count
    }
    
    
    
}
