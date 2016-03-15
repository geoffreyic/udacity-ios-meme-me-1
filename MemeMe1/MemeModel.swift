//
//  MemeModel.swift
//  MemeMe1
//
//  Created by Geoffrey Ching on 2/21/16.
//  Copyright © 2016 Geoffrey Ching. All rights reserved.
//

import Foundation
import UIKit

class MemeModel{
	var image: UIImage!
	var topText: NSAttributedString!
	var bottomText: NSAttributedString!
	var memeImage: UIImage!
	
	init(image: UIImage, topText: NSAttributedString, bottomText: NSAttributedString, width: CGFloat, height: CGFloat){
		self.image = image
		self.topText = topText
		self.bottomText = bottomText
		self.memeImage = image
		
		
		if(topText.string.characters.count == 0 && bottomText.string.characters.count == 0){
			self.memeImage = image
			return
		}
		
		
		let range = NSMakeRange(0, 0)
		
		let scale:CGFloat = image.size.width / width
		
		let mutPar = NSMutableParagraphStyle()
		mutPar.alignment = .Center
		
		
		
		// idea for drawing in the image from http://stackoverflow.com/questions/25302799/add-text-on-uiimage
		
		UIGraphicsBeginImageContext(CGSize(width: image.size.width, height: image.size.height))
		
		image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
		
		
		if(topText.string.characters.count > 0){
			
			let topTextNew = topText.mutableCopy()
			let fontTop:UIFont = topText.attribute(NSFontAttributeName, atIndex: NSMaxRange(range), effectiveRange: nil) as! UIFont
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
			let rectTop = CGRectMake(10*scale, 20*scale, image.size.width-(20*scale), 35*scale)
			topTextNew.drawInRect(rectTop)
		}
		
		
		if(bottomText.string.characters.count > 0){
			let bottomTextNew = bottomText.mutableCopy()
			let fontBottom:UIFont = bottomText.attribute(NSFontAttributeName, atIndex: NSMaxRange(range), effectiveRange: nil) as! UIFont
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
			let rectBottom = CGRectMake(10*scale, image.size.height-20*scale-35*scale, image.size.width-(20*scale), 35*scale)
			bottomTextNew.drawInRect(rectBottom)
		
		}
		
		self.memeImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		
	}
}