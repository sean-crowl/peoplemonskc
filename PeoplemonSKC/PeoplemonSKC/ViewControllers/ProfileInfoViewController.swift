//
//  ProfileInfoViewController.swift
//  PeoplemonSKC
//
//  Created by Sean Crowl on 11/8/16.
//  Copyright © 2016 Interapt. All rights reserved.
//

import UIKit
import MBProgressHUD

class ProfileInfoViewController: UIViewController {
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var newNameTextField: UITextField!
    @IBOutlet weak var avatarView: UIImageView!
    
    var gestureRecognizer: UITapGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = UserStore.shared.user {
            fullNameLabel.text = user.fullName
            emailLabel.text = user.email
            
            if let image = Utils.imageFromString(imageString: user.avatar) {
                avatarView.image = Utils.imageFromString(imageString: user.avatar)
            } else {
                avatarView.image = #imageLiteral(resourceName: "question-mark")
            }
            
            // Do any additional setup after loading the view.
        }
    }
    
    func addGestureRecognizer() {
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewImage))
        avatarView.addGestureRecognizer(gestureRecognizer)
    }
    
    func viewImage() {
        if let image = avatarView.image {
            UserStore.shared.selectedImage = image
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageNavController")
            present(viewController, animated: true, completion: nil)
        }
    }
    
    fileprivate func showPicker(_ type: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = type
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: - IBActions

    @IBAction func addAvatarClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Picture", message: "Choose a picture type", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            self.showPicker(.camera)
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            self.showPicker(.photoLibrary)
        }))
        present(alert, animated: true, completion: nil)
    }
    

    @IBAction func saveClicked(_ sender: Any) {
        let name = newNameTextField.text
        
        let resizedImage = Utils.resizeImage(image: avatarView.image!, maxSize: Constants.avatarSize)
        let imageString = Utils.stringFromImage(image: resizedImage)
        
        let user = User(fullName: name!, avatar: imageString)
        
        MBProgressHUD.showAdded(to: view, animated: true)
        WebServices.shared.postObject(user) { (updatedUser, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let error = error {
                self.present(Utils.createAlert(title: "Error", message: error), animated: true, completion: nil)
            } else {
                UserStore.shared.user?.fullName = name
                UserStore.shared.user?.avatar = imageString
            }
        }
    }
}


extension ProfileInfoViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            let maxSize: CGFloat = 512
            let scale = maxSize / image.size.width
            let newHeight = image.size.height * scale
            
            UIGraphicsBeginImageContext(CGSize(width: maxSize, height: newHeight))
            image.draw(in: CGRect(x: 0, y: 0, width: maxSize, height: newHeight))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            avatarView.image = resizedImage
            
            avatarView.isHidden = false
            if gestureRecognizer != nil {
                avatarView.removeGestureRecognizer(gestureRecognizer)
            }
            addGestureRecognizer()
            
        }
    }
}
