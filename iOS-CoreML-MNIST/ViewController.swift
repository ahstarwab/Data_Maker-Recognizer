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
    
    var cnt = 40
    
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
        
        
        inputImage = context?.makeImage()
        
        let rect = drawView.return_max_min()
        let pic2 = cropImage(UIImage(cgImage: inputImage), toRect: rect!, viewWidth: 28, viewHeight: 28)
        let pic = resizeImage(image: pic2!, newWidth: 28)
        let pixelBuffer = pic.pixelBuffer()
        let output = try? model.prediction(image: pixelBuffer!)
        let accuracy =  output?.output
        

        predictLabel.text = output?.classLabel
       
        predictLabel.isHidden = false
       
        
        if let data = UIImagePNGRepresentation(pic) {
            let filename = getDocumentsDirectory().appendingPathComponent("2pop.png")
            try? data.write(to: filename)
            print(filename)
        }
                       
        /*
        var file_name = "copy" + String(cnt) + ".png"
        if let data = UIImagePNGRepresentation(UIImage(cgImage: inputImage)) {
            let filename = getDocumentsDirectory().appendingPathComponent(file_name)
            cnt += 1
            try? data.write(to: filename)
            print(filename)
        }
    */
        
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


//func rotateImage(_ InputImage: UIImage,)


func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage?
{
    //let imageViewScale = max(viewWidth / inputImage.size.width,
    //                         viewHeight / inputImage.size.height)
    let imageViewScale = CGFloat(1)
    print(cropRect)
    // Scale cropRect to handle images larger than shown-on-screen size
    let cropZone = CGRect(x:cropRect.origin.x * imageViewScale,
                          y:cropRect.origin.y * imageViewScale,
                          width:cropRect.size.width * imageViewScale,
                          height:cropRect.size.height * imageViewScale)
    
    print(cropZone)
    // Perform cropping in Core Graphics
    guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropZone)
        else {
            return nil
    }
    
    // Return image to UIImage
    let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
    return croppedImage
}

func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
    
    let newHeight = newWidth
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}






