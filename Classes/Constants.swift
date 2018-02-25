//
//  Constants.swift
//  RealMadridCFResourcesPod
//
//  Created by Borja Álvaro González Jurado on 19/02/2018.
//

import Foundation

struct Constants {
    
    struct Devices {
        static let iPhone7Width = 414.0
        static let iPhone7Height = 736.0
    }
    
    struct Files {
        // Constant framework file
        static let framework = "RealMadridCFResourcesPod.framework"
        // Constant bundle file
        static let bundle = "RealMadridCFResourcesPod.bundle"
        // Constants plist files
        static let audiosPlist = "Audios.plist"
        static let availableFontsPlist = "AvailableFonts.plist"
        static let colorsPlist = "Colors.plist"
        static let fontsPlist = "Fonts.plist"
        static let framesPlist = "Frames.plist"
        static let imagesPlist = "Images.plist"
        static let textsPlist = "Texts.plist"
        static let videosPlist = "Videos.plist"
        // Others files
        static let trophiesJson = "trophies.json"
    }
    
    // Others constants
    struct KeyWords {
        static let audiosKey = "Audios"
        static let autoresizingKey = "Autoresizing"
        static let colorsKey = "Colors"
        static let fontsKey = "Fonts"
        static let framesKey = "Frames"
        static let heightKey = "Height"
        static let imagesKey = "Images"
        static let landscapeKey = "Landscape"
        static let portraitKey = "Portrait"
        static let textsKey = "Texts"
        static let videosKey = "Videos"
        static let widthKey = "Width"
        static let xKey = "X"
        static let yKey = "Y"
    }
}
