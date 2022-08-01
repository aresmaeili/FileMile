//
//  PdfViewController.swift
//  FileMile
//
//  Created by AREM on 8/1/22.
//

import Foundation
import UIKit
import PDFKit

class PdfViewController: UIViewController{
    
    let pdfView = PDFView()
    var pdfUrl: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pdfFileSetup(fileUrl: pdfUrl)
    }
}

//MARK: - Functions
extension PdfViewController{
    
    func pdfFileSetup(fileUrl: URL){
        pdfView.delegate = self
        view.addSubview(pdfView)
        pdfView.frame = view.bounds
        guard let document = PDFDocument(url: fileUrl) else { return }
        pdfView.document = document
        pdfView.autoScales = true
        pdfView.maxScaleFactor = 4.0
        pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit 
    }
}

//MARK: - PDF Delegates
extension PdfViewController: PDFViewDelegate{

}

