//
//  ingLocalImage.swift
//  ingCalc
//
//  Created by yuka on 2017/12/01.
//  Copyright © 2017年 yuka. All rights reserved.
//  アプリ内の画像データを扱うためのクラス

import UIKit

class ingLocalImage {
    private let fileManager = FileManager.default
    private lazy var documentDirectory: URL = {
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0]
    }()
   
    //=========================
    // JPGをdocumentフォルダへ保存
    //=========================
    func storeJpgImageInDocument(image: UIImage , name: String) {
        if Constants.DEBUG == true {
            print(#function)
        }
        let dataPath = documentDirectory.appendingPathComponent(name)
        do {
            if let data = image.jpegData(compressionQuality: 0.8) {
                try data.write(to: dataPath)
                print("画像が正常に保存されました: \(dataPath.path)")
            } else {
                print("画像データの生成に失敗しました")
            }
        } catch {
            print("画像の保存に失敗しました: \(error.localizedDescription)")
        }

    }
    
    //=============================
    // JPGをdocumentフォルダから読み出し
    //==============================
    func readJpgImageInDocument(nameOfImage: String) -> UIImage? {
        if Constants.DEBUG == true {
            print(#function)
        }
        let dataPath = documentDirectory.appendingPathComponent(nameOfImage)
        
        do {
            let data = try Data(contentsOf: dataPath)
            if let image = UIImage(data: data) {
                return image
            } else {
                print("画像データの解析に失敗しました")
                return nil
            }
        } catch {
            print("画像の読み込みに失敗しました: \(error.localizedDescription)")
            return nil
        }        
        
    }

    //===========================
    // JPGをdocumentフォルダから削除
    //===========================
    func deleteJpgImageInDocument(nameOfImage: String){
        if Constants.DEBUG == true {
            print(#function)
        }
        let dataPath = documentDirectory.appendingPathComponent(nameOfImage)
        
        do {
            if fileManager.fileExists(atPath: dataPath.path) {
                // Delete file
                try fileManager.removeItem(atPath: dataPath.path)
            } else {
                print("File does not exist")
            }
        }
        catch let error as NSError {
            print("An error took place: \(error)")
        }
    }
}
