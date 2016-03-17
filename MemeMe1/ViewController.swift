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
		
		initTextField(topText, placeholder: "TOP TEXT")
		initTextField(bottomText, placeholder: "BOTTOM TEXT")
		
	}
	
	
	func initTextField(textField: UITextField, placeholder: String){
		
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
		
		textField.adjustsFontSizeToFitWidth = true
		textField.minimumFontSize = 0
		textField.defaultTextAttributes = strokeTextAttributes
		textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: placeholderStrokeTextAttributes)
		textField.delegate = self
		
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
		doCancelReset()
	}
	
	func doCancelReset(){
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
		openCameraOrImageSelector(.Camera)
	}
	
	@IBAction func openImageSelector(){
		openCameraOrImageSelector(.PhotoLibrary)
	}
	
	func openCameraOrImageSelector(type:UIImagePickerControllerSourceType){
		
		imageSelector.allowsEditing = true
		imageSelector.sourceType = type
		
		presentViewController(imageSelector, animated: true, completion: nil)
	}
	
	@IBAction func share(){
		
		topText.resignFirstResponder()
		bottomText.resignFirstResponder()
		
		
		// paramters are passed to MemeModel, which constructs the memed image
		let memedImage = generateMemedImage()
		
		// launch activity view controller to share memed image
		let aVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
		
		aVC.completionWithItemsHandler = {activityType, completed, returnedItems, activityError in
			if(completed){
				_ = MemeModel(image: self.imageSelected.image!, topText: self.topText.attributedText!.string, bottomText: self.bottomText.attributedText!.string, memeImage:  memedImage)
			}
		}
		
		self.presentViewController(aVC, animated: true, completion: nil)
	}
	
	
	func generateMemedImage() -> UIImage{
		
		let localImage = imageSelected.image!
		let bottomAttrText = bottomText.attributedText!
		let topAttrText = topText.attributedText!
		
		var memeImage: UIImage
		
		if(topText.attributedText!.string.characters.count == 0 && bottomText.attributedText!.string.characters.count == 0){
			return localImage
		}
		
		
		let range = NSMakeRange(0, 0)
		
		let scale:CGFloat = localImage.size.width / imageWidth
		
		let mutPar = NSMutableParagraphStyle()
		mutPar.alignment = .Center
		
		
		
		// idea for drawing in the image from http://stackoverflow.com/questions/25302799/add-text-on-uiimage
		
		UIGraphicsBeginImageContext(CGSize(width: localImage.size.width, height: localImage.size.height))
		
		localImage.drawInRect(CGRectMake(0, 0, localImage.size.width, localImage.size.height))
		
		
		if(topAttrText.string.characters.count > 0){
			
			let topTextNew = topAttrText.mutableCopy()
			let fontTop:UIFont = topAttrText.attribute(NSFontAttributeName, atIndex: NSMaxRange(range), effectiveRange: nil) as! UIFont
			let fontTopSize:CGFloat = fontTop.pointSize
			
			
			
			let strokeTextTopAttributes: [String: AnyObject] = [
				NSStrokeColorAttributeName : UIColor.blackColor(),
				NSForegroundColorAttributeName : UIColor.whiteColor(),
				NSStrokeWidthAttributeName : -2.0,
				NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: fontTopSize*scale)!,
				NSParagraphStyleAttributeName: mutPar
			]
			
			topTextNew.setAttributes(strokeTextTopAttributes, range: NSMakeRange(0, topTextNew.length))
			
			
			// draw top text
			let rectTop = CGRectMake(10*scale, 20*scale, localImage.size.width-(20*scale), 35*scale)
			topTextNew.drawInRect(rectTop)
		}
		
		
		if(bottomAttrText.string.characters.count > 0){
			let bottomTextNew = bottomAttrText.mutableCopy()
			let fontBottom:UIFont = bottomAttrText.attribute(NSFontAttributeName, atIndex: NSMaxRange(range), effectiveRange: nil) as! UIFont
			let fontBottomSize:CGFloat = fontBottom.pointSize
			
			
			let strokeTextBottomAttributes: [String: AnyObject] = [
				NSStrokeColorAttributeName : UIColor.blackColor(),
				NSForegroundColorAttributeName : UIColor.whiteColor(),
				NSStrokeWidthAttributeName : -2.0,
				NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: fontBottomSize*scale)!,
				NSParagraphStyleAttributeName: mutPar
			]
			
			bottomTextNew.setAttributes(strokeTextBottomAttributes, range: NSMakeRange(0, bottomTextNew.length))
			
			
			
			// draw bottom text
			let rectBottom = CGRectMake(10*scale, localImage.size.height-20*scale-35*scale, localImage.size.width-(20*scale), 35*scale)
			bottomTextNew.drawInRect(rectBottom)
			
		}
		
		memeImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return memeImage
	}
	
	
	// UIImagePickerControllerDelegate
	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
		doCancelReset()
		
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
			view.bounds.origin.y += viewShiftAmount
		}
	}
	
	
	func keyboardWillDisappear(notification: NSNotification){
		print("keyboard will disappear")
		
		// unshift view if keyboard shifted it
		if(viewShiftAmount > 0){
			view.bounds.origin.y -= viewShiftAmount
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

