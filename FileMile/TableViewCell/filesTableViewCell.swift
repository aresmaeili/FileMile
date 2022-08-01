//
//  TableViewCell.swift
//  FileMile
//
//  Created by AREM on 7/23/22.
//

import UIKit
import PDFKit

class filesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
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
        default:
            contentImageView.image = UIImage(named: "file")
            fileTypeLabel.text = data.pathExtension
            return
        }
    }
    
    func setupCell(){
        contentImageView.layer.cornerRadius = 25
    }
    
    func handlePdf(){
        
    }
}
