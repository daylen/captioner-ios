//
//  ViewController.swift
//  Captioner
//
//  Created by Daylen Yang on 3/1/16.
//  Copyright © 2016 Daylen Yang. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func cameraButtonPressed(sender: UIButton) {
        if !UIImagePickerController.isSourceTypeAvailable(.Camera) {
            print("camera not available")
            return
        }
        let cameraUI = UIImagePickerController()
        cameraUI.sourceType = .Camera
        cameraUI.delegate = self
        cameraUI.allowsEditing = false
        self.presentViewController(cameraUI, animated: true, completion: nil)
    }
    
    @IBAction func photoLibraryButtonPressed(sender: UIButton) {
        let pickerUI = UIImagePickerController()
        pickerUI.sourceType = .SavedPhotosAlbum
        pickerUI.delegate = self
        pickerUI.allowsEditing = false
        self.presentViewController(pickerUI, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.dismissViewControllerAnimated(true, completion: nil)
        let vc = CaptionViewController()
        vc.senderId = "0"
        vc.senderDisplayName = "Me"
        vc.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
}

