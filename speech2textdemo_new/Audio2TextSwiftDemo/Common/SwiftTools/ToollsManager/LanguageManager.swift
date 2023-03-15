//
//  LanguageManager.swift
//  Audio2TextSwiftDemo
//
//  Created by admin on 2023/2/10.
//

import UIKit

class LanguageManager: NSObject {

    public static let shared = LanguageManager()
    
    // current Language
    var currentLanguage : String = ""
    // current LanguageCode
    var currentLanguageCode : String = ""
    
    private let maxCount : Int = 2
    var dataArray = [LanguageAlertModel]()
    
}

extension LanguageManager{
    
    func currentSysLanguage()->(code:String,displayName:String){
        
        let languageCode = NSLocale.current.languageCode ?? ""
        let descript = NSLocale.current.localizedString(forLanguageCode: languageCode) ?? ""
        
        return (languageCode,descript)
    }
    
    func configLanguage(_ model : LanguageAlertModel)->Bool{
        
        let isContains = dataArray.contains(where: { (item) -> Bool in
            return item.code == model.code
        })

        if isContains == true{
            return false
        }
        dataArray.append(model)
        
        var languageCode = self.dataArray[0].code
        var language = self.dataArray[0].title
        if self.dataArray.count >= maxCount {
            if self.dataArray.count > maxCount{
                self.dataArray.removeFirst()
            }
            languageCode = self.dataArray[0].code + "," +  self.dataArray[1].code
            language = self.dataArray[0].title + "," +  self.dataArray[1].title
        }
        currentLanguage = language
        currentLanguageCode = languageCode
    
        return true
    }
    
    func clearData(){
        dataArray.removeAll()
        currentLanguage = ""
        currentLanguageCode = ""
    }
    
}

