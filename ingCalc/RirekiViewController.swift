//
//  RirekiViewController.swift
//  ingCalc
//
//  Created by yuka on 2017/11/20.
//  Copyright © 2017年 yuka. All rights reserved.
//

import UIKit
//  import ActionCell           // アクションセル
import CoreGraphics
import GoogleMobileAds

let tableHeight:CGFloat = 55

class RirekiViewController: UIViewController
    ,UITableViewDelegate
    ,UITableViewDataSource
    ,GADBannerViewDelegate
{
    
    @IBOutlet weak var myTableView: UITableView!
    var rirekids:[NSDictionary] = []
    var myIngCoreData:ingCoreData = ingCoreData()
    
    var bannerView: GADBannerView!


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red:0.96, green:0.5, blue:0, alpha:1)
        myTableView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 225/255, alpha:1)
        
        // TableViewとCellの設定
        myTableView.rowHeight = tableHeight
        myTableView.dataSource = self
        myTableView.delegate   = self
        myTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cellta")
        NSLayoutConstraint.activate([
            myTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
        
        // Admob
        showAdBanner()
        admobInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(#function)
        reloadForTableView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print(#function)

    }
    
    //移動した画面から戻ってきた時発動
    @IBAction func returnMenu(_ segu:UIStoryboardSegue) {
        if Constants.DEBUG == true {
            print(#function)
        }
        myTableView.reloadData()
        
    }
    


    func reloadForTableView() {
        if Constants.DEBUG == true {
            print(#function)
        }
        let myIngCoreData:ingCoreData = ingCoreData()
        rirekids = myIngCoreData.readRirekiAll()
        
        myTableView.reloadData()

    }
    
    //=============================
    //TableView
    //=============================
    //2.行数の決定
    // numberofrowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let myIngCore:ingCoreData = ingCoreData()

        return myIngCore.rirekiCount
        
    }
    
    var selectedIndex:Int = -1
    
    // セグエを使って、画面遷移している時は発動
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 次の画面のインスタンス(オブジェクト）を取得
        let pvc:pictureViewController = segue.destination as! pictureViewController
        if Constants.DEBUG == true {
            print(#function)
        }
        //次の画面のプロパティ（メンバ変数）passedIndexに選択された行番号を渡す
        pvc.passedIndex = selectedIndex
        print(selectedIndex)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if Constants.DEBUG == true {
            print(#function)
        }
        
        //選択された行番号を保存
        selectedIndex = indexPath.row
        
        //セグエの名前を指定して、画面遷移処理を発動
        //storyboadのIdentifierと名前を合わせるのを忘れずに
        performSegue(withIdentifier: "segueko", sender: nil)
        
    }

    //3.リストに表示する文字列を決定し、表示
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellta", for: indexPath) as! CustomTableViewCell
        
        let rirekiForCell = rirekids[indexPath.row]
        cell.hiddenLabelOfRid = rirekiForCell["r_id"] as! Int
        cell.hiddenLabelOfResult = rirekiForCell["result"] as! String
        cell.button.setTitle((rirekiForCell["resultText"] as! String), for: .normal)
        cell.button.addTarget(self, action:  #selector(cellButtonClicked(_:))
            , for: .touchUpInside)
        myTableView.separatorColor = UIColor(red: 255/255, green: 255/255, blue: 225/255, alpha:1)


        let wrapper = ActionCell()
        wrapper.delegate = self
        wrapper.animationStyle = .concurrent
        wrapper.wrap(cell: cell,
                     actionsLeft: [
                        {
                            let action = IconTextAction(action: "Delete" )
                            action.icon.image = #imageLiteral(resourceName: "image_8").withRenderingMode(.alwaysTemplate)
                            action.icon.tintColor = UIColor.white
                            
                            if Constants.DEBUG == true { action.label.text = "Delete!\(rirekiForCell["r_id"]!)" }
                            else {action.label.text = "Delete"}
                            
                            action.label.font = UIFont.systemFont(ofSize: 12)
                            action.label.textColor = UIColor.white
                            action.backgroundColor = UIColor(red: 255/255, green:70/255, blue: 70/255, alpha:1.00)
                            return action
                        }(),
                        ],
                     actionsRight: [
                        {
                            let action = IconTextAction(action: "Copy")
                            action.icon.image = #imageLiteral(resourceName: "image_7").withRenderingMode(.alwaysTemplate)
                            action.icon.tintColor = UIColor.white
                            action.label.text = "Copy"
                            action.label.font = UIFont.systemFont(ofSize: 12)
                            action.label.textColor = UIColor.white
                            action.backgroundColor = UIColor(red: 70/255, green: 70/255, blue: 255/255, alpha:1.00)
                            return action
                        }(),
                        ])
        
        return cell
    }
    
    //addTargetでselector通じて引数を渡すことはできない。それ自身を渡すことならできる
    //なので、テキストラベルに入っているボタンを渡すことにする
    @objc func cellButtonClicked(_ sender: UIButton ) {
        if Constants.DEBUG == true {
            print(#function)
        }
        
        let btn:UIButton = sender
        let cell:CustomTableViewCell = btn.superview?.superview as! CustomTableViewCell
        //選択された行番号を保存
        selectedIndex =   cell.hiddenLabelOfRid

        //セグエの名前を指定して、画面遷移処理を発動
        //storyboadのIdentifierと名前を合わせるのを忘れずに
        performSegue(withIdentifier: "segueko", sender: nil)

    }

    //=============================
    // Alert
    //=============================
    func alertAction1(s_title:String?, s_message:String, s_action:String){
        
        //部品となるアラート
        let alert = UIAlertController(
            title: s_title ,
            message: s_message,
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: s_action,
                style: .default,
                handler: nil)
        )
        
        // アラート表示
        self.present(alert, animated: true, completion: {
            // アラートを閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 8.0, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        })
    
    }

    
    //================================
    // Admob
    //================================
    //広告を表示するメソッド
    func showAdBanner() {
        //バナー用のビューを作成
        //  kGADAdSizeBannerは決まっているサイズ
        bannerView = GADBannerView(adSize: GADAdSizeBanner)

        addBannerViewToView(bannerView)
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        view.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    
//
//        //バナーを下に配置
//        admobView.frame.origin = CGPoint(x: 0, y: view.frame.size.height - admobView.frame.height)
//
//        //バナーの横幅をデバイスと合わせる
//        admobView.frame.size = CGSize(width: widthOfScreen, height: admobView.frame.height)
//        admobView.adUnitID = AdMobID
//        admobView.rootViewController = self
//
    
    func admobInit() {
        bannerView.adUnitID = AdMobID
        bannerView.delegate = self
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
    }

    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }

}

// MARK:- ActionCell用
extension RirekiViewController: ActionCellDelegate {
    
    var tableView: UITableView! {
        return myTableView
        
    }
    
    
    public func didActionTriggered(cell: UITableViewCell, action: String) {
        if Constants.DEBUG == true {
            print(#function)
            print(action)
        }
        let cellta = cell as! CustomTableViewCell
        
        if(action == "Delete")
        {
            let myIngCoreData:ingCoreData = ingCoreData()
            let myIngLocalImage:ingLocalImage = ingLocalImage()
            let ridOfCell = cellta.hiddenLabelOfRid
            
            myIngCoreData.deleteRireki(r_id: ridOfCell )
            myIngLocalImage.deleteJpgImageInDocument(nameOfImage: "image\(ridOfCell).jpg")
            self.reloadForTableView()
            
            
        }
        else if(action == "Copy")
        {
            let myPasteBoard = UIPasteboard.general
            myPasteBoard.string = cellta.hiddenLabelOfResult

            alertAction1(s_title: "Text has been copied to clipboard.",s_message: "クリップボードにコピーされました",s_action: "OK")
            
        }
        
        
    }
    


}



class CustomTableViewCell: UITableViewCell {
    
    var button: UIButton!
    var hiddenLabelOfResult:String = ""
    var hiddenLabelOfRid:Int = 0
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        button = {
            let the = UIButton()
            the.setTitle("click me", for: .normal)
            the.setTitleColor(UIColor.black, for: .normal)
           // the.setTitleColor(UIColor.white , for: .highlighted)
            the.setBackgroundImage(createImageFromUIColor(color: UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)), for: .highlighted)
            the.setBackgroundImage(createImageFromUIColor(color: UIColor(red: 255/255, green: 255/255, blue: 225/255, alpha: 1)), for: .normal)
            //the.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 225/255, alpha:1)
            the.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
            the.layer.borderWidth = 1
            
            return the
        }()
        guard let button = button  else { return }
        contentView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: widthOfScreen))
        contentView.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: tableHeight))  //TODO: ここの数字とセルの高さを同じにすること
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        clearActionsheet()
    }
    
    private func createImageFromUIColor(color: UIColor) -> UIImage {
        // 1x1のbitmapを作成
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        // bitmapを塗りつぶし
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        // UIImageに変換
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
}

