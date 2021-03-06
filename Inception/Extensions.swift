//
//  Extensions.swift
//  Inception
//
//  Created by Mihaela Miches on 6/17/17.
//  Copyright © 2017 me. All rights reserved.
//

import UIKit
import SceneKit

//MARK: - CVPixelBuffer
extension CVPixelBuffer {
    func resized(for kind: MLModelInput) -> CVPixelBuffer? {
        let image = UIImage(ciImage: CIImage(cvPixelBuffer: self))
        
        UIGraphicsBeginImageContextWithOptions(kind.size(), false, 0.0);
        image.draw(in: CGRect(origin: CGPoint.zero, size: kind.size()))
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        
        return resizedImage.pixelBuffer
    }
}

//MARK: - UIImage
extension UIImage {
    var pixelBuffer: CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}

//MARK: - Array
extension Array {
    func shuffled() -> Array {
        return sorted { _,_ in arc4random() < arc4random() }
    }
}

//MARK: - UIColor
extension UIColor {
    static var pink: UIColor {
        return UIColor(red: 0xF2 / 255.0, green: 0x6D / 255.0, blue: 0x7D / 255.0, alpha: 1.0)
    }
    
    static var faintPink: UIColor {
        return UIColor(red: 0xF2 / 255.0, green: 0x6D / 255.0, blue: 0x7D / 255.0, alpha: 0.5)
    }
}

//MARK: - CABasicAnimation
extension CABasicAnimation {
    static var spin: CABasicAnimation {
        let spin = CABasicAnimation(keyPath: "rotation")
        spin.fromValue = SCNVector4(0, 1, 0, 0)
        spin.toValue = SCNVector4(0, 1, 0, 2 * Double.pi)
        spin.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        spin.duration = 0.9
        spin.repeatCount = .infinity
        return spin
    }
}

//MARK: - String
extension String {
    func localised(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
}

// MARK: - UIViewController Thermal State
extension UIViewController {
    func addThermalStateObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(thermalStateChanged), name: ProcessInfo.thermalStateDidChangeNotification,    object: nil)
    }
    
    @objc func thermalStateChanged(notification: NSNotification) {
        if let processInfo = notification.object as? ProcessInfo {
            showThermalState(state: processInfo.thermalState)
        }
    }
    
    func checkTermalState() {
        let initialThermalState = ProcessInfo.processInfo.thermalState
        if initialThermalState == .serious || initialThermalState == .critical {
            showThermalState(state: initialThermalState)
        }
    }
    
    func showThermalState(state: ProcessInfo.ThermalState) {
        DispatchQueue.main.async {
            var thermalState = "UNKNOWN"
            if state == .nominal {
                thermalState = "it's cool"
            } else if state == .fair {
                thermalState = "fairly warm"
            } else if state == .serious {
                thermalState = "hot af"
            } else if state == .critical {
                thermalState = "your phone is about to blow up. Go outside and get some air, nerd!"
            }
            
            let alertController = UIAlertController(title: "ThermalState", message: thermalState.localised(), preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "mkay".localised(), style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
