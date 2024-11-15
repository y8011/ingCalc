//
//  CalculatorKeyboard.swift
//  CalculatorKeyboard
//
//  Created by Guilherme Moura on 8/15/15.
//  Copyright (c) 2015 Reefactor, Inc. All rights reserved.
//

import UIKit


public var btn4cnt:Int = -1  //okayu四則演算が連続で呼ばれているかの確認用

public protocol CalculatorDelegate: AnyObject {
    func calculator(_ calculator: CalculatorKeyboard, didChangeValue value: String, KeyType:Int)
    
    func confirmZero(_ op:CalculatorKey?)
}

public enum CalculatorKey: Int {
    case zero = 1
    case one
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine
    case decimal
    case clear
    case delete
    case multiply
    case divide
    case subtract
    case add
    case equal
}

open class CalculatorKeyboard: UIView {
    open weak var delegate: CalculatorDelegate?
    open var numbersBackgroundColor = UIColor(white: 0.97, alpha: 1.0) {

        didSet {
            adjustLayout()
        }
    }
    open var numbersTextColor = UIColor.black {
        didSet {
            adjustLayout()
        }
    }
    open var operationsBackgroundColor = UIColor(white: 0.75, alpha: 1.0) {
        didSet {
            adjustLayout()
        }
    }
    open var operationsTextColor = UIColor.white {
        didSet {
            adjustLayout()
        }
    }
    open var equalBackgroundColor = UIColor(red:0.96, green:0.5, blue:0, alpha:1) {
        didSet {
            adjustLayout()
        }
    }
    open var equalTextColor = UIColor.white {
        didSet {
            adjustLayout()
        }
    }
    
    open var showDecimal = true {
        didSet {
            processor.automaticDecimal = !showDecimal
            adjustLayout()
        }
    }
    
    var view: UIView!
    fileprivate var processor = CalculatorProcessor()

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXib()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        adjustLayout()
        adjustForSafeArea()
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        adjustForSafeArea()
    }
    
    fileprivate func loadXib() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        adjustLayout()
        adjustForSafeArea()
        addSubview(view)
    }
    
    fileprivate func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CalculatorKeyboard", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    fileprivate func adjustLayout() {
        for i in 1...CalculatorKey.decimal.rawValue {
            if let button = self.view.viewWithTag(i) as? UIButton {
                button.tintColor = numbersBackgroundColor
                button.setTitleColor(numbersTextColor, for: UIControl.State())
                //okayu
                button.titleLabel?.font.withSize(20.0)
            }
        }
        
        for i in CalculatorKey.clear.rawValue...CalculatorKey.add.rawValue {
            if let button = self.view.viewWithTag(i) as? UIButton {
                button.tintColor = operationsBackgroundColor
                button.setTitleColor(operationsTextColor, for: UIControl.State())
                button.tintColor = operationsTextColor
            }
        }
        
        if let button = self.view.viewWithTag(CalculatorKey.equal.rawValue) as? UIButton {
            button.tintColor = equalBackgroundColor
            button.setTitleColor(equalTextColor, for: UIControl.State())
        }
        layoutIfNeeded()
    }
    
    private func adjustForSafeArea() {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0
        
        // キーボードの高さを調整
        frame.size.height += bottomPadding
        
        // その他のボタンの位置も必要に応じて調整
        for i in 1...CalculatorKey.equal.rawValue {
            if let button = self.view.viewWithTag(i) as? UIButton {
                var frame = button.frame
                frame.origin.y -= bottomPadding
                button.frame = frame
            }
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        switch (sender.tag) {
        case (CalculatorKey.zero.rawValue)...(CalculatorKey.nine.rawValue):
            btn4cnt = 0
            let output = processor.storeOperand(sender.tag-1)
            delegate?.calculator(self, didChangeValue: output, KeyType: sender.tag)
        case CalculatorKey.decimal.rawValue:
            btn4cnt = 0
            let output = processor.addDecimal()
            delegate?.calculator(self, didChangeValue: output, KeyType: sender.tag)
        case CalculatorKey.clear.rawValue:
            btn4cnt = 0
            let output = processor.clearAll()
            delegate?.calculator(self, didChangeValue: output, KeyType: sender.tag)
        case CalculatorKey.delete.rawValue:
            let output = processor.deleteLastDigit()
            delegate?.calculator(self, didChangeValue: output, KeyType: sender.tag)
        case (CalculatorKey.multiply.rawValue)...(CalculatorKey.add.rawValue):
            btn4cnt += 1
            let output = processor.storeOperator(sender.tag)
            delegate?.calculator(self, didChangeValue: output, KeyType: sender.tag)
        case CalculatorKey.equal.rawValue:
            if processor.currentOperand == "0" {
                delegate?.confirmZero(processor.storedOperator)
            }
            else {
                finalCalc()
            }
        default:
            break
        }
    }
    
    func finalCalc() {
        let output = processor.computeFinalValue()
        delegate?.calculator(self, didChangeValue: output, KeyType: CalculatorKey.equal.rawValue)
        btn4cnt = 0  //ingCalc側の計算の都合上、delegateの後に移動
    }
}
