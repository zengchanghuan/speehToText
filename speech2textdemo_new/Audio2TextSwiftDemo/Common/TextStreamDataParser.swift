//
//  TextStreamDataParser.swift
//  Audio2TextSwiftDemo
//
//  Created by FanPengpeng on 2022/3/25.
//

import UIKit
import AGEVideoLayout

class TextStreamDataParser: NSObject {
    
    private static var lastSeqnum:Int32 = -1
    
    private static var finalLists:[Int64:[String]] = [Int64:[String]]()
    
    private static var finalConfidenceLists:[Int64:[String]] = [Int64:[String]]()

    private static var finalTexts:[Int64:String] = [Int64:String]()
    
    private static var finalTextConfidences:[Int64:String] = [Int64:String]()
    
    static func clear(){
        finalLists.removeAll()
        finalConfidenceLists.removeAll()
        finalTexts.removeAll()
        finalTextConfidences.removeAll()
        lastSeqnum = -1
    }
    
    static func createStringWithText(_ textstream:Text,finalClourse:((String,String)->Void)?) -> (String,String,String,Int,String) {
        let defaultReturnValue = ("","","",0,"")
        guard let words = textstream.wordsArray else { return defaultReturnValue  }
//        if textstream.seqnum == lastSeqnum {
//            return defaultReturnValue
//        }
//        lastSeqnum = textstream.seqnum
        
        let revUid:Int64 = textstream.uid
        var finalList:[String] = finalLists[revUid] ?? [String]()
        finalLists[revUid] = finalList
        
        var finalConfidenceList = finalConfidenceLists[revUid] ?? [String]()
        finalConfidenceLists[revUid] = finalConfidenceList
        
        var finalText = finalTexts[revUid] ?? ""
        finalTexts[revUid] = finalText
        
        var finalTextConf = finalTextConfidences[revUid] ?? ""
        finalTextConfidences[revUid] = finalTextConf
        
        var nonFinalList = [String]()
        
        var nonFinalConfidenceList = [String]()
        
        for item in words {
            guard let word:Word = item as? Word else { return defaultReturnValue }
            if word.isFinal {
                finalList.append(word.text)
                finalLists[revUid] = finalList
                
                finalConfidenceList.append(String(format: "%.2f", (word.confidence)))
                finalConfidenceLists[revUid] = finalConfidenceList
                
                if isSentenceBoundaryWord(word.text) {
                    let text = wordsToText(finalList)
                    finalList.removeAll()
                    finalLists[revUid] = finalList
        
                    finalText.append(text)
                    finalTexts[revUid] = finalText
                    
                    let textConfidence = wordsToText(finalConfidenceList)
                    finalConfidenceList.removeAll()
                    finalConfidenceLists[revUid] = finalConfidenceList
                    
                    finalTextConf.append(textConfidence)
                    finalTextConfidences[revUid] = finalTextConf
                    
                    finalClourse?(text,textConfidence)
                }
            }else{
                nonFinalList.append(word.text)
                nonFinalConfidenceList.append(String(format: "%.2f", (word.confidence)))
            }
        }
        
        let currentFinalText = wordsToText(finalList)
        let currentFinalCount = currentFinalText.count
        
        var currentText = currentFinalText
        let oldFinalCount = finalText.count
        currentText.append(wordsToText(nonFinalList))
        
        let wholeText = finalText.appending(currentText)
        let wholeFinalCount = currentFinalCount + oldFinalCount
        
        var currentConfidenceText = wordsToText(finalConfidenceList)
        currentConfidenceText.append(wordsToText(nonFinalConfidenceList))
        
        return (currentText,currentConfidenceText,wholeText,wholeFinalCount,currentFinalText)
    }
    
    static func isPunctuationWord(_ word:String) -> Bool {
        return word == "." || word == "?" || word == ","
    }
    
    static func isSentenceBoundaryWord(_ word:String) -> Bool {
        return word == "." || word == "?"
    }
    
    static func wordsToText(_ words:[String]) -> String {
        var str = ""
        for word in words {
            if !isPunctuationWord(word) {
                str.append(" ")
            }
            str.append(word)
        }
        return str;
    }
    
}
