//
//  ResourcesManager.swift
//  RealMadridCFResourcesPod
//
//  Created by Borja González Jurado on 17/6/16.
//  Copyright © 2016 Borja González Jurado. All rights reserved.
//

import Foundation
import UIKit
import CoreText


open class ResourcesManager {
    
    enum ParamType: Int {
        case xCoordOrWidthDim
        case yCoordOrHeightDim
    }
    
    public enum ResourcesManagerError: Error {
        case getBundleError
        case getClassWithNameError
        case getViewAutoresizingWithIdError
        case getColorWithNameError
        case getColorForViewWithNameError
        case getFontWithNameError
        case getImageForViewWithNameError
        case getTextWithIdError
        case getAudioWithIdError
        case getVideoWithIdError
        case getViewCoordinatesWithIdError
        case getViewDimensionsWithIdError
        case loadAvailableFontsError
        case parsingJSONError
        case getAutoresizingWithTypeError
        case getDictionaryFromPlistWithNameError
        case getImageFileNameWithNameError
        case getKeyForInterfaceOrientationError
        case getFontSizeError
        case getResourcePathError
        case intFromHexStringError
        case crossMultiplicationWithParameterError
    }
    
    
    // MARK: - Public methods
    
    open static func handleError(_ error: ResourcesManagerError) {
        
        var functionName = ""
        
        switch error {
        case .getBundleError:
            functionName = "getBundle"
        case .getClassWithNameError:
            functionName = "getClassWithName"
        case .getViewAutoresizingWithIdError:
            functionName = "getViewAutoresizingWithId"
        case .getColorWithNameError:
            functionName = "getColorWithName"
        case .getColorForViewWithNameError:
            functionName = "getColorForViewWithName"
        case .getFontWithNameError:
            functionName = "getFontWithName"
        case .getImageForViewWithNameError:
            functionName = "getImageForViewWithName"
        case .getTextWithIdError:
            functionName = "getTextWithId"
        case .getAudioWithIdError:
            functionName = "getAudioWithId"
        case .getVideoWithIdError:
            functionName = "getVideoWithId"
        case .getViewCoordinatesWithIdError:
            functionName = "getViewCoordinatesWithId"
        case .getViewDimensionsWithIdError:
            functionName = "getViewDimensionsWithId"
        case .loadAvailableFontsError:
            functionName = "loadAvailableFonts"
        case .parsingJSONError:
            functionName = "parsingJSON"
        case .getAutoresizingWithTypeError:
            functionName = "getAutoresizingWithType"
        case .getDictionaryFromPlistWithNameError:
            functionName = "getDictionaryFromPlistWithName"
        case .getImageFileNameWithNameError:
            functionName = "getImageFileNameWithName"
        case .getKeyForInterfaceOrientationError:
            functionName = "getKeyForInterfaceOrientation"
        case .getFontSizeError:
            functionName = "getFontSize"
        case .getResourcePathError:
            functionName = "getResourcePath"
        case .intFromHexStringError:
            functionName = "intFromHexString"
        case .crossMultiplicationWithParameterError:
            functionName = "crossMultiplicationWithParameter"
        default:
            print("Unknow error")
        }
        
        if !functionName.isEmpty { print("Throwed error in function with name \(functionName)") }
    }
    
    // Returns the bundle app
    open static func getBundle() throws -> Bundle {
        
        guard let bundle = Bundle(url: try getResourcePath()) else {
            throw ResourcesManagerError.getBundleError
        }
        
        return bundle
    }
    
    // Returns any class
    open static func getClassWithName(_ className: String) throws -> AnyClass {
        
        guard let bundle = Bundle(url: try getResourcePath()),
            let classURL = bundle.url(forResource: className, withExtension: nil),
            let classData = try? Data(contentsOf: classURL),
            let objectClass = type(of: classData) as? AnyClass else {
                throw ResourcesManagerError.getClassWithNameError
        }
        
        return objectClass
    }
    
    // Returns Autoresizing
    open static func getViewAutoresizingWithId(_ autoresizingId: String, orientation: UIInterfaceOrientation, viewControllerName: String) throws -> UIViewAutoresizing {
        
        let orientationKey = try getKeyForInterfaceOrientation(orientation)
        let framesDict = try getDictionaryFromPlistWithName(Constants.Files.framesPlist)
        let keyValue = Constants.KeyWords.framesKey + "." +
            viewControllerName + "." +
            autoresizingId + "." +
            orientationKey + "." +
            Constants.KeyWords.autoresizingKey
        
        guard let autoresizingConfiguration = framesDict[keyPath: keyValue] as? String else {
            throw ResourcesManagerError.getViewAutoresizingWithIdError
        }
        
        var currentAutoresizing = UIViewAutoresizing()
        let autoresizingArray = autoresizingConfiguration.components(separatedBy: "|")
        for autoresizingType in autoresizingArray {
            currentAutoresizing.insert(try getAutoresizingWithType(autoresizingType))
        }
        
        return currentAutoresizing
    }
    
