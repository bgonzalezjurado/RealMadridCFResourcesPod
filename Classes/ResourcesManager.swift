//
//  ResourcesManager.swift
//  CustomizationArchitectureDemo
//
//  Created by Borja González Jurado on 17/6/16.
//  Copyright © 2016 Borja González Jurado. All rights reserved.
//

import Foundation
import UIKit
import CoreText


open class ResourcesManager {
    
    enum ParamType: NSInteger {
        case xCoordOrWidthDim
        case yCoordOrHeightDim
    }
    
    struct Constants {
        
        struct Devices {
            static let kiPhone7Width = 414.0
            static let kiPhone7Height = 736.0
        }
        
        struct Files {
            // Constant framework file
            static let kFramework = "RealMadridCFResourcesPod.framework"
            // Constant bundle file
            static let kBundle = "RealMadridCFResourcesPod.bundle"
            // Constants plist files
            static let kAudiosPlist = "Audios.plist"
            static let kAvailableFontsPlist = "AvailableFonts.plist"
            static let kColorsPlist = "Colors.plist"
            static let kFontsPlist = "Fonts.plist"
            static let kFramesPlist = "Frames.plist"
            static let kImagesPlist = "Images.plist"
            static let kTextsPlist = "Texts.plist"
            static let kVideosPlist = "Videos.plist"
            // Others files
            static let kTrophiesJson = "trophies.json"
        }
        
        // Others constants
        struct KeyWords {
            static let kAudiosKey = "Audios"
            static let kAutoresizingKey = "Autoresizing"
            static let kColorsKey = "Colors"
            static let kFontsKey = "Fonts"
            static let kFramesKey = "Frames"
            static let kHeightKey = "Height"
            static let kImagesKey = "Images"
            static let kLandscapeKey = "Landscape"
            static let kPortraitKey = "Portrait"
            static let kTextsKey = "Texts"
            static let kVideosKey = "Videos"
            static let kWidthKey = "Width"
            static let kXKey = "X"
            static let kYKey = "Y"
        }
    }
    
    
    // MARK: - Public methods
    
    // Returns the bundle app
    open static func getBundle() -> Bundle {
        
        let bundle = Bundle(url: self.getResourcePath())
        return bundle!
    }
    
    // Returns any class
    open static func getClassWithName(_ className: String) -> AnyClass {
        
        let bundle = Bundle(url: self.getResourcePath())
        let classURL = (bundle?.url(forResource: className, withExtension: nil))
        let classData = try? Data(contentsOf: classURL!)
        
        return type(of: classData) as! AnyClass
    }
    
    // Returns Autoresizing
    open static func getViewAutoresizingWithId(_ autoresizingId: String,
                                               orientation: UIInterfaceOrientation,
                                               viewControllerName: String) -> UIViewAutoresizing {
        
        var currentAutoresizing = UIViewAutoresizing()
        
        let orientationKey = self.getKeyForInterfaceOrientation(orientation)
        let framesDict = self.getDictionaryFromPlistWithName(Constants.Files.kFramesPlist)
        let autoresizingConfiguration = (framesDict as NSDictionary).value(forKeyPath: Constants.KeyWords.kFramesKey + "." +
            viewControllerName + "." +
            autoresizingId + "." +
            orientationKey + "." +
            Constants.KeyWords.kAutoresizingKey) as! String
        
        let autoresizingArray = autoresizingConfiguration.components(separatedBy: "|")
        for autoresizingType in autoresizingArray {
            currentAutoresizing.insert(self.getAutoresizingWithType(autoresizingType))
        }
        
        return currentAutoresizing as! UIViewAutoresizing
    }
    
    // Returns color for the given color name in the view controller, according to pod
    open static func getColorWithName(_ colorName: String, viewControllerName: String) -> UIColor {
        
        return self.getColorForViewWithName(colorName, viewControllerName: viewControllerName)
    }
    
    // Returns color from Plist
    open static func getColorForViewWithName(_ viewName: String, viewControllerName: String) -> UIColor {
        
        let colorsDict = self.getDictionaryFromPlistWithName(Constants.Files.kColorsPlist)
        let colorCode = (colorsDict as NSDictionary).value(forKeyPath: Constants.KeyWords.kColorsKey + "." +
            viewControllerName + "." +
            viewName) as! String
        let hexInt = self.intFromHexString(colorCode)
        let color = UIColor(red:((CGFloat) ((hexInt & 0xFF0000) >> 16)) / 255,
                            green:((CGFloat) ((hexInt & 0xFF00) >> 8)) / 255,
                            blue:((CGFloat) (hexInt & 0xFF)) / 255,
                            alpha:1.0)
        
        return color
    }
    
