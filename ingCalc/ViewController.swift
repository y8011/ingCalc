//
//  ViewController.swift
//  ingCalc
//
//  Created by yuka on 16/11/2017.
//  Copyright © 2017 yuka. All rights reserved.
//
//TODO: デザインは高さ固定、横はオートで伸びる方が良い
// fontとのバランスを考えると横長のアイテムは↑のように考える方が良い

import UIKit
import Photos               // 写真用
import CoreData
import AVFoundation
import AppTrackingTransparency
import AdSupport
import FirebaseAnalytics
import GoogleMobileAds

var iphoneType:String = ""
var widthOfScreen:CGFloat = 0

class ViewController: UIViewController
, CalculatorDelegate
, UIImagePickerControllerDelegate
, UINavigationControllerDelegate
, UIScrollViewDelegate
{

    @IBOutlet weak var inputText: UITextField!
    //@IBOutlet weak var displayImageView: UIImageView!
    var displayImageView: UIImageView = UIImageView()
    @IBOutlet weak var myScrollView: UIScrollView!
    
    //演算記号のラベル
    @IBOutlet weak var plusLabel: UILabel!
    @IBOutlet weak var minusLabel: UILabel!
    @IBOutlet weak var multiplyLabel: UILabel!
    @IBOutlet weak var divideLabel: UILabel!

    
    @IBOutlet weak var cameraBarButton: UIBarButtonItem!
    
    // 計算機
    var keyboard:CalculatorKeyboard = CalculatorKeyboard()
    var resultText:String = ""
    var suuji:String = ""
    
    // オーディオ
    var apCat1:AVAudioPlayer = AVAudioPlayer()
    var apCat2:AVAudioPlayer = AVAudioPlayer()
    var apCat3:AVAudioPlayer = AVAudioPlayer()


    // レイアウト
    @IBOutlet weak var safeABeqMSVB: NSLayoutConstraint!
        @IBOutlet weak var safeABeqMSVBforSE: NSLayoutConstraint!
    
    
    //===============================
    // viewDidLoad
    //===============================
    override func viewDidLoad() {
        super.viewDidLoad()

        
        displayImageView = UIImageView(image: UIImage(named: "Red-kitten.jpg"))
        displayImageView.isUserInteractionEnabled = true  // Gestureの許可

        displayImageView.contentMode = UIView.ContentMode.scaleAspectFit
        
        myScrollView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 225/255, alpha:1)
        
        self.makeSound1("cat1b.mp3")
        self.makeSound2("cat-meowing-2.mp3")
        self.makeSound3("cat2.mp3")
        
        switch self.view.frame.size.height {
        case 812..<1000 :
            iphoneType = "X"
//        case 736:
//            iphoneType = "8plus"
        case 568 :
            iphoneType = "SE"
        default:
                if( UIDevice.current.userInterfaceIdiom == .pad) {
                    iphoneType = "iPad"
                }
                else {
                    iphoneType = "iPhone"
                }

        }
        widthOfScreen = self.view.frame.size.width

        initCalc()
        
        adustConstrains()
        
        
    }

    func requestIDFA() {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
            GADMobileAds.sharedInstance().start(completionHandler: nil)

            switch status {
                case .authorized:
                    Analytics.setUserProperty("true", forName: AnalyticsUserPropertyAllowAdPersonalizationSignals)
                case .denied:
                    Analytics.setUserProperty("false", forName: AnalyticsUserPropertyAllowAdPersonalizationSignals)
                case .restricted:
                    Analytics.setUserProperty("false", forName: AnalyticsUserPropertyAllowAdPersonalizationSignals)
                case .notDetermined:
                    Analytics.setUserProperty("false", forName: AnalyticsUserPropertyAllowAdPersonalizationSignals)
                default:
                    Analytics.setUserProperty("false", forName: AnalyticsUserPropertyAllowAdPersonalizationSignals)
                
            }
            Analytics.setAnalyticsCollectionEnabled(true)

        })
    }


    
    //===============================
    // viewDidAppear
    //===============================
    var onetime:Bool = false
    override func viewDidAppear(_ animated: Bool) {
        print(#function)
        super.viewDidAppear(animated)
        if onetime == false {
            initScrollImage()
            onetime = true
        }
        inputText.becomeFirstResponder()   //計算機
        requestIDFA()

    }

    //==============================
    // Constrains
    //==============================
    func adustConstrains() {
        if iphoneType == "SE" { // SEの時
            NSLayoutConstraint.deactivate([safeABeqMSVB])
            NSLayoutConstraint.activate([safeABeqMSVBforSE])
        } else {
            NSLayoutConstraint.activate([safeABeqMSVB])
            NSLayoutConstraint.deactivate([safeABeqMSVBforSE])
        }
        
    }
    
    
    //===============================
    // MARK:計算機
    //===============================
    func calculator(_ calculator: CalculatorKeyboard, didChangeValue value: String, KeyType: Int) {

        inputText.text = value.withComma()
        inputText.fitTextToBounds()

        switch KeyType {
        case CalculatorKey.multiply.rawValue ... CalculatorKey.add.rawValue:

            if btn4cnt > 1 {
                //operatorが連続していたら一番後ろにあるスペースとopratorの文字を削除する。そのあとで入れ直す
                let range = resultText.index(resultText.endIndex, offsetBy: -3)..<resultText.endIndex
                resultText.removeSubrange(range)
                var ope:String  = ""
                if KeyType == CalculatorKey.multiply.rawValue {
                    ope = " × "
                    hideOpeLabel()
                    multiplyLabel.isHidden = false
                }
                else if KeyType == CalculatorKey.divide.rawValue {
                    ope = " ÷ "
                    hideOpeLabel()
                    divideLabel.isHidden = false
                }
                else if KeyType == CalculatorKey.subtract.rawValue {
                    ope = " - "
                    hideOpeLabel()
                    minusLabel.isHidden = false
                }
                else if KeyType == CalculatorKey.add.rawValue {
                    ope = " + "
                    hideOpeLabel()
                    plusLabel.isHidden = false
                }
                
                resultText.append(ope)
                if Constants.DEBUG == true {
                    print(resultText)
                }
            }
            else {
                if KeyType == CalculatorKey.multiply.rawValue {
                    resultText = resultText + "\(suuji)".withComma() + " × "
                    hideOpeLabel()
                    multiplyLabel.isHidden = false
                    
                }
                else if KeyType == CalculatorKey.divide.rawValue {
                    resultText = resultText + "\(suuji)".withComma() + " ÷ "
                    hideOpeLabel()
                    divideLabel.isHidden = false
                }
                else if KeyType == CalculatorKey.subtract.rawValue {
                    resultText = resultText + "\(suuji)".withComma() + " - "
                    hideOpeLabel()
                    minusLabel.isHidden = false
                }
                else if KeyType == CalculatorKey.add.rawValue {
                    resultText = resultText + "\(suuji)".withComma() + " + "
                    hideOpeLabel()
                    plusLabel.isHidden = false
                }
            }
            
        case CalculatorKey.equal.rawValue :
            if btn4cnt > 0 {
                //operatorの続きだったら連続していたらそのあとがoperandが０になっているので
                //Calculatorの動きに合わせてsuujiを0にする
                suuji = "0"
            }

            resultText.append("\(suuji)".withComma() + " = " + "\(value)".withComma())
          
            //履歴に追加する。
            let myIngCoreData:ingCoreData = ingCoreData()
            let myIngLocalImage:ingLocalImage = ingLocalImage()

            let newrid = myIngCoreData.insertRireki(result: value, resultText: resultText)
            myIngLocalImage.storeJpgImageInDocument(image: displayImageView.image!, name: "image\(newrid).jpg")

            resultText = ""
            hideOpeLabel()
            
            
        case CalculatorKey.clear.rawValue:

            resultText = ""
            hideOpeLabel()
            
            if Constants.DEBUG == true {
                let myIngCoreData:ingCoreData = ingCoreData()
                let myIngLocalImage:ingLocalImage = ingLocalImage()
                
                let dics = myIngCoreData.readRirekiAll()
                switch myIngCoreData.rirekiCount {
                case 0:
                    break
                case 1:
                    let r_id = myIngCoreData.max_rid
                    myIngLocalImage.deleteJpgImageInDocument(nameOfImage: "image\(r_id).jpg")
                case 2...:
                    for i in 1...myIngCoreData.rirekiCount {
                        let dic = dics[i-1]
                        let r_id:Int  = dic["r_id"] as! Int
                        myIngLocalImage.deleteJpgImageInDocument(nameOfImage: "image\(r_id).jpg")
                    }
                default:
                    break
                }
                myIngCoreData.deleteRirekiAll()
            }
            
        default:
            //数字が押された時
            if(value.count > 2) {
                checkDigit(digit: value)
            }
     
            break
            
        }
        
        suuji = value

    }
    
    func confirmZero(_ op: CalculatorKey?) {
        let localStr = NSLocalizedString("zeroConfirmation", comment: "") //
        var opString = ""
        if let mark = op!.mark() {
            opString = mark
        }
        
        let alert = UIAlertController(title: "" ,
            message:  opString + " " + localStr,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
                title: NSLocalizedString("cancel", comment: ""),
                style: .cancel,
                handler: nil))
        alert.addAction(UIAlertAction(
                title:"OK" ,
                style: .default,
                handler: { (action) in
                    self.keyboard.finalCalc()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    // 電卓keyboardのセッティング
    func initCalc() {
        var fheight:CGFloat = 300  // other
        switch iphoneType {
        case "X":
            fheight = 334
        case "SE":
            fheight = 280
        default:
            fheight = 300
        }
        
        let frame = CGRect(x:0 , y:0, width: UIScreen.main.bounds.width, height: fheight )
        keyboard = CalculatorKeyboard(frame: frame)

        keyboard.delegate = self
        keyboard.showDecimal = true
        inputText.inputView = keyboard
        
        hideOpeLabel()
    }
    
    func hideOpeLabel () {
        plusLabel.isHidden = true
        minusLabel.isHidden = true
        multiplyLabel.isHidden = true
        divideLabel.isHidden = true
    }
    
    //===============================
    //　癒し用コマンド
    //===============================
    func checkDigit(digit: String) {
        switch digit {
        case "333":
            apCat2.play()
            break
        case "3333333333":
            apCat3.play()

        case "33333333333333333333":
            let cat = Int(arc4random()) % 5
            switch cat {
            case 0:
                let text = """
                The smallest feline is a masterpiece.
                ネコ科の一番小さな動物、つまり猫は、最高傑作である。
                """
                alert1(s_title: "Leonardo da Vinci", s_message: text)
                
            case 1:
                let text = """
                If you yell at a cat, you're the one who is making a fool of yourself.
                猫に怒鳴るという行為は、自分で自分を笑い者にしているようなものだ。
                """
                alert1(s_title: "Author Unknown", s_message: text)
                
            case 2:
                let text = """
                There are few things in life more heart warming than to be welcomed by a cat.
                ネコに迎え入れられることより心が暖まることは、人生にはそうない。
                """
                alert1(s_title: "Tay Hohoff", s_message: text)
           
            case 3:
                let text = """
                A cat has absolute emotional honesty: human beings, for one reason or another, may hide their feelings, but a cat does not.
                猫は絶対的な正直さを持っている。
                人間は何かしらの理由で感情を隠すが、猫はそれがない。
                """
                alert1(s_title: "Ernest Hemingway", s_message: text)
                
            default:
                let text = """
                I wish I could write as mysterious as a cat.
                猫のようにミステリアスに書けたらいいのに。
                """
                alert1(s_title: "Edgar Allan Poe", s_message: text)
                
            }
            
        default:
            break
        }
        
        
    }
    
    //=============================
    // MARK:Alert
    //=============================
    func alert1(s_title:String?, s_message:String){
        let alert = UIAlertController(
            title: s_title ,
            message: s_message,
            preferredStyle: .alert
        )
        
        let subView = alert.view.subviews.first!
        let alertContentView = subView.subviews.first!
        alertContentView.layer.cornerRadius = 5

        alert.addAction(
            UIAlertAction(
                title: "Huh",
                style: .default,
                handler: nil)
        )
        
        self.present(alert, animated: true, completion: {
            // アラートを自動で閉じる 非同期処理
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        })
        
    }
    
    //===============================
    // MARK:ジェスチャー
    //===============================
    @IBAction func longPressImageView(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == UIGestureRecognizer.State.began{
            return
            
        }
        
        let neko = Int(arc4random()) % 10
        print(neko)
        if neko == 1 {
            apCat3.play()

        }
        else {
            apCat1.play()
        }
        showAlbum()
    }
    

    //===============================
    // カメラボタン
    //===============================
    @IBAction func tapCameraBarButton(_ sender: UIBarButtonItem) {
        showCamera()
        
    }
    
    
    
    //===============================
    // カメラ
    //===============================
    func showCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let status = AVCaptureDevice.authorizationStatus(for: .video)

            if status == AVAuthorizationStatus.authorized
            || status == AVAuthorizationStatus.notDetermined
            {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                present(picker, animated: true, completion: nil)
            }
            else {   // Cameraが使えない時に設定を変えるよう促すコーション
                let localStr = NSLocalizedString("CameraErrorMessage", comment: "") //
                let settingStr = NSLocalizedString("Setting", comment: "")
                let alert = UIAlertController(
                    title: "Camera Error!" ,
                    message: localStr,
                    preferredStyle: .alert
                )
                
                alert.addAction(
                    UIAlertAction(
                        title: NSLocalizedString("cancel", comment: ""),
                        style: .cancel,
                        handler: nil
                    )
                )
                alert.addAction(
                    UIAlertAction(
                        title:settingStr ,
                        style: .default,
                        handler: {
                            (action) in
                            UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                        })
                )
                present(alert, animated: true, completion: nil)
                
            }
            
        }
        
    
    }

    func showAlbum(){
        let sourceType:UIImagePickerController.SourceType = UIImagePickerController.SourceType.photoLibrary

        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion:  nil)

        }
    }



    //カメラロールで写真を選んだ後発動
    func imagePickerController(_ imagePicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)


        if Constants.DEBUG == true {
            print(#function)
        }

        //for camera
        // UIImagePickerControllerReferenceURL はカメラロールを選択した時だけ存在するので切り分け。
        if (info.index(forKey: convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.referenceURL)) == nil) {
            //imageViewに撮影した写真をセットするために変数に保存する
            let takenimage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
            
            //画面上のimageViewに設定
            displayImageView.image = takenimage
            
            //自分のデバイス（プログラムが動いている場所）に写真を保存（カメラロール）
            UIImageWriteToSavedPhotosAlbum(takenimage, nil, nil, nil)
            

            //モーダルで表示した撮影モード画面を閉じる（前の画面に戻る）
            dismiss(animated: true, completion: nil)
            
        }
        else {
            //for photolibrary
            let assetURL:AnyObject = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.referenceURL)]! as AnyObject

            let strURL:String = assetURL.description
            let myDefault = UserDefaults.standard
            
            myDefault.set(strURL, forKey: "selectedPhotoURL")
            
            myDefault.synchronize()
            
            
            let takenimage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
            
            displayImageView.image = takenimage

            imagePicker.dismiss(animated: true, completion: nil)
        }
        imageViewSetting()
        
    }
    

    //==============================
    // MARK:ScrolView
    //==============================
    func initScrollImage() {
        if Constants.DEBUG == true {
            print("initScrollImage")
        }
        
        imageViewSetting()
        myScrollView.maximumZoomScale = 4.0
        myScrollView.minimumZoomScale = 0.8
        
        myScrollView.delegate = self
        myScrollView.addSubview(displayImageView)


    }
    
    func imageViewSetting() {
        if Constants.DEBUG == true {
            print(#function)
        }
        //初期化
        myScrollView.zoomScale = 1
        
        if let size = displayImageView.image?.size {
            // imageViewのサイズがscrollView内に収まるように調整
            let wrate = myScrollView.frame.width / size.width
            let hrate = myScrollView.frame.height / size.height
            var rate = min(wrate,hrate)
            if onetime == false {
                rate = wrate
            }
 
            let newImageWidth = size.width * rate
            displayImageView.frame.size = CGSize(width: newImageWidth , height: size.height * rate)
            
            
            displayImageView.frame.origin = CGPoint(x: 0.0, y: 0.0)

            // contentSizeははみ出すサイズなので、画像サイズに設定
            myScrollView.contentSize = displayImageView.frame.size


        }
    }
    
   
    // ユーザがドラッグ後、指を離した際に呼び出されるデリゲートメソッド.
    // velocity = points / second.
    // targetContentOffsetは、停止が予想されるポイント？
    // pagingEnabledがYESの場合には、呼び出されません.
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if Constants.DEBUG == true {
            print(#function)
        }
    }
    
    // ユーザがドラッグ後、指を離した際に呼び出されるデリゲートメソッド.
    // decelerateがYESであれば、慣性移動を行っている.
    //
    // 指をぴたっと止めると、decelerateはNOになり、
    // その場合は「scrollViewWillBeginDecelerating:」「scrollViewDidEndDecelerating:」が呼ばれない？
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if Constants.DEBUG == true {
            print(#function)
        }
    }
    
    // ユーザがドラッグ後、スクロールが減速する瞬間に呼び出されるデリゲートメソッド.
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if Constants.DEBUG == true {
            print(#function)
        }
    }
    
    // ユーザがドラッグ後、慣性移動も含め、スクロールが停止した際に呼び出されるデリゲートメソッド.
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if Constants.DEBUG == true {
            print(#function)
            print(displayImageView.frame)
            print(myScrollView.frame)
        }
   }
    
    // スクロールのアニメーションが終了した際に呼び出されるデリゲートメソッド.
    // アニメーションプロパティがNOの場合には呼び出されない.
    // 【setContentOffset】/【scrollRectVisible:animated:】
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if Constants.DEBUG == true {
            print(#function)
        }
   }
    
    // ズーム中に呼び出されるデリゲートメソッド.
    // ズームの値に対応したUIViewを返却する.
    // nilを返却すると、何も起きない.
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.displayImageView
    }

    //ズームのために要指定
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return displayImageView
    }
    
    //===============================
    // オーディオ
    //===============================
    func makeSound1(_ audioFileName: String) {
        let soundFile = Bundle.main.path(forResource: audioFileName, ofType: nil)!
        let soundClear = URL(fileURLWithPath: soundFile )
        
        do {
            apCat1 = try AVAudioPlayer(contentsOf: soundClear as URL)
        }catch{
            print("Failed AVAudioPlayer Instance")
        }
        apCat1.prepareToPlay()
        
    }
    
    func makeSound2(_ audioFileName: String) {
        let soundFile = Bundle.main.path(forResource: audioFileName, ofType: nil)!
        let soundClear = URL(fileURLWithPath: soundFile )
        
        do {
            apCat2 = try AVAudioPlayer(contentsOf: soundClear as URL)
        }catch{
            print("Failed AVAudioPlayer Instance")
        }
        apCat2.prepareToPlay()
        
    }
    func makeSound3(_ audioFileName: String) {
        let soundFile = Bundle.main.path(forResource: audioFileName, ofType: nil)!
        let soundClear = URL(fileURLWithPath: soundFile )
        
        do {
            apCat3 = try AVAudioPlayer(contentsOf: soundClear as URL)
        }catch{
            print("Failed AVAudioPlayer Instance")
        }
        apCat3.prepareToPlay()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}




// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
