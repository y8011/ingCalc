//
//  macro.swift
//  ingCalc
//
//  Created by yuka on 2017/12/03.
//  Copyright © 2017年 yuka. All rights reserved.
//

import Foundation

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