    // Returns color for the given color name in the view controller, according to pod
    open static func getColorWithName(_ colorName: String, viewControllerName: String) throws -> UIColor {
        
        return try getColorForViewWithName(colorName, viewControllerName: viewControllerName)
    }
    
    // Returns color from Plist
    open static func getColorForViewWithName(_ viewName: String, viewControllerName: String) throws -> UIColor {
        
        let colorsDict = try getDictionaryFromPlistWithName(Constants.Files.colorsPlist)
        let keyValue = Constants.KeyWords.colorsKey + "." + viewControllerName + "." + viewName
        guard let hexCode = colorsDict[keyPath: keyValue] as? String else {
            throw ResourcesManagerError.getColorForViewWithNameError
        }
        
        let hexInt = try intFromHexString(hexCode)
        let color = UIColor(red:((CGFloat) ((hexInt & 0xFF0000) >> 16)) / 255,
                            green:((CGFloat) ((hexInt & 0xFF00) >> 8)) / 255,
                            blue:((CGFloat) (hexInt & 0xFF)) / 255,
                            alpha:1.0)
        
        return color
    }
    
    // Returns font
    open static func getFontWithName(_ fontName: String, fontSize: String, viewControllerName: String) throws -> UIFont {
        
        let size = try getFontSize(fontSize, viewControllerName: viewControllerName)
        let fontsDict = try getDictionaryFromPlistWithName(Constants.Files.fontsPlist)
        let keyValue = Constants.KeyWords.fontsKey + "." + viewControllerName + "." + fontName
        guard let name = fontsDict[keyPath: keyValue] as? String else {
            throw ResourcesManagerError.getFontWithNameError
        }
        
        guard let font = UIFont(name: name, size: size) else {
            guard let font = UIFont(name: name.stringByDeletingPathExtension, size: size) else {
                return UIFont.systemFont(ofSize: size)
            }
            
            return font
        }
        
        return font
    }
    
    // Returns an image for a particular view controller
    open static func getImageForViewWithName(_ imageName: String, screenScale: CGFloat, viewControllerName: String) throws -> UIImage {
        
        let imagesDict = try getDictionaryFromPlistWithName(Constants.Files.imagesPlist)
        let keyValue = Constants.KeyWords.imagesKey + "." + viewControllerName + "." + imageName
        guard let imgName = imagesDict[keyPath: keyValue] as? String,
            let bundle = Bundle(url: try getResourcePath()),
            let imageURL = bundle.url(forResource: imgName, withExtension: nil),
            let imageData = try? Data(contentsOf: imageURL),
            let image = UIImage(data: imageData, scale: screenScale) else {
                throw ResourcesManagerError.getImageForViewWithNameError
        }
        
        return image
    }
    
    // Returns text
    open static func getTextWithId(_ textId: String, viewControllerName: String) throws -> String {
        
        let textsDict = try getDictionaryFromPlistWithName(Constants.Files.textsPlist)
        let keyValue = Constants.KeyWords.textsKey + "." + viewControllerName + "." + textId
        guard let text = textsDict[keyPath: keyValue] as? String else {
            throw ResourcesManagerError.getTextWithIdError
        }
        
        return text
    }
    
    // Returns URL from audio
    open static func getAudioWithId(_ audioId: String, viewControllerName: String) throws -> URL {
        
        let audiosDict = try getDictionaryFromPlistWithName(Constants.Files.audiosPlist)
        let keyValue = Constants.KeyWords.audiosKey + "." + viewControllerName + "." + audioId
        guard let audioName = audiosDict[keyPath: keyValue] as? String,
            let bundle = Bundle(url: try getResourcePath()),
            let audioURL = bundle.url(forResource: audioName, withExtension: nil) else {
                throw ResourcesManagerError.getAudioWithIdError
        }
        
        return audioURL
    }
    
    // Returns URL from video
    open static func getVideoWithId(_ videoId: String, viewControllerName: String) throws -> URL {
        
        let videosDict = try getDictionaryFromPlistWithName(Constants.Files.videosPlist)
        let keyValue = Constants.KeyWords.videosKey + "." + viewControllerName + "." + videoId
        guard let videoName = videosDict[keyPath: keyValue] as? String,
            let bundle = Bundle(url: try getResourcePath()),
            let videoURL = bundle.url(forResource: videoName, withExtension: nil) else {
                throw ResourcesManagerError.getVideoWithIdError
        }
        
        return videoURL
    }
    