    // Returns font
    open static func getFontWithName(_ fontName: String, fontSize: String, viewControllerName: String) -> UIFont {
        
        let size = self.getFontSize(fontSize, viewControllerName: viewControllerName)
        let fontsDict = self.getDictionaryFromPlistWithName(Constants.Files.kFontsPlist)
        let name = (fontsDict as NSDictionary).value(forKeyPath: Constants.KeyWords.kFontsKey + "." +
            viewControllerName + "." +
            fontName) as! String
        var font = UIFont(name: name, size: size)
        if (font == nil) {
            font = UIFont(name: name.stringByDeletingPathExtension, size: size)
            if (font == nil) {
                font = UIFont.systemFont(ofSize: size)
            }
        }
        
        return font!
    }
    
    // Returns an image for a particular view controller
    open static func getImageForViewWithName(_ imageName: String, screenScale: CGFloat, viewControllerName: String) -> UIImage {
        
        let imagesDict = self.getDictionaryFromPlistWithName(Constants.Files.kImagesPlist)
        let imgName = (imagesDict as NSDictionary).value(forKeyPath: Constants.KeyWords.kImagesKey + "." +
            viewControllerName + "." +
            imageName) as! String
        let bundle = Bundle(url: self.getResourcePath())
        let imageURL = (bundle?.url(forResource: imgName, withExtension: nil))
        let image = UIImage(data: try! Data(contentsOf: imageURL!), scale: screenScale)
        
        return image!
    }
    
    // Returns text
    open static func getTextWithId(_ textId: String, viewControllerName: String) -> String {
        
        let textsDict = self.getDictionaryFromPlistWithName(Constants.Files.kTextsPlist)
        let text = (textsDict as NSDictionary).value(forKeyPath: Constants.KeyWords.kTextsKey + "." +
            viewControllerName + "." +
            textId) as! String
        
        return text
    }
    
    // Returns URL from audio
    open static func getAudioWithId(_ audioId: String, viewControllerName: String) -> URL {
        
        let audiosDict = self.getDictionaryFromPlistWithName(Constants.Files.kAudiosPlist)
        let audioName = (audiosDict as NSDictionary).value(forKeyPath: Constants.KeyWords.kAudiosKey + "." +
            viewControllerName + "." +
            audioId) as! String
        let bundle = Bundle(url: self.getResourcePath())
        let audioURL = (bundle?.url(forResource: audioName, withExtension: nil))
        
        return audioURL!
    }
    
    // Returns URL from video
    open static func getVideoWithId(_ videoId: String, viewControllerName: String) -> URL {
        
        let videosDict = self.getDictionaryFromPlistWithName(Constants.Files.kVideosPlist)
        let videoName = (videosDict as NSDictionary).value(forKeyPath: Constants.KeyWords.kVideosKey + "." +
            viewControllerName + "." +
            videoId) as! String
        let bundle = Bundle(url: self.getResourcePath())
        let videoURL = (bundle?.url(forResource: videoName, withExtension: nil))
        
        return videoURL!
    }
    
    // Returns view coordinates (x, y)
    open static func getViewCoordinatesWithId(_ coordinatesId: String,
                                              orientation: UIInterfaceOrientation,
                                              viewControllerName: String) -> [Double] {
        
        let orientationKey = self.getKeyForInterfaceOrientation(orientation)
        let framesDict = self.getDictionaryFromPlistWithName(Constants.Files.kFramesPlist)
        
        let xPath = Constants.KeyWords.kFramesKey + "." +
            viewControllerName + "." +
            coordinatesId + "." +
            orientationKey + "." +
            Constants.KeyWords.kXKey
        var xCoord = (framesDict as NSDictionary).value(forKeyPath: xPath)
        
        let yPath = Constants.KeyWords.kFramesKey + "." +
            viewControllerName + "." +
            coordinatesId + "." +
            orientationKey + "." +
            Constants.KeyWords.kYKey
        var yCoord = (framesDict as NSDictionary).value(forKeyPath: yPath)
        
        xCoord = self.crossMultiplicationWithParameter(param: Double((xCoord! as AnyObject).floatValue),
                                                       paramType: ParamType.xCoordOrWidthDim)
        
        yCoord = self.crossMultiplicationWithParameter(param: Double((yCoord! as AnyObject).floatValue),
                                                       paramType: ParamType.yCoordOrHeightDim)
        
        return [xCoord as! Double, yCoord as! Double]
    }
    
