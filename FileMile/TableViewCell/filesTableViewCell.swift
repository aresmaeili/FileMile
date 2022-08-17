//
//  TableViewCell.swift
//  FileMile
//
//  Created by AREM on 7/23/22.
//

import UIKit
import PDFKit
import MarqueeLabel

class filesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var nameLabel: MarqueeLabel!
    @IBOutlet weak var fileTypeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
}

//MARK: - Functions
extension filesTableViewCell {
    func configureCell(data: URL){
        nameLabel.text = data.lastPathComponent.removingPercentEncoding
        switch data.pathExtension {
        case "":
            contentImageView.image = UIImage(named: "folder")
            fileTypeLabel.text = data.pathExtension
            return
        case "pdf":
            let thumbnailSize = CGSize(width: 100, height: 100)
            let thumbnail = generatePdfThumbnail(of: thumbnailSize, for: data, atPage: 0)
            contentImageView.image = thumbnail
            fileTypeLabel.text = data.pathExtension
        default:
            contentImageView.image = UIImage(named: "file")
            fileTypeLabel.text = data.pathExtension
            return
        }
    }
    
    func setupCell(){
        contentImageView.layer.cornerRadius = 10
    }

}

//MARK: - PDF Functions
extension filesTableViewCell {
    func generatePdfThumbnail(of thumbnailSize: CGSize , for documentUrl: URL, atPage pageIndex: Int) -> UIImage? {
        let pdfDocument = PDFDocument(url: documentUrl)
        let pdfDocumentPage = pdfDocument?.page(at: pageIndex)
        return pdfDocumentPage?.thumbnail(of: thumbnailSize, for: PDFDisplayBox.trimBox)
    }
}
