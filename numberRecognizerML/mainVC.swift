//
//  mainVC.swift
//  numberRecognizerML
//
//  Created by Josh Jaslow on 4/9/18.
//  Copyright © 2018 Jaslow Enterprises. All rights reserved.
//

import UIKit
import Vision

class mainVC: UIViewController {

    @IBOutlet weak var canvas: CanvasView!
    @IBOutlet weak var digitLabel: UILabel!
    
    var requests = [VNRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVision()
    }
    
    func setupVision() {
        guard let visionModel = try? VNCoreMLModel(for: MNIST().model) else { fatalError("Can't load Vision ML model") }
        let classificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: self.handleClassification)
        
        self.requests = [classificationRequest]
    }
    
    func handleClassification(request: VNRequest, error: Error?) {
        guard let observations = request.results else { print("No Results"); return }
        
        let classifications = observations
            .flatMap({$0 as? VNClassificationObservation})
            .filter({$0.confidence > 0.8})
            .map({$0.identifier})
        
        DispatchQueue.main.async {
            self.digitLabel.text = classifications.first
        }
    }
    
    @IBAction func clearScreen(_ sender: UIButton) {
        canvas.clearCanvas()
    }
    
    @IBAction func recognizeDrawing(_ sender: UIButton) {
        let image = UIImage(view: canvas)
        let scaledImage = scaleImage(image: image, toSize: CGSize(width: 28, height: 28))
        
        let imageRequestHandler = VNImageRequestHandler(cgImage: scaledImage.cgImage!, options: [:])
        
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    func scaleImage(image: UIImage, toSize size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
}