    // Returns view dimensions (width, height)
    open static func getViewDimensionsWithId(_ dimensionsId: String,
                                             orientation: UIInterfaceOrientation,
                                             viewControllerName: String) -> [Double] {
        
        let orientationKey = self.getKeyForInterfaceOrientation(orientation)
        let framesDict = self.getDictionaryFromPlistWithName(Constants.Files.kFramesPlist)
        
        let widthPath = Constants.KeyWords.kFramesKey + "." +
            viewControllerName + "." +
            dimensionsId + "." +
            orientationKey + "." +
            Constants.KeyWords.kWidthKey
        var width = (framesDict as NSDictionary).value(forKeyPath: widthPath)
        
        let heightPath = Constants.KeyWords.kFramesKey + "." +
            viewControllerName + "." +
            dimensionsId + "." +
            orientationKey + "." +
            Constants.KeyWords.kHeightKey
        var height = (framesDict as NSDictionary).value(forKeyPath: heightPath)
        
        width = self.crossMultiplicationWithParameter(param: Double((width! as AnyObject).floatValue),
                                                      paramType: ParamType.xCoordOrWidthDim)
        
        height = self.crossMultiplicationWithParameter(param: Double((height! as AnyObject).floatValue),
                                                       paramType: ParamType.yCoordOrHeightDim)
        
        return [width as! Double, height as! Double]
    }
    
    // Loads the font files
    open static func loadAvailableFonts() -> Void {
        
        let fontsDict = self.getDictionaryFromPlistWithName(Constants.Files.kAvailableFontsPlist)
        let fontsArray = ((fontsDict as NSDictionary).value(forKeyPath: Constants.KeyWords.kFontsKey) as AnyObject).allValues
        
        for (_, value) in fontsArray!.enumerated() {
            
            let fontName = value as! String
            let bundle = Bundle(url: self.getResourcePath())
            let fontURL = (bundle?.url(forResource: fontName, withExtension: nil))
            
            var errorRef: Unmanaged<CFError>?
            _ = CTFontManagerRegisterFontsForURL(fontURL as! CFURL, .process, &errorRef)
            
            if (errorRef != nil) {
                _ = errorRef!.takeRetainedValue()
            }
        }
    }
    
    // Parse a JSON file and returns data
    open static func parsingJSON() -> [String: Any] {
        
        var jsonData: [String: Any] = [String: Any]()
        let bundle = Bundle(url: self.getResourcePath())
        
        if let jsonURL = (bundle?.url(forResource: Constants.Files.kTrophiesJson, withExtension: nil)) {
            do {
                let data = try Data(contentsOf: jsonURL)
                if let parsedData = try? JSONSerialization.jsonObject(with: data) as! [String: Any] {
                    jsonData = parsedData
                }
            } catch {
                print(error)
            }
        }
        
        return jsonData
    }
    
    
    // MARK: - Private methods
    
    // Returns UIViewAutoresizing
    fileprivate static func getAutoresizingWithType(_ autoresizingType: String) -> UIViewAutoresizing {
        
        let autoresizingParamsArray = [".flexibleLeftMargin",
                                       ".flexibleRightMargin",
                                       ".flexibleTopMargin",
                                       ".flexibleBottomMargin",
                                       ".flexibleHeight",
                                       ".flexibleWidth",
                                       ".none"]
        
        var currentAutoresizing: UIViewAutoresizing
        
        let index: Int = autoresizingParamsArray.index(of: autoresizingType)!
        switch index {
        case 0:
            currentAutoresizing = .flexibleLeftMargin
        case 1:
            currentAutoresizing = .flexibleRightMargin
        case 2:
            currentAutoresizing = .flexibleTopMargin
        case 3:
            currentAutoresizing = .flexibleBottomMargin
        case 4:
            currentAutoresizing = .flexibleHeight
        case 5:
            currentAutoresizing = .flexibleWidth
        default:
            currentAutoresizing = UIViewAutoresizing()
        }
        
        return currentAutoresizing
    }
    
