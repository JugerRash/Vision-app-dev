//
//  CameraVC.swift
//  Vision-app-dev
//
//  Created by juger rash on 12.09.19.
//  Copyright © 2019 juger rash. All rights reserved.
//

import UIKit
import AVFoundation // this lib will allow us to use the camera and all the functions
import CoreML // this will allow us to use the basic functions of ML
import Vision // this is resposible about objects and things

//this enum just for the status of the flash light
enum FlashState {
    case off
    case on
}


class CameraVC: UIViewController {
    
    //Outlets -:
    @IBOutlet private weak var cameraView : UIView!
    @IBOutlet private weak var captureImageView : RoundedShadowImageView!
    @IBOutlet private weak var flashBtn : RoundedShadowButton!
    @IBOutlet private weak var identificationLbl : UILabel!
    @IBOutlet private weak var confidenceLbl : UILabel!
    @IBOutlet private weak var roundedLblView : RoundedShadowView!

    //Variables -:
    //first of all when u want to use the camera u ness 3 variables
    var captureSession : AVCaptureSession!// this take the input for the devices and getting the output from it
    var cameraOutput : AVCapturePhotoOutput! // To hanlde the output of the capture session
    var previewLayer : AVCaptureVideoPreviewLayer!// this to show the camera on the view
    var photoData : Data? // to get the photo that captured
    var flashControlState : FlashState = .off
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer.frame = cameraView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCameraView))
        tap.numberOfTapsRequired = 1
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080 // this to take all the screen size
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            //first we have to check if we cann add an input to our device
            let input = try AVCaptureDeviceInput(device: backCamera!)
            if captureSession.canAddInput(input) == true {
                captureSession.addInput(input)
            }
            
            cameraOutput = AVCapturePhotoOutput()
            
            //second we have to check if we can add output to our device ad our device is the backCamera
            if captureSession.canAddOutput(cameraOutput!) {
                captureSession.addOutput(cameraOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                
                cameraView.layer.addSublayer(previewLayer)
                cameraView.addGestureRecognizer(tap)
                captureSession.startRunning()
            }
            
        }catch {
            debugPrint(error)
        }
        
        
    }
    
   @objc func didTapCameraView(){
        let settings = AVCapturePhotoSettings()
    //the next two lines are in the old swift
    //        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first! // this will take the generic photo of ios
//        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String : previewPixelType , kCVPixelBufferWidthKey as String : 160 , kCVPixelBufferHeightKey as String : 160 ] // this to take a small size of the captured image
    
        settings.previewPhotoFormat = settings.embeddedThumbnailPhotoFormat
    if flashControlState == .off {
        settings.flashMode = .off
    }else {
        settings.flashMode = .on
    }
    
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func resultMethod(request : VNRequest , error : Error?){
        guard let results = request.results as? [VNClassificationObservation] else {
            return
        }
        
        for classification in results {
            if classification.confidence < 0.5 {
                self.identificationLbl.text = "I'm not sure what is this is.please try again"
                self.confidenceLbl.text = ""
                break
            }else {
                self.identificationLbl.text = classification.identifier
                self.confidenceLbl.text = "CONFIDENCE: \(Int(classification.confidence * 100 ))%"
                break
            }
        }
        
    }
    
    //Actions -:
    @IBAction func flashBtnWasPressed(_ sender : Any) {
        switch flashControlState {
        case .off :
            self.flashControlState = .on
            self.flashBtn.setTitle("FLASH ON", for: .normal)
        case .on :
            self.flashControlState = .off
            self.flashBtn.setTitle("FLASH OFF", for: .normal)
        }
    }

}

extension CameraVC : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            debugPrint(error)
        }else {
            photoData = photo.fileDataRepresentation()
            let image = UIImage(data: photoData!)
            
            do{
                let model = try VNCoreMLModel(for: SqueezeNet().model) // this is the brain of the Model
                let request = VNCoreMLRequest(model: model, completionHandler: resultMethod(request:error:))//this is the thought of our training
                let handler = VNImageRequestHandler(data: photoData!) // this for anlyze the photo and give us the results
                try handler.perform([request])
            }catch {
                debugPrint(error)
            }
            
            
            self.captureImageView.image = image
        }
    }
}

