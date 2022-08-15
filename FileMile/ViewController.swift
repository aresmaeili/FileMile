//
//  ViewController.swift
//  FileMile
//
//  Created by AREM on 7/23/22.
//

import UIKit
import PDFKit

enum vcType{
    case normal,copy,move
}
enum sortType {
    case nameAsc,nameDesc,dateAsc,dateDesc
}

class ViewController: UIViewController {
    
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var insertButton: UIButton!
    @IBOutlet weak var optionsStackView: UIStackView!
    @IBOutlet weak var filesTableView: UITableView!
    @IBOutlet weak var optionsStackViewHeightConstraint: NSLayoutConstraint!
    @IBAction func cancelButtonAction(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func insertButtonAction(_ sender: Any) {
        insertButtonTapped(type: vcType)
    }
    
    var optionsOpenisHidden = true
    var vcType: vcType = .normal 
    var sortingType : sortType = .nameAsc {
        didSet{
            sortingBy(sortBy: sortingType)
        }
    }
    let fileManager = FileManager.default
    var sourcesURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    var destinationsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    var fileURLs : [URL] = []{
        didSet{
            filesTableView.reloadData()
        }
    }
    var filteredFileURLs : [URL] = []{
        didSet{
            filesTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        createDirectory(FolderName: "FileMile")
        setupFileManager(url: destinationsURL)
        setupTableView()
        setupOptions()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sortingBy(sortBy: .nameAsc)
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
    
    func secureCopyItem(at srcURL: URL, to dstURL: URL){
            do {
                if FileManager.default.fileExists(atPath: dstURL.path) {
                    try FileManager.default.removeItem(at: dstURL)
                }
                try FileManager.default.copyItem(at: srcURL, to: dstURL)
            } catch (let error) {
                print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
            }
        vcType = .normal
        navigationController?.popToRootViewController(animated: true)
        }

    func secureMoveItem(at srcURL: URL, to dstURL: URL){
            do {
                if FileManager.default.fileExists(atPath: dstURL.path) {
                    try FileManager.default.removeItem(at: dstURL)
                }
                try FileManager.default.moveItem(at: srcURL, to: dstURL)
            } catch (let error) {
                print("Cannot Move item at \(srcURL) to \(dstURL): \(error)")
            }
        vcType = .normal
        navigationController?.popToRootViewController(animated: true)
        }

    func setupFileManager(url: URL){
        let addItem = UIBarButtonItem(title: "|||", style: .plain, target: self, action: #selector(addedTapped))
        navigationItem.rightBarButtonItems =  [addItem]
        self.title = url.lastPathComponent.removingPercentEncoding
        sortingBy(sortBy: sortingType)
    }
    
    @objc func transportFile(){
        if optionsOpenisHidden {
            optionsStackViewHeightConstraint.constant = 25
            insertButton.isHidden = false
            cancelButton.isHidden = false
            optionsOpenisHidden.toggle()
        }else{
            optionsStackViewHeightConstraint.constant = 0
            insertButton.isHidden = true
            cancelButton.isHidden = true
            optionsOpenisHidden.toggle()
        }
    }
    
    @objc func addedTapped(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddViewController") as! AddViewController
        vc.url = destinationsURL
        vc.delegate = self
        navigationController?.present(vc, animated: true)
    }
    
    func sortTapped(){
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
    
    func insertButtonTapped(type: vcType){
        switch type {
        case .copy:
            secureCopyItem(at: sourcesURL, to: destinationsURL.appendingPathComponent(sourcesURL.lastPathComponent))
        case .move:
            secureMoveItem(at: sourcesURL, to: destinationsURL.appendingPathComponent(sourcesURL.lastPathComponent))
        case .normal: return
        }
    }
    
    func copyTapped(sourceUrl: URL){
        sourcesURL = sourceUrl
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        vc.vcType = .copy
        vc.sourcesURL = sourceUrl
        vc.destinationsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func moveTapped(sourceUrl: URL){
        sourcesURL = sourceUrl
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        vc.vcType = .move
        vc.sourcesURL = sourceUrl
        vc.destinationsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupOptions(){
        cancelButton.layer.cornerRadius = 10
        cancelButton.layer.borderWidth = 0.2
        cancelButton.layer.borderColor = UIColor.red.cgColor
        insertButton.layer.cornerRadius = 10
        insertButton.layer.borderWidth = 0.2
        insertButton.layer.borderColor = UIColor.systemBlue.cgColor
        switch vcType {
        case .normal:
            optionsStackViewHeightConstraint.constant = 0
            insertButton.isHidden = true
            cancelButton.isHidden = true
        case .copy:
            insertButton.setTitle("Copy Here!", for: .normal)
            optionsStackViewHeightConstraint.constant = 25
            insertButton.isHidden = false
            cancelButton.isHidden = false
        case .move:
            insertButton.setTitle("Move Here!", for: .normal)
            optionsStackViewHeightConstraint.constant = 25
            insertButton.isHidden = false
            cancelButton.isHidden = false
        }
    }
    
    func selectObjectTapped(fileUrl: URL){
        if fileUrl.pathExtension == "" {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            vc.vcType = self.vcType
            vc.sourcesURL = self.sourcesURL
            vc.destinationsURL = fileUrl
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
            do {
            fileURLs = try FileManager.default.contentsOfDirectory(at: destinationsURL, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles).sorted(by: {
                if let name1 = try? $0.resourceValues(forKeys: [.nameKey]).name?.lowercased(),
                   let name2 = try? $1.resourceValues(forKeys: [.nameKey]).name?.lowercased() {
                    return name1 < name2
                }
                return false
            })}catch{
                print("error")
            }
        case .nameDesc:
            do {
            fileURLs = try FileManager.default.contentsOfDirectory(at: destinationsURL, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles).sorted(by: {
                if let name1 = try? $0.resourceValues(forKeys: [.nameKey]).name?.lowercased(),
                   let name2 = try? $1.resourceValues(forKeys: [.nameKey]).name?.lowercased() {
                    return name1 > name2
                }
                return false
            })}catch{
                print("error")
            }
        case .dateAsc:
            do {
            fileURLs = try FileManager.default.contentsOfDirectory(at: destinationsURL, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles).sorted(by: {
                if let date1 = try? $0.resourceValues(forKeys: [.creationDateKey]).creationDate,
                   let date2 = try? $1.resourceValues(forKeys: [.creationDateKey]).creationDate {
                    return date1 < date2
                }
                return false
            })}catch{
                print("error")
            }
        case .dateDesc:
            do {
            fileURLs = try FileManager.default.contentsOfDirectory(at: destinationsURL, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles).sorted(by: {
                if let date1 = try? $0.resourceValues(forKeys: [.creationDateKey]).creationDate,
                   let date2 = try? $1.resourceValues(forKeys: [.creationDateKey]).creationDate {
                    return date1 > date2
                }
                return false
            })}catch{
                print("error")
            }
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
                setupFileManager(url: destinationsURL)
            }catch{
                BannerManager.showMessage(errorMessageStr: "Error Delete", .warning)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch vcType{
        case .normal: return true
        case .copy: return false
        case .move: return false
        }
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Move") {
            (action, sourceView, completionHandler) in
            self.moveTapped(sourceUrl: self.fileURLs[indexPath.row])
            completionHandler(true)
        }
        let shareAction = UIContextualAction(style: .normal, title: "Copy") {
            (action, sourceView, completionHandler) in
            self.copyTapped(sourceUrl: self.fileURLs[indexPath.row])
            completionHandler(true)
        }
        editAction.backgroundColor = .darkGray
        shareAction.backgroundColor = .blue
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [editAction, shareAction])
        swipeConfiguration.performsFirstActionWithFullSwipe = false
        return swipeConfiguration
    }

    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton = UITableViewRowAction(style: .destructive, title: "Delete") { _, indexPath in
            do {
                try FileManager.default.removeItem(at: self.fileURLs[indexPath.row])
                self.setupFileManager(url: self.destinationsURL)
            }catch{
                BannerManager.showMessage(errorMessageStr: "Error Delete", .warning)
            }
        }

        deleteButton.backgroundColor = .red
        return [deleteButton]
    }
}

//MARK: - Setup SearchBar
extension ViewController  {
  
}




//MARK: - Setup Delegates
extension ViewController: addViewControllerDelegate {
    func closedView() {
        setupFileManager(url: destinationsURL)
    }
}