    // Returns Dictionary from Plist
    fileprivate static func getDictionaryFromPlistWithName(_ plistName: String) -> [String: AnyObject] {
        
        let bundle = Bundle(url: self.getResourcePath())
        let resource = plistName.stringByDeletingPathExtension
        let type = plistName.pathExtension
        let plistFile = bundle?.path(forResource: resource, ofType: type)
        let plistDictionary = NSDictionary(contentsOfFile:plistFile!) as! [String: AnyObject]
        
        return plistDictionary
    }
    
    // Returns image file name with or without @2x added
    fileprivate static func getImageFileNameWithName(_ imageName: String, screenScale: CGFloat) -> String {
        
        var fileName = imageName
        let validName = !imageName.isEmpty && (imageName.characters.count >= 4)
        if (validName) {
            
            switch Int(screenScale) {
            case 2:
                let index: String.Index = imageName.characters.index(imageName.startIndex, offsetBy: imageName.characters.count - 4)
                let name: String = imageName.substring(to: index)
                let ext: String = imageName
                fileName = String.localizedStringWithFormat("%@%@.%@", name, "@2x", ext)
            default:
                break;
            }
        }
        
        return fileName
    }
    
    // Returns a string key according the current interface orientation
    fileprivate static func getKeyForInterfaceOrientation(_ orientation: UIInterfaceOrientation) -> String {
        
        let orientationKey: String!
        switch orientation {
        case UIInterfaceOrientation.landscapeLeft,
             UIInterfaceOrientation.landscapeRight:
            orientationKey = "Landscape"
            break
        case UIInterfaceOrientation.unknown,
             UIInterfaceOrientation.portrait,
             UIInterfaceOrientation.portraitUpsideDown:
            orientationKey = "Portrait"
            break
        }
        
        return orientationKey
    }
    
    // Returns font size
    fileprivate static func getFontSize(_ kFontSize: String, viewControllerName: String) -> CGFloat {
        
        let fontsDict = self.getDictionaryFromPlistWithName(Constants.Files.kFontsPlist)
        let fontSizeDict = fontsDict[Constants.KeyWords.kFontsKey] as? [String: AnyObject]
        let fontSizeViewControllerDict = fontSizeDict![viewControllerName] as? [String: AnyObject]
        let fontSize = fontSizeViewControllerDict![kFontSize]
        
        return CGFloat(fontSize!.floatValue)
    }
    
    // Returns the base path
    fileprivate static func getResourcePath() -> URL {
        
        let resourcePath = URL(fileURLWithPath:Bundle.main.privateFrameworksPath!).appendingPathComponent(Constants.Files.kFramework).appendingPathComponent(Constants.Files.kBundle)
        
        return resourcePath
    }
    
    // Converts hexadecimal String to CUnsignedInt
    fileprivate static func intFromHexString(_ hexStr: String) -> CUnsignedInt {
        
        var hexInt: CUnsignedInt = 0;
        let scanner = Scanner(string:hexStr)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn:"#")
        scanner.scanHexInt32(&hexInt)
        
        return hexInt
    }
    
    // 'parameter' could be the X and Y coordinates or Width and Height dimensions for iPhone 7 stored in 'Frames.plist' file.
    // For the others iPhones devices the X, Y, Width or Height parameters are estimated with a cross multiplication depending
    // on the current screen iPhone dimensions device
    fileprivate static func crossMultiplicationWithParameter(param: Double, paramType: ParamType) -> Double {
        
        var parameter: Double = 0.0
        var screenDimension: Double = 0.0
        var kScreenDimension: Double = 0.0
        
        switch paramType {
        case ParamType.xCoordOrWidthDim:
            screenDimension = Double(UIScreen.main.bounds.width)
            kScreenDimension = Constants.Devices.kiPhone7Width
            break
        case ParamType.yCoordOrHeightDim:
            screenDimension = Double(UIScreen.main.bounds.height)
            kScreenDimension = Constants.Devices.kiPhone7Height
            break
        }
        
        if (screenDimension == kScreenDimension) {
            // iPhone 7 device
            parameter = param
        } else {
            // Others iPhone devices
            parameter = ceil((screenDimension * param) / kScreenDimension)
        }
        
        return parameter
    }
}
