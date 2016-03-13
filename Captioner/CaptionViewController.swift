//
//  CaptionViewController.swift
//  Captioner
//
//  Created by Daylen Yang on 3/2/16.
//  Copyright © 2016 Daylen Yang. All rights reserved.
//

import UIKit
import Alamofire
import JSQMessagesViewController

let uploadEndpoint = "http://durian8.banatao.berkeley.edu:5000/upload"

class CaptionViewController: JSQMessagesViewController {
    
    var image : UIImage?
    var messages = [JSQMessage]()
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Chat"
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        setupBubbles()
        uploadImage()
    }
    
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleGreenColor())
    }

    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
        messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
            return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        self.messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
        self.finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        let alert = UIAlertController(title: "Not supported", message: nil, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    
    func correctlyOrientedImage(image: UIImage) -> UIImage {
        if image.imageOrientation == UIImageOrientation.Up {
            return image
        }
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
        let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return normalizedImage;
    }
    
    func uploadImage() {
        if let image = image {
            self.messages.append(JSQMessage(senderId: "0", displayName: "Me", media: JSQPhotoMediaItem(image: image)))
            self.messages.append(JSQMessage(senderId: "1", displayName: "Captioner", text: "Captioning..."))
            Alamofire.upload(.POST, uploadEndpoint, multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(data: UIImageJPEGRepresentation(self.correctlyOrientedImage(image), 0.8)!, name: "file", fileName: "chess.jpg", mimeType: "image/jpeg")
                }, encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.progress { _, written, total in
                            
                        }
                        upload.responseJSON { response in
                            if let error = response.result.error {
                                dispatch_async(dispatch_get_main_queue()) {
                                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                                    self.presentViewController(alert, animated: true, completion: nil)
                                }
                            } else if let JSON = response.result.value {
                                if let error = JSON["error"] as? String {
                                    dispatch_async(dispatch_get_main_queue()) {
                                        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .Alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                                        self.presentViewController(alert, animated: true, completion: nil)
                                    }
                                } else if let caption = JSON["caption"] as? String {
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.messages.append(JSQMessage(senderId: "1", displayName: "Captioner", text: caption))
                                        self.finishReceivingMessageAnimated(true)
                                    }
                                }
                            }
                        }
                    case .Failure(let encodingError):
                        print(encodingError)
                    }
            })
        } else {
            print("no image")
        }
    }
    
}
