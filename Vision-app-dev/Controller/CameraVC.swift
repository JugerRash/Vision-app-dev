//
//  CameraVC.swift
//  Vision-app-dev
//
//  Created by juger rash on 12.09.19.
//  Copyright © 2019 juger rash. All rights reserved.
//

import UIKit
import AVFoundation // this lib will allow us to use the camera and all the functions

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
                captureSession.startRunning()
            }
            
        }catch {
            debugPrint(error)
        }
    }


}