    // Returns view coordinates (x, y)
    open static func getViewCoordinatesWithId(_ coordinatesId: String, orientation: UIInterfaceOrientation, viewControllerName: String) throws -> [Double] {
        
        let orientationKey = try getKeyForInterfaceOrientation(orientation)
        let framesDict = try getDictionaryFromPlistWithName(Constants.Files.framesPlist)
        
        let xPath = Constants.KeyWords.framesKey + "." +
            viewControllerName + "." +
            coordinatesId + "." +
            orientationKey + "." +
            Constants.KeyWords.xKey
        
        let yPath = Constants.KeyWords.framesKey + "." +
            viewControllerName + "." +
            coordinatesId + "." +
            orientationKey + "." +
            Constants.KeyWords.yKey
        
        guard let xCoord = framesDict[keyPath: xPath] as? AnyObject,
            let yCoord = framesDict[keyPath: yPath] as? AnyObject else {
                throw ResourcesManagerError.getViewCoordinatesWithIdError
        }
        
        let x = try crossMultiplicationWithParameter(param: Double(xCoord.floatValue), paramType: ParamType.xCoordOrWidthDim)
        let y = try crossMultiplicationWithParameter(param: Double(yCoord.floatValue), paramType: ParamType.yCoordOrHeightDim)
        
        return [x, y]
    }
    
    // Returns view dimensions (width, height)
    open static func getViewDimensionsWithId(_ dimensionsId: String,
                                             orientation: UIInterfaceOrientation,
                                             viewControllerName: String) throws -> [Double] {
        
        let orientationKey = try getKeyForInterfaceOrientation(orientation)
        let framesDict = try getDictionaryFromPlistWithName(Constants.Files.framesPlist)
        
        let widthPath = Constants.KeyWords.framesKey + "." +
            viewControllerName + "." +
            dimensionsId + "." +
            orientationKey + "." +
            Constants.KeyWords.widthKey
        
        let heightPath = Constants.KeyWords.framesKey + "." +
            viewControllerName + "." +
            dimensionsId + "." +
            orientationKey + "." +
            Constants.KeyWords.heightKey
        
        guard let width = framesDict[keyPath: widthPath] as? AnyObject,
            let height = framesDict[keyPath: heightPath] as? AnyObject else {
                throw ResourcesManagerError.getViewDimensionsWithIdError
        }
        
        let w = try crossMultiplicationWithParameter(param: Double(width.floatValue), paramType: ParamType.xCoordOrWidthDim)
        let h = try crossMultiplicationWithParameter(param: Double(height.floatValue), paramType: ParamType.yCoordOrHeightDim)
       
        return [w, h]
    }
    
    // Loads the font files
    open static func loadAvailableFonts() throws -> Void {
        
        let fontsDict = try getDictionaryFromPlistWithName(Constants.Files.availableFontsPlist)
        guard let fontsArray = (fontsDict[keyPath: Constants.KeyWords.fontsKey] as? AnyObject)?.allValues else {
            throw ResourcesManagerError.loadAvailableFontsError
        }
        
        for (_, value) in fontsArray.enumerated() {
            
            if let fontName = value as? String,
                let bundle = Bundle(url: try getResourcePath()),
                let fontURL = bundle.url(forResource: fontName, withExtension: nil) {
                
                let url = fontURL as! CFURL
                var errorRef: Unmanaged<CFError>?
                _ = CTFontManagerRegisterFontsForURL(url, .process, &errorRef)
                
                if errorRef != nil {
                    _ = errorRef!.takeRetainedValue()
                }
            }
        }
    }
    
    // Parse a JSON file and returns data
    open static func parsingJSON() throws -> [String : Any] {
        
        guard let bundle = Bundle(url: try getResourcePath()),
            let jsonURL = bundle.url(forResource: Constants.Files.trophiesJson, withExtension: nil),
            let data = try? Data(contentsOf: jsonURL),
            let jsonData = try? JSONSerialization.jsonObject(with: data) as! [String : Any] else {
                throw ResourcesManagerError.parsingJSONError
        }
        
        return jsonData
    }
    
    
    // MARK: - Private methods
    
