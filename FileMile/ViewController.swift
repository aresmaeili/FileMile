//
//  ViewController.swift
//  FileMile
//
//  Created by AREM on 7/23/22.
//

import UIKit
import PDFKit

enum sortType {
    case nameAsc,nameDesc,dateAsc,dateDesc
}

class ViewController: UIViewController {
    
    @IBOutlet weak var filesTableView: UITableView!
    
    var sortingType : sortType = .nameAsc {
        didSet{
            sortingBy(sortBy: sortingType)
        }
    }
    let fileManager = FileManager.default
    var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    var fileURLs : [URL] = []{
        didSet{
            filesTableView.reloadData()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createDirectory(FolderName: "FileMile")
        setupFileManager(url: documentsURL)
        setupTableView()
//        sortingBy(sortBy: sortingType)
    }
}

//MARK: - Functions
extension ViewController{
    func createDirectory(FolderName: String){
        
        guard let url = FileManager.default.urls(for: .documentDirectory , in: .userDomainMask).first else { return }
        let newFolder = url.appendingPathComponent("\(FolderName)")
        do{
            if !FileManager.default.fileExists(atPath: newFolder.path) {
                try FileManager.default.createDirectory(at: newFolder, withIntermediateDirectories: true, attributes: [:])
            }
        }catch{
            print("ERROR --> Create Directory \(newFolder.path)")
        }
    }
    
    func setupFileManager(url: URL){
        let addItem = UIBarButtonItem(title: "Import", style: .plain, target: self, action: #selector(addTapped))
        let sortItem = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(sortTapped))
        navigationItem.rightBarButtonItems =  [addItem,sortItem]
        self.title = url.lastPathComponent.removingPercentEncoding
        sortingBy(sortBy: sortingType)
        }
    
    @objc func addTapped(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddViewController") as! AddViewController
        vc.url = documentsURL
        vc.delegate = self
        navigationController?.present(vc, animated: true)
    }
    
    @objc func sortTapped(){
        let alert = UIAlertController(title: "Sort by:" , message: "", preferredStyle: .actionSheet)
        let sortByNameAscAction = UIAlertAction(title: "Name Asc", style: .default) {
               UIAlertAction in
            self.sortingType = .nameAsc
           }
        let sortByNameDescAction = UIAlertAction(title: "Name Desc", style: .default) {
               UIAlertAction in
            self.sortingType = .nameDesc
           }
        let sortByDateAscAction = UIAlertAction(title: "Date Asc", style: .default) {
               UIAlertAction in
            self.sortingType = .dateAsc
           }
        let sortByDateDescAction = UIAlertAction(title: "Date Desc", style: .default) {
               UIAlertAction in
            self.sortingType = .dateDesc
           }
        alert.addAction(sortByNameAscAction)
        alert.addAction(sortByNameDescAction)
        alert.addAction(sortByDateAscAction)
        alert.addAction(sortByDateDescAction)
        self.present(alert, animated: true, completion: nil)

    }
    
    func selectObjectTapped(fileUrl: URL){
        if fileUrl.pathExtension == "" {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            vc.documentsURL = fileUrl
            navigationController?.pushViewController(vc, animated: true)
        } else if fileUrl.pathExtension == "pdf" {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PdfViewController") as! PdfViewController
            vc.pdfUrl = fileUrl
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let path = fileUrl.absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
            let url = URL(string: path)!
            UIApplication.shared.open(url)
        }
    }
    
    func sortingBy(sortBy: sortType){
        switch sortBy {
        case .nameAsc:
            fileURLs = try! FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles).sorted(by: {
                if let date1 = try? $0.resourceValues(forKeys: [.nameKey]).name?.lowercased(),
                   let date2 = try? $1.resourceValues(forKeys: [.nameKey]).name?.lowercased() {
                        return date1 < date2
                    }
                    return false
                })
        case .nameDesc:
            fileURLs = try! FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles).sorted(by: {
                if let date1 = try? $0.resourceValues(forKeys: [.nameKey]).name?.lowercased(),
                   let date2 = try? $1.resourceValues(forKeys: [.nameKey]).name?.lowercased() {
                        return date1 > date2
                    }
                    return false
                })
        case .dateAsc:
            fileURLs = try! FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles).sorted(by: {
                if let date1 = try? $0.resourceValues(forKeys: [.creationDateKey]).creationDate,
                   let date2 = try? $1.resourceValues(forKeys: [.creationDateKey]).creationDate {
                        return date1 < date2
                    }
                    return false
                })
        case .dateDesc:
            fileURLs = try! FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles).sorted(by: {
                if let date1 = try? $0.resourceValues(forKeys: [.creationDateKey]).creationDate,
                   let date2 = try? $1.resourceValues(forKeys: [.creationDateKey]).creationDate {
                        return date1 > date2
                    }
                    return false
                })
        }
    }
}

//MARK: - Setup TableView
extension ViewController: UITableViewDelegate,UITableViewDataSource {
    func setupTableView(){
        filesTableView.register(UINib(nibName: "filesTableViewCell", bundle: nil), forCellReuseIdentifier: "filesTableViewCell")
        filesTableView.delegate = self
        filesTableView.dataSource = self
        filesTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileURLs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filesTableViewCell", for: indexPath) as! filesTableViewCell
        cell.configureCell(data: fileURLs[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectObjectTapped(fileUrl: fileURLs[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
            try FileManager.default.removeItem(at: fileURLs[indexPath.row])
                setupFileManager(url: documentsURL)
            }catch{
                BannerManager.showMessage(errorMessageStr: "Error Delete", .warning)
            }
        }
    }
}


extension ViewController: addViewControllerDelegate {
    func closedView() {
        setupFileManager(url: documentsURL)
    }
}


