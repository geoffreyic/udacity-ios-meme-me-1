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
	var topText: String!
	var bottomText: String!
	var memeImage: UIImage!
	
	init(image: UIImage, topText: NSAttributedString, bottomText: NSAttributedString, width: CGFloat, height: CGFloat){
		self.image = image
		self.topText = topText.string
		self.bottomText = bottomText.string
		self.memeImage = image
		
		// idea from http://stackoverflow.com/questions/25302799/add-text-on-uiimage
		
		UIGraphicsBeginImageContext(CGSize(width: width, height: height))
		
		image.drawInRect(CGRectMake(0, 0, width, height))
		
		let rectTop = CGRectMake(10, 20, width-20, 35)
		
		topText.drawInRect(rectTop)
		
		self.memeImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
	}
}