//
//  ViewController.swift
//  FileMile
//
//  Created by AREM on 7/23/22.
//

import UIKit
import PDFKit

class ViewController: UIViewController {
    
    @IBOutlet weak var filesTableView: UITableView!
    
    var fileURLs : [URL] = []
    let fileManager = FileManager.default
    var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createDirectory(FolderName: "FileMile")
        setupFileManager(url: documentsURL)
        setupTableView()
    }
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        // just send back the first one, which ought to be the only one
        return paths[0]
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
//        let newFolderItem = UIBarButtonItem(title: "New Folder", style: .plain, target: self, action: #selector(addTapped))
        let addItem = UIBarButtonItem(title: "import", style: .plain, target: self, action: #selector(addTapped))

        navigationItem.rightBarButtonItems =  [addItem]
        self.title = url.lastPathComponent.removingPercentEncoding
        do {
            fileURLs = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
    }
    
    @objc func addTapped(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddViewController") as! AddViewController
        navigationController?.present(vc, animated: true)
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
}

//MARK: - Setup TableView
extension ViewController: UITableViewDelegate,UITableViewDataSource {
    func setupTableView(){
        filesTableView.register(UINib(nibName: "filesTableViewCell", bundle: nil), forCellReuseIdentifier: "filesTableViewCell")
        filesTableView.delegate = self
        filesTableView.dataSource = self
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
}


