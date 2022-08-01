//
//  ViewController.swift
//  FileMile
//
//  Created by AREM on 7/23/22.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var filesTableView: UITableView!
    
    var fileURLs : [URL] = []
    let fileManager = FileManager.default
    var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFileManager(url: documentsURL)
        setupTableView()       
    }
}

//MARK: - Functions
extension ViewController{
    
    func setupFileManager(url: URL){
        do {
            fileURLs = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
    }
    
    func selectObjectTapped(fileUrl: URL){
        
        if fileUrl.pathExtension == "" {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            vc.documentsURL = fileUrl
            navigationController?.pushViewController(vc, animated: true)
        }else{
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
