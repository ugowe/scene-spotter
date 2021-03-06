//
//  ViewController.swift
//  SceneSpotter
//
//  Created by Joseph Ugowe on 2/2/18.
//  Copyright © 2018 Joseph Ugowe. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var scene: UIImageView!
    @IBOutlet weak var answerLabel: UILabel!
    
    // MARK: - Properties
    let vowels: [Character] = ["a", "e", "i", "o", "u"]
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        guard let image = UIImage(named: "train_night") else {
            fatalError("no starting image")
        }
        
        scene.image = image
        
        guard let ciImage = CIImage(image: image) else {
            fatalError("couldn't convert UIImage to CIImage")
        }
        
        detectScene(image: ciImage)
    }
}

// MARK: - IBActions
extension ViewController {
    
    @IBAction func pickImage(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .savedPhotosAlbum
        present(pickerController, animated: true)
    }
    
/*
     The standard Vision workflow is to:
     1) Create a model
     2) Create one or more requests
     3) Create and run a request handler
 
*/
    func detectScene(image: CIImage) {
        answerLabel.text = "detecting scene..."
        
        // 1) Load the ML model through its general class
        guard let model = try? VNCoreMLModel(for: GoogLeNetPlaces().model) else {
            fatalError("Can't load Places ML model")
        }
        
        // 2) Create a Vision request with completion handler
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first else {
                fatalError("Unexpected result type from VNCoreMLRequest")
            }
            
            // Update UI on main queue
            let article = (self?.vowels.contains(topResult.identifier.first!))! ? "an" : "a"
            DispatchQueue.main.async { [weak self] in
                self?.answerLabel.text = "\(Int(topResult.confidence * 100))% it's \(article) \(topResult.identifier)"
            }
        }
        
        // 3) Run the Core ML GoogLeNetPlaces classifier on global dispatch queue
        let handler = VNImageRequestHandler(ciImage: image)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
        
/*
         VNImageRequestHandler is the standard Vision framework request handler; it isn’t specific to Core ML models. You give it the image that came into detectScene(image:) as an argument. And then you run the handler by calling its perform method, passing an array of requests. In this case, you have only one request.
         
         The perform method throws an error, so you wrap it in a try-catch.
 */
    }
    
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true)
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Couldn't load image from Photos")
        }
        
        scene.image = image
        
        guard let ciImage = CIImage(image: image) else {
            fatalError("couldn't convert UIImage to CIImage")
        }
        
        detectScene(image: ciImage)
    }
}

// MARK: - UINavigationControllerDelegate
extension ViewController: UINavigationControllerDelegate {
    
}