    // Returns UIViewAutoresizing
    fileprivate static func getAutoresizingWithType(_ autoresizingType: String) throws -> UIViewAutoresizing {
        
        let autoresizingParamsArray = [".flexibleLeftMargin",
                                       ".flexibleRightMargin",
                                       ".flexibleTopMargin",
                                       ".flexibleBottomMargin",
                                       ".flexibleHeight",
                                       ".flexibleWidth",
                                       ".none"]
        
        var currentAutoresizing: UIViewAutoresizing
        
        guard let index: Int = autoresizingParamsArray.index(of: autoresizingType) else {
            throw ResourcesManagerError.getAutoresizingWithTypeError
        }
        
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
    fileprivate static func getDictionaryFromPlistWithName(_ plistName: String) throws -> [String : AnyObject] {
        
        guard let bundle = Bundle(url: try getResourcePath()) else {
            throw ResourcesManagerError.getDictionaryFromPlistWithNameError
        }
        
        let resource = plistName.stringByDeletingPathExtension
        let type = plistName.pathExtension
        
        guard !resource.isEmpty,
            !type.isEmpty,
            let plistFile = bundle.path(forResource: resource, ofType: type),
            !plistFile.isEmpty,
            let plistDictionary = NSDictionary(contentsOfFile:plistFile) else {
                 throw ResourcesManagerError.getDictionaryFromPlistWithNameError
        }
        
        return plistDictionary as! [String : AnyObject]
    }
    
    // Returns image file name with or without @2x added
    fileprivate static func getImageFileNameWithName(_ imageName: String, screenScale: CGFloat) throws -> String {
    
        guard imageName.isEmpty, imageName.count >= 5 else {
            throw ResourcesManagerError.getImageFileNameWithNameError
        }
        
        let index = imageName.characters.index(imageName.startIndex, offsetBy: imageName.count - 4)
        let name = imageName.substring(to: index)
        let fileName = screenScale == 2 ? String.localizedStringWithFormat("%@%@.%@", name, "@2x", imageName) : String.localizedStringWithFormat("%@.%@", name, imageName)
        
        return fileName
    }
    
    // Returns a string key according the current interface orientation
    fileprivate static func getKeyForInterfaceOrientation(_ orientation: UIInterfaceOrientation) throws -> String {
        
        let orientationKey: String
        
        switch orientation {
        case UIInterfaceOrientation.landscapeLeft, UIInterfaceOrientation.landscapeRight:
            orientationKey = "Landscape"
            break
        case UIInterfaceOrientation.unknown, UIInterfaceOrientation.portrait, UIInterfaceOrientation.portraitUpsideDown:
            orientationKey = "Portrait"
            break
        }
        
        return orientationKey
    }
    
    // Returns font size
    fileprivate static func getFontSize(_ kFontSize: String, viewControllerName: String) throws -> CGFloat {
        
        let fontsDict = try getDictionaryFromPlistWithName(Constants.Files.fontsPlist)
        let keyValue = Constants.KeyWords.fontsKey + "." + viewControllerName + "." + kFontSize
        guard let fontSize = fontsDict[keyPath: keyValue] as? CGFloat else {
            throw ResourcesManagerError.getFontSizeError
        }
        
        return fontSize
    }
    
    // Returns the base path
    fileprivate static func getResourcePath() throws -> URL {
        
        guard let path = Bundle.main.privateFrameworksPath else {
            throw ResourcesManagerError.getResourcePathError
        }
        
        let fileURL = URL(fileURLWithPath: path)
        let resourcePath = fileURL.appendingPathComponent(Constants.Files.framework).appendingPathComponent(Constants.Files.bundle)
        
        guard let resourceExists = try? resourcePath.checkResourceIsReachable() else {
            throw ResourcesManagerError.getResourcePathError
        }
        
        return resourcePath
    }
    
    // Converts hexadecimal String to CUnsignedInt
    fileprivate static func intFromHexString(_ hexStr: String) throws -> CUnsignedInt {
        
        var hexInt: CUnsignedInt = 0
        
        do {
            let scanner = Scanner(string:hexStr)
            scanner.charactersToBeSkipped = CharacterSet(charactersIn:"#")
            scanner.scanHexInt32(&hexInt)
        } catch {
            throw ResourcesManagerError.intFromHexStringError
        }
        
        return hexInt
    }
    
    // 'parameter' could be the X and Y coordinates or Width and Height dimensions for iPhone 7 stored in 'Frames.plist' file.
    // For the others iPhones devices the X, Y, Width or Height parameters are estimated with a cross multiplication depending
    // on the current screen iPhone dimensions device
    fileprivate static func crossMultiplicationWithParameter(param: Double, paramType: ParamType) throws -> Double {
        
        var parameter: Double = 0.0
        var screenDimension: Double = 0.0
        var kScreenDimension: Double = 0.0
        
        switch paramType {
        case ParamType.xCoordOrWidthDim:
            screenDimension = Double(UIScreen.main.bounds.width)
            kScreenDimension = Constants.Devices.iPhone7Width
            break
        case ParamType.yCoordOrHeightDim:
            screenDimension = Double(UIScreen.main.bounds.height)
            kScreenDimension = Constants.Devices.iPhone7Height
            break
        }
        
        // iPhone 7 device = param
        parameter = screenDimension == kScreenDimension ? param : ceil((screenDimension * param) / kScreenDimension)
        
        return parameter
    }
}
