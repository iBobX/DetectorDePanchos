//
//  ViewController.swift
//  DetectorDePanchos
//
//  Created by Roberto Antonio Berrospe Machin on 3/25/19.
//  Copyright © 2019 Ruta Internet. All rights reserved.
//

import UIKit
import CoreML
import Vision

//image picker delegate and navigation controller delegate needed
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imagePreview: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set image picker delegate
        imagePicker.delegate = self
        //set source to camera (take photo)
        imagePicker.sourceType = .camera
        //don't allow editing
        imagePicker.allowsEditing = false
    }

    @IBAction func cameraActionTapped(_ sender: Any) {
        //show image picker
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //try to get the image taken by the camera
        if let userSelectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //assign to the image view
            imagePreview.image = userSelectedImage
            
            //call our detect function passing the image
            detect(image: userSelectedImage)
            
        }
        //close the image picker
        picker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: UIImage){
        //generate core image
        guard let ciImage = CIImage(image: image) else {
            //if wasn't able to generate, fatal error...
            fatalError("No se pudo convertir a CIImage")
        }
        //instantiate the Model as hotdogsDetectorModel
        guard let hotdogsDetectorModel = try? VNCoreMLModel(for: Resnet50().model) else {
            fatalError("Error instanciating HotdogsImageClassifier")
        }
        //Create the request using the neew model instance
        //with the closure that will process the result
        let request = VNCoreMLRequest(model: hotdogsDetectorModel) {
            (request, error) in
            if error == nil {
                guard let results = request.results as? [VNClassificationObservation] else {
                    fatalError("Error getting CoreML request results")
                }
                print(results)
                if let firstResult = results.first {
                    let navBar = self.navigationController?.navigationBar
                    if firstResult.identifier.contains("hotdog") == true && firstResult.confidence >= 0.4 {
                        navBar?.backgroundColor = UIColor.green
                        self.title = "¡Puedo ver un pancho! 🌭🙋🏻‍♂️"
                    } else {
                        self.title = "¿Yo no veo un pancho? 🤷🏻‍♂️"
                        navBar?.backgroundColor = UIColor.yellow
                    }
                }
            } else {
                fatalError("Error requesting CoreML")
            }
        }
        
        //now create the vision image request using thepassed image
        let handler = VNImageRequestHandler(ciImage: ciImage)
        
        do {
          //and apply the detection request
          try handler.perform([request])
        } catch {
            fatalError("Error trying to perform CoreML request. \(error)")
        }
        
    }
    
}

