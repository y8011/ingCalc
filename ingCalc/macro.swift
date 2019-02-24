//
//  macro.swift
//  ingCalc
//
//  Created by yuka on 2017/12/03.
//  Copyright © 2017年 yuka. All rights reserved.
//

import Foundation
import UIKit

//-----Admob
//自分で登録して作成したAdMobIDを指定
let AdMobID:String = "ca-app-pub-6416476542651492/1952439259"

//-----Admob Test用
let TEST_DEVICE_ID:String = "7b91a62bf15121d30247bbac787ea68fff941420"


class Constants {
    
    // MARK: List of Constants
    
    static let DEBUG:Bool = false

    static let AdmobTest:Bool = false
    static let SimulatorTest:Bool = false
    
}

extension String {
    func withComma() -> String {
        var value = self
        
        let arrayTheDecimalPoint = value.components(separatedBy: ".")
        
        var upperDividedNumbers : [Character] = []
        var i = 0
        for num in arrayTheDecimalPoint[0].reversed() {
            upperDividedNumbers.insert(num, at: 0)
            i += 1
            if i % 3 == 0
            && i != arrayTheDecimalPoint[0].count
                {
                upperDividedNumbers.insert(",", at: 0)            }
        }
        
        value = String(upperDividedNumbers)
        if arrayTheDecimalPoint.count == 2 {
            value += "." + arrayTheDecimalPoint[1]
        }
        
        return value
    }
    
}

extension UIFont {
    
    /**
     Will return the best font conforming to the descriptor which will fit in the provided bounds.
     */
    static func bestFittingFontSize(for text: String, in bounds: CGRect, fontDescriptor: UIFontDescriptor, additionalAttributes: [NSAttributedString.Key: Any]? = nil) -> CGFloat {
        let constrainingDimension = min(bounds.width, bounds.height)
        let properBounds = CGRect(origin: .zero, size: bounds.size)
        var attributes = additionalAttributes ?? [:]
        
        let infiniteBounds = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
        var bestFontSize: CGFloat = constrainingDimension
        
        for fontSize in stride(from: bestFontSize, through: 0, by: -1) {
            let newFont = UIFont(descriptor: fontDescriptor, size: fontSize)
            attributes[.font] = newFont
            
            let currentFrame = text.boundingRect(with: infiniteBounds, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
            
            if properBounds.contains(currentFrame) {
                bestFontSize = fontSize
                break
            }
        }
        return bestFontSize
    }
    
    static func bestFittingFont(for text: String, in bounds: CGRect, fontDescriptor: UIFontDescriptor, additionalAttributes: [NSAttributedString.Key: Any]? = nil) -> UIFont {
        let bestSize = bestFittingFontSize(for: text, in: bounds, fontDescriptor: fontDescriptor, additionalAttributes: additionalAttributes)
        return UIFont(descriptor: fontDescriptor, size: bestSize)
    }
}

extension UITextField {
    
    /// Will auto resize the contained text to a font size which fits the frames bounds.
    /// Uses the pre-set font to dynamically determine the proper sizing
    func fitTextToBounds() {
        guard let text = text, let currentFont = font else { return }
        
        let bestFittingFont = UIFont.bestFittingFont(for: text, in: bounds, fontDescriptor: currentFont.fontDescriptor, additionalAttributes: basicStringAttributes)
        font = bestFittingFont
    }
    
    private var basicStringAttributes: [NSAttributedString.Key: Any] {
        var attribs = [NSAttributedString.Key: Any]()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = self.textAlignment
        attribs[.paragraphStyle] = paragraphStyle
        
        return attribs
    }
}


extension CalculatorKey {
    func mark() -> String? {
        switch(self) {
        case .multiply:
            return "×"
        case .divide:
            return "÷"
        case .add:
            return "+"
        case .subtract:
            return "-"
        default:
            return nil
        }
    }
}
