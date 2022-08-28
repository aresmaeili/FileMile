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
        createMenu()
    }
}

//MARK: - Functions
extension PdfViewController: PDFViewDelegate{
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
extension PdfViewController{
    private func createMenu() {
        let highlightItem = UIMenuItem(title: "Highlight", action: #selector(highlight(_:)))
        UIMenuController.shared.menuItems = [highlightItem]
    }
        
    @objc private func highlight(_ sender: UIMenuController?) {
        guard let currentSelection = pdfView.currentSelection else { return }
        let selections = currentSelection.selectionsByLine()
        guard let page = selections.first?.pages.first else { return }

        selections.forEach { selection in
            let highlight = PDFAnnotation(bounds: selection.bounds(for: page), forType: .highlight, withProperties: nil)
            highlight.endLineStyle = .square
            page.addAnnotation(highlight)
        }
        pdfView.clearSelection()
    }
}

