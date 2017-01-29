//
//  SearchViewController.swift
//  Patient Records
//
//  Created by Lukas Valine on 10/2/16.
//  Copyright © 2016 Lukas Valinevaline. All rights reserved.
//

import UIKit

import AVFoundation

class SearchViewController: UIViewController,
AVCaptureMetadataOutputObjectsDelegate {

    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    @IBOutlet weak var scanParentView: UIView!
    let videoRadius: CGFloat = 7

       // Added to support different barcodes
    let supportedBarCodes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode]


    override func viewDidLoad() {
        super.viewDidLoad()

        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)

            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
        
            // Set the input device on the capture session.
            captureSession?.addInput(input)

            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)

            // Detect all the supported bar code
            captureMetadataOutput.metadataObjectTypes = supportedBarCodes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            let viewBounds = scanParentView.layer.bounds
            videoPreviewLayer?.frame = viewBounds

            videoPreviewLayer?.cornerRadius = videoRadius
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            scanParentView.layer.addSublayer(videoPreviewLayer!)
            updateVideoOrientation()
            
            // Start video capture
            captureSession?.startRunning()

            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            } else {
                print("no frame view :(")
            }
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }

    }
    
    func updateVideoOrientation() {
        
        
        let orientation: UIDeviceOrientation = UIDevice.current.orientation
        
        if orientation == .portrait {

            let rotate = CGAffineTransform(rotationAngle: 0.0 * 3.14/180.0)
            videoPreviewLayer?.setAffineTransform(rotate)
            
            let viewBounds = scanParentView.layer.bounds
            videoPreviewLayer?.frame = viewBounds
            
        } else if orientation == .landscapeLeft {

            let rotate = CGAffineTransform(rotationAngle: -90.0 * 3.14/180.0)
            videoPreviewLayer?.setAffineTransform(rotate)
            
            let viewBounds = scanParentView.layer.bounds
            videoPreviewLayer?.frame = viewBounds
            
            
        } else if orientation == .landscapeRight {

            let rotate = CGAffineTransform(rotationAngle: 90.0 * 3.14/180.0)
            videoPreviewLayer?.setAffineTransform(rotate)
            
            let viewBounds = scanParentView.layer.bounds
            videoPreviewLayer?.frame = viewBounds
            
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
//            messageLabel.text = "No QR code is detected"
            print("no qrcode detected")
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            qrCodeFrameView?.frame = barCodeObject.bounds;
            
            if metadataObj.stringValue != nil {
                
                print(metadataObj.stringValue)
               
                let url = URL(string: metadataObj.stringValue)
                let id = url?.lastPathComponent
                
                presentPatient(idString: id!)
                captureSession?.stopRunning()
                qrCodeFrameView?.frame = CGRect.zero
               // print(id!)
                //messageLabel.text = metadataObj.stringValue
            }
        }
    }
    
    func presentPatient(idString: String ) {
        

            let id = Int(idString)
                
        
        
        print(id!)
            PatientRespository.getPatientById(id: id!, completion: {(patient) in
                
                let controller = CreatePatientViewController()
                
                //            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                // It is instance of  `NewViewController` from storyboard
                let nc: UINavigationController = storyboard.instantiateViewController(withIdentifier: "create-nav") as! UINavigationController
                let pvc = nc.topViewController as! CreatePatientViewController
              
                pvc.patientDictionary = patient
                //pvc.patientDictionaryToSave = patient
                pvc.obscure = true
                
                self.navigationController?.pushViewController(pvc, animated: true)
                //self.present(nc, animated: true, completion: {})
                pvc.mode = .view
                //nc.navigationItem.setHidesBackButton(true, animated:true);
                
               // controller.obscure = false
               // controller.tableView.reloadData();
            }, debug: {(debug) in })
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if captureSession != nil {
            
            captureSession?.startRunning()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        updateVideoOrientation()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    @IBOutlet weak var scanAnimationContainer: NestableUIView!
    
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
