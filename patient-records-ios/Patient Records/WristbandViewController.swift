//
//  WristbandViewController.swift
//  Patient Records
//
//  Created by Lukas Valine on 1/28/17.
//  Copyright © 2017 Lukas Valinevaline. All rights reserved.
//

import UIKit

import CoreImage

class WristbandViewController: UIViewController {

    
    var qrcode: CIImage?
    
    var idValue: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        print(String(idValue) + "in wristband")
        let listPatientsRequest = "patient/id/" + String(idValue)
        let url = ServerSettings.sharedInstance.getServerAddress().appendingPathComponent(listPatientsRequest)
        

        let data = url.absoluteString.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        
        qrcode = filter?.outputImage
       
        let wristBandView = WristbandView()
        
        let scaleX = wristBandView.imageView.frame.size.width / (qrcode?.extent.size.width)!
        let scaleY = wristBandView.imageView.frame.size.height / (qrcode?.extent.size.height)!
        
        let transformedImage = qrcode?.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))

        
        wristBandView.imageView.image = UIImage(ciImage: transformedImage!)

        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary:nil)
        
        printInfo.outputType = UIPrintInfoOutputType.general
        printInfo.jobName = "print Job"
        printController.printInfo = printInfo
        printController.printingItem = toPDF(views: [imageView])
 
        printController.present(animated: true, completionHandler: nil)
    
    
    }
    
    private func toPDF(views: [UIView]) -> NSData? {
        
        if views.isEmpty {
            return nil
        }
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRect(x: 0, y: 0, width: 612, height: 792), nil)
        
        let context = UIGraphicsGetCurrentContext()
        
        for view in views {
            UIGraphicsBeginPDFPage()
            view.layer.render(in: context!)
        }
        
        UIGraphicsEndPDFContext()
        
        return pdfData
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var imageView: UIImageView!

    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: {})
    }

}
