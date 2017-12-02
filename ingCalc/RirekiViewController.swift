//
//  RirekiViewController.swift
//  ingCalc
//
//  Created by yuka on 2017/11/20.
//  Copyright © 2017年 yuka. All rights reserved.
//

import UIKit
import ActionCell           // アクションセル

class RirekiViewController: UIViewController
    ,UITableViewDelegate
    ,UITableViewDataSource
//    ,ActionCellDelegate
{
    
    @IBOutlet weak var myTableView: UITableView!
  //  var myActionCell:ActionCell = ActionCell()
    var rirekids:[NSDictionary] = []
    var myIngCoreData:ingCoreData = ingCoreData()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // TableViewとCellの設定
        myTableView.dataSource = self
        myTableView.delegate   = self
        myTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cellta")
        
    //    myActionCell.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(#function)
        reloadForTableView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print(#function)
        // Dispose of any resources that can be recreated.
    }
    
    //移動した画面から戻ってきた時発動
    @IBAction func returnMenu(_ segu:UIStoryboardSegue) {
        print("戻ってきました")
        
    }


    func reloadForTableView() {
        print(#function)
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
        
        //return rirekiResult.count
        
    }
    
    var selectedIndex:Int = -1
    
    // セグエを使って、画面遷移している時は発動
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 次の画面のインスタンス(オブジェクト）を取得
        let pvc:pictureViewController = segue.destination as! pictureViewController
        
        //次の画面のプロパティ（メンバ変数）passedIndexに選択された行番号を渡す
        pvc.passedIndex = selectedIndex
        print(selectedIndex)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.row)行目がタップされました")
        //選択された行番号を保存
        selectedIndex = indexPath.row
        
        //セグエの名前を指定して、画面遷移処理を発動
        //storyboadのIdentifierと名前を合わせるのを忘れずに
        performSegue(withIdentifier: "segueko", sender: nil)
        
    }

    //3.リストに表示する文字列を決定し、表示
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    //    let myIngCore:ingCoreData = ingCoreData()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellta", for: indexPath) as! CustomTableViewCell
        
        
//        let rirekiForCell = myIngCore.readRireki(r_id: indexPath.row)
        let rirekiForCell = rirekids[indexPath.row]
        cell.hiddenLabelOfRid = rirekiForCell["r_id"] as! Int
        cell.hiddenLabelOfResult = rirekiForCell["result"] as! String
        cell.button.setTitle((rirekiForCell["resultText"] as! String), for: .normal)
        cell.button.addTarget(self, action:  #selector(cellButtonClicked(_:))
            , for: .touchUpInside)
        myTableView.separatorColor = UIColor.white

        let wrapper = ActionCell()
        wrapper.delegate = self
        wrapper.animationStyle = .concurrent
        wrapper.wrap(cell: cell,
                     actionsLeft: [
                        {
                            let action = IconTextAction(action: "Delete" )
                            action.icon.image = #imageLiteral(resourceName: "image_8").withRenderingMode(.alwaysTemplate)
                            action.icon.tintColor = UIColor.white
                            action.label.text = "Delete!\(rirekiForCell["r_id"]!)"
                            action.label.font = UIFont.systemFont(ofSize: 12)
                            action.label.textColor = UIColor.white
                            action.backgroundColor = UIColor(red:0.51, green:0.83, blue:0.73, alpha:1.00)
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
                            action.backgroundColor = UIColor(red:0.14, green:0.69, blue:0.67, alpha:1.00)
                            return action
                        }(),
                        ])
        return cell
    }
    
    //addTargetでselector通じて引数を渡すことはできない。それ自身を渡すことならできる
    //なので、テキストラベルに入っているボタンを渡すことにする
    @objc func cellButtonClicked(_ sender: UIButton ) {
       // self.output.text = "cell button clicked"
        print(#function)

     //==============================================================================ここなおす
        //選択された行番号を保存
        selectedIndex = 1
        
        //セグエの名前を指定して、画面遷移処理を発動
        //storyboadのIdentifierと名前を合わせるのを忘れずに
        performSegue(withIdentifier: "segueko", sender: nil)

    }

    
    //=============================
    // Alert
    //=============================
    func alertAction1(s_title:String, s_message:String, s_action:String){
        
        //部品となるアラート
        let alert = UIAlertController(
            title: s_title ,
            message: s_message,
            preferredStyle: .alert
        )
        
        //ボタンを増やしたいときは、addActionをもう一つ作ればよい
        alert.addAction(
            UIAlertAction(
                title: s_action,
                style: .default,
                handler: nil)
        )
        
        //アラートを表示
        present(alert,
                animated: true,
                completion: nil
        )
    }
}


extension RirekiViewController: ActionCellDelegate {
    
    var tableView: UITableView! {
        return myTableView
        
    }
    
    
    public func didActionTriggered(cell: UITableViewCell, action: String) {
        print(#function)
        print(action)
        let cellta = cell as! CustomTableViewCell
        
        if(action == "Delete")
        {
            let myIngCoreData:ingCoreData = ingCoreData()
            let myIngLocalImage:ingLocalImage = ingLocalImage()
            let ridOfCell = cellta.hiddenLabelOfRid
            
            myIngCoreData.deleteRireki(r_id: ridOfCell )
            print("cellta.hiddenLabelOfRid : \(ridOfCell)")
            myIngLocalImage.deleteJpgImageInDocument(nameOfImage: "image\(ridOfCell).jpg")
            self.reloadForTableView()
            
            
        }
        else if(action == "Copy")
        {
            let myPasteBoard = UIPasteboard.general
//            myPasteBoard.string = (cellta.button.titleLabel?.text as! String)
            myPasteBoard.string = cellta.hiddenLabelOfResult

            alertAction1(s_title: "ながら電卓",s_message: "クリップボードにコピーされました",s_action: "OK")
            
        }
        
        
    }
}

// ActionCell用
class CustomTableViewCell: UITableViewCell {
    
    var button: UIButton!
    var hiddenLabelOfResult:String = ""
    var hiddenLabelOfRid:Int = 0
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        button = {
            let the = UIButton()
            the.setTitle("click me", for: .normal)
            the.setTitleColor(UIColor.black, for: .normal)
            the.backgroundColor = UIColor.orange
       //     the.tintColor = UIColor.orange
            return the
        }()
        contentView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 500))  //TODO: ここの数字の横幅を画面最大にすること
        contentView.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50))  //TODO: ここの数字とセルの高さを同じにすること
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        clearActionsheet()
    }
}

