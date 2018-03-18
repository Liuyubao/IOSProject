//
//  XHWLSoundPlayer.swift
//  XHWLHouseManager
//
//  Created by gongairong on 2017/12/28.
//  Copyright © 2017年 XHWL. All rights reserved.
//

import UIKit
import AudioToolbox

enum SoundType:NSInteger {
    case caller
    case callee
}

class XHWLSoundPlayer: NSObject {

    static var soundID:SystemSoundID = 0
    static var soundID2:SystemSoundID = SystemSoundID(kSystemSoundID_Vibrate)
    static func playSound(_ type:SoundType) {
        
        var res:String = "ring"
        if type == .callee {
            res = "videoRing"
        }
        
        let path:String = Bundle.main.path(forResource: res, ofType:"caf")!
        
        AudioServicesCreateSystemSoundID(URL.init(fileURLWithPath: path) as CFURL, &soundID)
        AudioServicesPlaySystemSound(soundID)
        
        soundID2 = SystemSoundID(kSystemSoundID_Vibrate)
        //加上震动
        AudioServicesPlaySystemSound(soundID2)
        
        
        
        AudioServicesPlaySystemSoundWithCompletion(soundID) {
            if soundID != 0 {
//                AudioServicesDisposeSystemSoundID(soundID2)
                self.playSound(type)
//                self.viberate()

            }
        }
    }
    
//    static func viberate() {
//        soundID2 = SystemSoundID(kSystemSoundID_Vibrate)
//        //加上震动
//        AudioServicesPlaySystemSound(soundID2)
//
//        AudioServicesPlaySystemSoundWithCompletion(soundID2) {
//
//            if soundID2 != 0 {
//                self.viberate()
//            }
//        }
//    }
    
    //摇一摇音效
    static func playShakeSound() {
        var shakeSoundID:SystemSoundID = 0
        let path:String = Bundle.main.path(forResource: "rock", ofType:"mp3")!
        AudioServicesCreateSystemSoundID(URL.init(fileURLWithPath: path) as CFURL, &shakeSoundID)
        AudioServicesPlaySystemSound(shakeSoundID)
    }
    
    //摇一摇开门成功音效
    static func playShakeSuccessfulSound() {
        var shakeSuccessfulSoundID:SystemSoundID = 0
        let path:String = Bundle.main.path(forResource: "rock_end", ofType:"mp3")!
        AudioServicesCreateSystemSoundID(URL.init(fileURLWithPath: path) as CFURL, &shakeSuccessfulSoundID)
        AudioServicesPlaySystemSound(shakeSuccessfulSoundID)
    }
    
    
    static func stop() {
        AudioServicesDisposeSystemSoundID(soundID)
        AudioServicesDisposeSystemSoundID(soundID2)
        soundID = 0
        soundID2 = 0
    }
}
