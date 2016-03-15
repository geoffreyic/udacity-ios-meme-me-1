//
//  ViewController.swift
//  MemeMe1
//
//  Created by Geoffrey Ching on 2/21/16.
//  Copyright © 2016 Geoffrey Ching. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{
	
	@IBOutlet weak var cameraButton: UIBarButtonItem!
	@IBOutlet weak var imageSelected: UIImageView!
	@IBOutlet weak var instructionText: UILabel!
	@IBOutlet weak var topText: UITextField!
	@IBOutlet weak var bottomText: UITextField!
	@IBOutlet weak var shareButton: UIBarButtonItem!
	
	
	@IBOutlet weak var textTopTopConstraint: NSLayoutConstraint!
	@IBOutlet weak var textTopLeftConstraint: NSLayoutConstraint!
	@IBOutlet weak var textTopRightConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var textBottomLeftConstraint: NSLayoutConstraint!
	@IBOutlet weak var textBottomRightConstraint: NSLayoutConstraint!
	@IBOutlet weak var textBottomBottomConstraint: NSLayoutConstraint!
	
	
	let imageSelector = UIImagePickerController()
	
	// stored for moving the keyboard
	var imageWidth:CGFloat = 0
	var imageHeight:CGFloat = 0
	var imageTopLeftX:CGFloat = 0
	var imageTopLeftY:CGFloat = 0
	
	// keyboard view shift check
	var watchForKeyboard = false
	var viewShiftAmount:CGFloat = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		imageSelector.delegate = self
		
		if(!UIImagePickerController.isSourceTypeAvailable(.Camera)){
			cameraButton.enabled = false
		}
		
		let mutPar = NSMutableParagraphStyle()
		mutPar.alignment = .Center
		
		
		let strokeTextAttributes: [String: AnyObject] = [
			NSStrokeColorAttributeName : UIColor.blackColor(),
			NSForegroundColorAttributeName : UIColor.whiteColor(),
			NSStrokeWidthAttributeName : -2.0,
			NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 26.0)!,
			NSParagraphStyleAttributeName: mutPar
		]
		
		
		let placeholderStrokeTextAttributes: [String: AnyObject] = [
			NSStrokeColorAttributeName : UIColor.whiteColor(),
			NSForegroundColorAttributeName : UIColor.grayColor(),
			NSStrokeWidthAttributeName : -2.0,
			NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 26.0)!,
			NSParagraphStyleAttributeName: mutPar
		]
		
		topText.adjustsFontSizeToFitWidth = true;
		topText.minimumFontSize = 0
		topText.defaultTextAttributes = strokeTextAttributes
		topText.attributedPlaceholder = NSAttributedString(string: "TOP TEXT", attributes: placeholderStrokeTextAttributes)
		topText.delegate = self
		
		bottomText.adjustsFontSizeToFitWidth = true;
		bottomText.minimumFontSize = 0
		bottomText.defaultTextAttributes = strokeTextAttributes
		bottomText.attributedPlaceholder = NSAttributedString(string: "BOTTOM TEXT", attributes: placeholderStrokeTextAttributes)
		bottomText.delegate = self
		
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		// register keyboard listener
		NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillAppear:", name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillDisappear:", name: UIKeyboardWillHideNotification, object: nil)
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	
	@IBAction func cancelReset(sender: AnyObject) {
		if(!imageSelected.hidden){
			imageSelected.hidden = true
			instructionText.hidden = false
			topText.hidden = true
			bottomText.hidden = true
			shareButton.enabled = false
		}
		
		topText.text = ""
		bottomText.text = ""
		
		topText.resignFirstResponder()
		bottomText.resignFirstResponder()
		
	}
	
	
	@IBAction func openCamera(){
		
		imageSelector.allowsEditing = true
		imageSelector.sourceType = .Camera
		
		presentViewController(imageSelector, animated: true, completion: nil)
	}
	
	@IBAction func openImageSelector(){
		
		imageSelector.allowsEditing = true
		imageSelector.sourceType = .PhotoLibrary
		
		presentViewController(imageSelector, animated: true, completion: nil)
	}
	
	@IBAction func share(){
		
		topText.resignFirstResponder()
		bottomText.resignFirstResponder()
		
		
		// paramters are passed to MemeModel, which constructs the memed image
		let memed = MemeModel(image: imageSelected.image!, topText: topText.attributedText!, bottomText: bottomText.attributedText!, width:imageWidth, height:imageHeight)
		
		// launch activity view controller to share memed image
		let aVC = UIActivityViewController(activityItems: [memed.memeImage], applicationActivities: nil)
		
		self.presentViewController(aVC, animated: true, completion: nil)
	}
	
	
	// UIImagePickerControllerDelegate
	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
		imageSelected.image = image
		
		if(imageSelected.hidden){
			imageSelected.hidden = false
			instructionText.hidden = true
			topText.hidden = false
			bottomText.hidden = false
			shareButton.enabled = true
		}
		
		findPositionMoveText()
		
		dismissViewControllerAnimated(true, completion: nil)
	}
	func imagePickerControllerDidCancel(picker: UIImagePickerController) {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	
	
	// idea for detecting actual image position from http://stackoverflow.com/questions/389342/how-to-get-the-size-of-a-scaled-uiimage-in-uiimageview
	func findPositionMoveText(){
		
		let image = imageSelected.image!
		
		let imageRatio = image.size.width / image.size.height;
		
		let viewRatio = imageSelected.frame.size.width / imageSelected.frame.size.height;
		
		
		if(imageRatio < viewRatio){
			let scale = imageSelected.frame.size.height / image.size.height;
			
			imageWidth = scale * image.size.width;
			imageHeight = imageSelected.frame.size.height
			
			imageTopLeftX = (imageSelected.frame.size.width - imageWidth) * 0.5;
			imageTopLeftY = 0
			
			textTopLeftConstraint.constant = imageTopLeftX + 10
			textTopRightConstraint.constant = imageTopLeftX + 10
			textTopTopConstraint.constant = -20
			
			textBottomLeftConstraint.constant = imageTopLeftX + 10
			textBottomRightConstraint.constant = imageTopLeftX + 10
			textBottomBottomConstraint.constant = -20
			
		}else{
			let scale = imageSelected.frame.size.width / image.size.width;
			
			imageWidth = imageSelected.frame.size.width;
			imageHeight = scale * image.size.height;
			
			imageTopLeftX = 0
			imageTopLeftY = (imageSelected.frame.size.height - imageHeight) * 0.5;
			
			textTopLeftConstraint.constant = 10
			textTopRightConstraint.constant = 10
			textTopTopConstraint.constant = -20 - imageTopLeftY
			
			textBottomLeftConstraint.constant = 10
			textBottomRightConstraint.constant = 10
			textBottomBottomConstraint.constant = -20 - imageTopLeftY
			
			
		}
		
		self.view.sendSubviewToBack(imageSelected)
	}


	// catch device rotations
	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		
		coordinator.animateAlongsideTransition(nil) { (UIViewControllerTransitionCoordinatorContext) -> Void in
			if(!self.imageSelected.hidden){
				self.findPositionMoveText()
			}
		}
		
	}
	
	
	// bottom textfield delegate functions
	
	func textFieldDidBeginEditing(textField: UITextField) {
		if(textField.placeholder == "BOTTOM TEXT"){
			print("caught bottom field begin editing")
			watchForKeyboard = true
		}
	}
	func textFieldDidEndEditing(textField: UITextField) {
		if(textField.placeholder == "BOTTOM TEXT"){
			print("caught bottom field end editing")
			watchForKeyboard = false
		}
	}
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	
	// keyboard detection
	
	func keyboardWillAppear(notification: NSNotification){
		if(!watchForKeyboard){
			return
		}
		
		print("keyboard will appear")
		
		
		let kHeight = getKeyboardHeight(notification)
		
		// shift view for keyboard if keyboard is in the way
		if(kHeight > 44+imageTopLeftY){
			viewShiftAmount = kHeight-44-imageTopLeftY
			view.frame.origin.y -= viewShiftAmount
		}
	}
	
	
	func keyboardWillDisappear(notification: NSNotification){
		print("keyboard will disappear")
		
		// unshift view if keyboard shifted it
		if(viewShiftAmount > 0){
			view.frame.origin.y += viewShiftAmount
			viewShiftAmount = 0
		}
		
	}
	
	// from Building MemeMe 1.0 Classroom
	func getKeyboardHeight(notification: NSNotification) -> CGFloat {
		let userInfo = notification.userInfo
		let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
		return keyboardSize.CGRectValue().height
	}
	
	
}

