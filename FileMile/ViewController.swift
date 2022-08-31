//
//  ViewController.swift
//  FileMile
//
//  Created by AREM on 7/23/22.
//

import UIKit
import PDFKit

protocol ViewControllerDelegate: AnyObject {
    func viewControllerDismissed()
}

class ViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var insertButton: UIButton!
    @IBOutlet weak var optionsStackView: UIStackView!
    @IBOutlet weak var filesTableView: UITableView!
    @IBOutlet weak var optionsStackViewHeightConstraint: NSLayoutConstraint!
    @IBAction func cancelButtonAction(_ sender: Any) {
        if let url = destinationsURL {
            setupFileManager(url: url)
        }
    }
    @IBAction func insertButtonAction(_ sender: Any) {
        insertButtonTapped(type: vcType)
    }

    enum VcType{
        case normal, copy, move
    }

    enum SortType {
        case typeAsc, nameAsc, nameDesc, dateAsc, dateDesc
    }

    enum ActionType{
        case move, copy, rename, delete
    }
    var searching = false
    var optionsOpenIsHidden = true
    var vcType: VcType = .normal
    weak var delegate : ViewControllerDelegate?
    let fileManager = FileManager.default
    var sourcesURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    var destinationsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    var sortingType : SortType = .typeAsc {
        didSet{
            sortingBy(sortBy: sortingType)
        }
    }
    var fileURLs : [URL] = []{
        didSet{
            DispatchQueue.main.async {
                self.filesTableView.reloadData()
            }
        }
    }
    var filteredFileURLs : [URL] = []{
        didSet{
            DispatchQueue.main.async {
                self.filesTableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        if let url = destinationsURL {
            setupFileManager(url: url)
        }
        setupTableView()
        setupOptions()
        setupSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sortingBy(sortBy: sortingType)
        if let url = destinationsURL {
            setupFileManager(url: url)
        }
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
    
    func insertExistedFile(sourceUrl: URL,destinationUrl: URL , insertType: VcType){
        let alert = UIAlertController(title: "EXISTED", message: "Your file Existed", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Replace", style: .default, handler: { _ in
           confirmAction()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak self] _ in
            self?.delegate?.viewControllerDismissed()
            self?.dismiss(animated: true)
            self?.navigationController?.popToRootViewController(animated: true)
        }))
       present(alert, animated: true, completion: nil)
        
        func confirmAction(){
            do{
                try FileManager.default.removeItem(at: destinationUrl)
                switch insertType {
                case .normal:
                    return
                case .copy:
                    try FileManager.default.copyItem(at: sourceUrl, to: destinationUrl)
                case .move:
                    try FileManager.default.moveItem(at: sourceUrl, to: destinationUrl)
                }
                dismiss(animated: true)
                navigationController?.popToRootViewController(animated: true)
            } catch (let error) {
                print("Cannot insert item at \(sourceUrl) to \(destinationUrl): \(error)")
            }
            sortingBy(sortBy: sortingType)
        }
    }
    
    func secureCopyItem(at sourceURL: URL, to destinationURL: URL){
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                insertExistedFile(sourceUrl: sourceURL, destinationUrl: destinationURL, insertType: .copy)
            }else{
                try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            }
        } catch (let error) {
            print("Cannot copy item at \(sourceURL) to \(destinationURL): \(error)")
        }
        vcType = .normal
        dismiss(animated: true)
    }
    
    func secureMoveItem(at sourceURL: URL, to destinationURL: URL){
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                insertExistedFile(sourceUrl: sourceURL, destinationUrl: destinationURL, insertType: .move)
            }
            try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
        } catch (let error) {
            print("Cannot Move item at \(sourceURL) to \(destinationURL): \(error)")
        }
        vcType = .normal
        delegate?.viewControllerDismissed()
        dismiss(animated: true)
    }
    
    func setupFileManager(url: URL){
        let addItem = UIBarButtonItem(title: "📂", style: .plain, target: self, action: #selector(addedTapped))
        let sortItem = UIBarButtonItem(title: "SOR〒", style: .plain, target: self, action: #selector(sortTapped))
        sortItem.tintColor = .darkGray
        navigationItem.rightBarButtonItems =  [addItem,sortItem]
        self.title = url.lastPathComponent.removingPercentEncoding
        sortingBy(sortBy: sortingType)
        DispatchQueue.main.async {
            self.filesTableView.reloadData()
        }
    }
    
    @objc func transportFile(){
        if optionsOpenIsHidden {
            optionsStackViewHeightConstraint.constant = 25
            insertButton.isHidden = false
            cancelButton.isHidden = false
            optionsOpenIsHidden.toggle()
        }else{
            optionsStackViewHeightConstraint.constant = 0
            insertButton.isHidden = true
            cancelButton.isHidden = true
            optionsOpenIsHidden.toggle()
        }
    }
    
    @objc func addedTapped(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddViewController") as! AddViewController
        vc.url = destinationsURL
        vc.delegate = self
        navigationController?.present(vc, animated: true)
    }
    
    @objc func sortTapped(){
        let alert = UIAlertController(title: "Sort by:" , message: "", preferredStyle: .actionSheet)
        let sortByNameAscAction = UIAlertAction(title: "Name Asc", style: .default) {
            UIAlertAction in
            self.sortingType = .nameAsc
        }
        let sortByTypeAscAction = UIAlertAction(title: "Type Asc", style: .default) {
            UIAlertAction in
            self.sortingType = .typeAsc
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
        let cancelSortByAction = UIAlertAction(title: "Cancel", style: .cancel) {
            UIAlertAction in
            self.dismiss(animated: true)
        }
        alert.addAction(sortByTypeAscAction)
        alert.addAction(cancelSortByAction)
        alert.addAction(sortByNameAscAction)
        alert.addAction(sortByNameDescAction)
        alert.addAction(sortByDateAscAction)
        alert.addAction(sortByDateDescAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func insertButtonTapped(type: VcType){
        switch type {
        case .copy:
            if let url = sourcesURL, let destination = destinationsURL {
                secureCopyItem(at: url, to: destination.appendingPathComponent(url.lastPathComponent))
            }
        case .move:
            if let source = sourcesURL, let destination = destinationsURL {
                secureMoveItem(at: source, to: destination.appendingPathComponent(source.lastPathComponent))
            }
        case .normal: return
        }
    }
    
    func copyTapped(sourceUrl: URL){
        sourcesURL = sourceUrl
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let navController = UINavigationController(rootViewController: vc)
        vc.vcType = .copy
        vc.sourcesURL = sourceUrl
        vc.delegate = self
        vc.destinationsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        present(navController, animated: true)
    }
    
    func moveTapped(sourceUrl: URL){
        sourcesURL = sourceUrl
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let navController = UINavigationController(rootViewController: vc)
        vc.vcType = .move
        vc.sourcesURL = sourceUrl
        vc.delegate = self
        vc.destinationsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        present(navController, animated: true)
    }
    
    func renameTapped(sourceFile: URL , currentName: String , newName: String , fileType:String){
        do {
            let path = sourceFile
            let originPath = path.appendingPathComponent(currentName)
            var destinationPath = path.appendingPathComponent(newName).appendingPathComponent(fileType)
            if fileType == "" {
                destinationPath = path.appendingPathComponent(newName).appendingPathComponent(fileType)
            }else{
                destinationPath = path.appendingPathComponent("\(newName).\(fileType)")
            }
            if FileManager.default.fileExists(atPath: destinationPath.path) {
                insertExistedFile(sourceUrl: originPath, destinationUrl: destinationPath, insertType: .move)
            }else{
                try FileManager.default.moveItem(at: originPath, to: destinationPath)
            }
            destinationsURL = sourcesURL
            sortingBy(sortBy: sortingType)
        } catch {
            print("Error in Rename")
        }
    }
    
    func setupOptions(){
        cancelButton.layer.cornerRadius = 10
        cancelButton.layer.borderWidth = 0.2
        cancelButton.layer.borderColor = UIColor.darkGray.cgColor
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
            vc.delegate = self
            if vc.sourcesURL != vc.destinationsURL {
                navigationController?.pushViewController(vc, animated: true)
            }else{
                BannerManager.showMessage(errorMessageStr: "The same file!!!", .warning)
            }
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
    
    func createNameAlert(indexPath: IndexPath){
        let alert = UIAlertController(title: "Rename", message: "Select your new name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
            textField.placeholder = "New Name"
        }
        alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: { [weak self] _ in
            let textField = alert.textFields![0]
            guard let sourceName = self?.filteredFileURLs[indexPath.row].lastPathComponent.removingPercentEncoding ,let newName = textField.text ,let destinationsURL = self?.destinationsURL , let files = self?.filteredFileURLs[indexPath.row].pathExtension  else {return}
            self?.renameTapped(sourceFile: destinationsURL , currentName: sourceName , newName: newName, fileType: files)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func sortingBy(sortBy: SortType){
        guard let destination = destinationsURL else { return }
        switch sortBy {
        case .typeAsc:
            do {
                filteredFileURLs = try FileManager.default.contentsOfDirectory(at: destination, includingPropertiesForKeys: [.nameKey], options: .skipsHiddenFiles).sorted(by: {
                        return $0.pathExtension < $1.pathExtension
                })
            }catch{
                BannerManager.showMessage(errorMessageStr: "error sort", .danger)
            }
        case .nameAsc:
            do {
                filteredFileURLs = try FileManager.default.contentsOfDirectory(at: destination, includingPropertiesForKeys: [.nameKey], options: .skipsHiddenFiles).sorted(by: {
                    if let name1 = try? $0.resourceValues(forKeys: [.nameKey]).name?.lowercased(),
                       let name2 = try? $1.resourceValues(forKeys: [.nameKey]).name?.lowercased() {
                        return name1 < name2
                    }
                    return false
                })
            }catch{
                BannerManager.showMessage(errorMessageStr: "error sort", .danger)
            }
        case .nameDesc:
            do {
                filteredFileURLs = try FileManager.default.contentsOfDirectory(at: destination, includingPropertiesForKeys: [.nameKey], options: .skipsHiddenFiles).sorted(by: {
                    if let name1 = try? $0.resourceValues(forKeys: [.nameKey]).name?.lowercased(),
                       let name2 = try? $1.resourceValues(forKeys: [.nameKey]).name?.lowercased() {
                        return name1 > name2
                    }
                    return false
                })
            }catch{
                BannerManager.showMessage(errorMessageStr: "error sort", .danger)
            }
        case .dateAsc:
            do {
                filteredFileURLs = try FileManager.default.contentsOfDirectory(at: destination, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles).sorted(by: {
                    if let date1 = try? $0.resourceValues(forKeys: [.creationDateKey]).creationDate,
                       let date2 = try? $1.resourceValues(forKeys: [.creationDateKey]).creationDate {
                        return date1 < date2
                    }
                    return false
                })
                
            }catch{
                BannerManager.showMessage(errorMessageStr: "error sort", .danger)
            }
        case .dateDesc:
            do {
                filteredFileURLs = try FileManager.default.contentsOfDirectory(at: destination, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles).sorted(by: {
                    if let date1 = try? $0.resourceValues(forKeys: [.creationDateKey]).creationDate,
                       let date2 = try? $1.resourceValues(forKeys: [.creationDateKey]).creationDate {
                        return date1 > date2
                    }
                    return false
                })
                
            }catch{
                BannerManager.showMessage(errorMessageStr: "error sort", .danger)
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
        DispatchQueue.main.async {
            self.filesTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFileURLs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filesTableViewCell", for: indexPath) as! filesTableViewCell
        cell.configureCell(data: filteredFileURLs[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectObjectTapped(fileUrl: filteredFileURLs[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try FileManager.default.removeItem(at: filteredFileURLs[indexPath.row])
                if let destination = destinationsURL {
                    setupFileManager(url: destination)
                }
            }catch{
                BannerManager.showMessage(errorMessageStr: "Error Delete", .warning)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch vcType {
        case .normal: return true
        default: return false
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let moveAction = swipeButtonsTapped(rowIndexPathAt: indexPath, actionType: .move)
        let copyAction = swipeButtonsTapped(rowIndexPathAt: indexPath, actionType: .copy)
        let renameAction = swipeButtonsTapped(rowIndexPathAt: indexPath, actionType: .rename)
        moveAction.backgroundColor = .darkGray
        copyAction.backgroundColor = .blue
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [moveAction, copyAction , renameAction])
        swipeConfiguration.performsFirstActionWithFullSwipe = false
        return swipeConfiguration
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = swipeButtonsTapped(rowIndexPathAt: indexPath, actionType: .delete)
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [delete])
        return swipeConfiguration
    }
    
    private func swipeButtonsTapped(rowIndexPathAt indexPath: IndexPath, actionType: ActionType) -> UIContextualAction {
        switch actionType {
        case .move:
            return swipeButtonMoveAction(indexPath: indexPath)
        case .copy:
            return swipeButtonCopyAction(indexPath: indexPath)
        case .rename:
            return swipeButtonRenameAction(indexPath: indexPath)
        case .delete:
            return swipeButtonDeleteAction(indexPath: indexPath)
        }
    }
    
    func swipeButtonDeleteAction(indexPath: IndexPath) -> UIContextualAction {
    return UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, _) in
        guard let self = self else {return}
        do {
            try FileManager.default.removeItem(at: self.filteredFileURLs[indexPath.row])
            if let url = self.destinationsURL {
                self.setupFileManager(url: url)
            }
        }catch{
            BannerManager.showMessage(errorMessageStr: "Error Delete", .warning)
        }
    }
}
    func swipeButtonRenameAction(indexPath: IndexPath) -> UIContextualAction {
        return UIContextualAction(style: .normal, title: "Rename") {
            (action, sourceView, completionHandler) in
            self.createNameAlert(indexPath: indexPath)
            completionHandler(true)
        }
    }
    
    func swipeButtonCopyAction(indexPath: IndexPath) -> UIContextualAction {
        return UIContextualAction(style: .normal, title: "Copy") {
            (action, sourceView, completionHandler) in
            self.copyTapped(sourceUrl: self.filteredFileURLs[indexPath.row])
            completionHandler(true)
        }
    }
    
    func swipeButtonMoveAction(indexPath: IndexPath) -> UIContextualAction {
        return UIContextualAction(style: .normal, title: "Move") {
            (action, sourceView, completionHandler) in
            self.moveTapped(sourceUrl: self.filteredFileURLs[indexPath.row])
            completionHandler(true)
        }
    }
}

//MARK: - Setup Delegates
extension ViewController : UISearchBarDelegate {
    
    func setupSearchBar(){
        searchBar.delegate = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        sortingBy(sortBy: sortingType)
        if !searchText.isEmpty {
            filteredFileURLs = filteredFileURLs.filter {
                $0.lastPathComponent.lowercased().contains(searchText.lowercased())
            }
        }
        DispatchQueue.main.async {
            self.filesTableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        searchBar.text = ""
        sortingBy(sortBy: sortingType)
        searchBar.endEditing(true)
        DispatchQueue.main.async {
            self.filesTableView.reloadData()
        }
    }
}

//MARK: - Setup Delegates
extension ViewController: addViewControllerDelegate {
    
    func closedView() {
        if let url = destinationsURL {
            setupFileManager(url: url)
        }
    }
}

//MARK: - Delegates
extension ViewController : ViewControllerDelegate {
    
    func viewControllerDismissed() {
        delegate?.viewControllerDismissed()
        if let url = destinationsURL {
            setupFileManager(url: url)
        }
    }
}
