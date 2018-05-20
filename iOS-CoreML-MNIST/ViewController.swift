//
//  ViewController.swift
//  iOS-CoreML-MNIST
//
//  Created by Sri Raghu Malireddi on 15/06/17.
//  Copyright © 2017 Sri Raghu Malireddi. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController {
    
    
    @IBOutlet weak var drawView: DrawView!
    @IBOutlet weak var predictLabel: UILabel!
    
    let model = mnistCNN()
    var inputImage: CGImage!
    var cnt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        predictLabel.isHidden = true
    }
    
    @IBAction func tappedClear(_ sender: Any) {
        drawView.lines = []
        drawView.setNeedsDisplay()
        predictLabel.isHidden = true
        drawView.initialize_var()
    }
    
    @IBAction func tappedDetect(_ sender: Any) {
        let context = drawView.getViewContext()
        
        /*
        let a = drawView.draw
        a?.contentMode = UIViewContentMode.center
        a?.clipsToBounds = true
        */
        
        inputImage = context?.makeImage()
        let pixelBuffer = UIImage(cgImage: inputImage).pixelBuffer()
        let output = try? model.prediction(image: pixelBuffer!)
        
        //let before_center = (UIImage(cgImage: inputImage))
        //var after_center = UIImageView(image: before_center)
        
        /*
        after_center.contentMode = UIViewContentMode.center
        after_center.clipsToBounds = true
        
        after_center.contentMode = UIViewContentMode.scaleAspectFill
        after_center.clipsToBounds = true
        */
        
        //let final = image(with: a!)
        
        
        
        predictLabel.text = output?.classLabel
        predictLabel.isHidden = false
        
        
        var file_name = "copy" + String(cnt) + ".png"
        if let data = UIImagePNGRepresentation(UIImage(cgImage: inputImage)) {
            let filename = getDocumentsDirectory().appendingPathComponent(file_name)
            cnt += 1
            try? data.write(to: filename)
            print(filename)
        }
        
        
        //var _: Data = UIImagePNGRepresentation(UIImage(cgImage: inputImage))!
        //print(i)
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension UIImage {
    func pixelBuffer() -> CVPixelBuffer? {
        let width = self.size.width
        let height = self.size.height
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(width),
                                         Int(height),
                                         kCVPixelFormatType_OneComponent8,
                                         attrs,
                                         &pixelBuffer)
        
        
        
        
        
        guard let resultPixelBuffer = pixelBuffer, status == kCVReturnSuccess else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(resultPixelBuffer)
        
        let grayColorSpace = CGColorSpaceCreateDeviceGray()
        guard let context = CGContext(data: pixelData,
                                      width: Int(width),
                                      height: Int(height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(resultPixelBuffer),
                                      space: grayColorSpace,
                                      bitmapInfo: CGImageAlphaInfo.none.rawValue) else {
                                        return nil
        }
        
        context.translateBy(x: 0, y: height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        
        
        CVPixelBufferUnlockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return resultPixelBuffer
    }
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

func image(with view: UIView) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
    defer { UIGraphicsEndImageContext() }
    if let context = UIGraphicsGetCurrentContext() {
        view.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
    return nil
}

