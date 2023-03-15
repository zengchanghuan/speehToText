//
//  LanguageAlertModel.swift
//  Audio2TextSwiftDemo
//
//  Created by admin on 2023/2/8.
//

import UIKit

struct LanguageAlertModel {

    
    var title: String = ""
    var code: String = ""
    
    static func createNodeData() -> [LanguageAlertModel] {
        
        var tempArray = [LanguageAlertModel]()
        
        var model = LanguageAlertModel(title: "English".L,code: "en")
        tempArray.append(model)
        model = LanguageAlertModel(title: "Hindi".L,code: "hi")
        tempArray.append(model)
        model = LanguageAlertModel(title: "Korean".L,code: "ko")
        tempArray.append(model)
        model = LanguageAlertModel(title: "Japanese".L,code: "ja")
        tempArray.append(model)
        model = LanguageAlertModel(title: "German".L,code: "de")
        tempArray.append(model)
        model = LanguageAlertModel(title: "Spanish".L,code: "es")
        tempArray.append(model)
        model = LanguageAlertModel(title: "French".L,code: "fr")
        tempArray.append(model)
        model = LanguageAlertModel(title: "Italian".L,code: "it")
        tempArray.append(model)
        model = LanguageAlertModel(title: "Chinese".L,code: "zh")
        tempArray.append(model)
        model = LanguageAlertModel(title: "Portuguese".L,code: "pt")
        tempArray.append(model)
        
        return tempArray
    }
    
}

