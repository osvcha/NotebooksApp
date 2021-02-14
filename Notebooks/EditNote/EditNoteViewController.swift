//
//  EditNoteViewController.swift
//  Notebooks
//
//  Created by Osvaldo Chaparro on 13/02/2021.
//

import UIKit

class EditNoteViewController: UIViewController {
    
    let borderColor: UIColor = .mainColor
    
    private let screenWidth = UIScreen.main.bounds.width
    
    lazy var titleField: TextFieldWithPadding = {
        let titleField = TextFieldWithPadding()
        titleField.translatesAutoresizingMaskIntoConstraints = false
        titleField.borderStyle = .none
        titleField.font = UIFont.systemFont(ofSize: 16)
        titleField.placeholder = NSLocalizedString("Insert note title", comment: "")
        titleField.layer.borderWidth = 0.5
        titleField.layer.borderColor = borderColor.cgColor
        titleField.layer.cornerRadius = CGFloat(10)
        return titleField
    }()
    
    lazy var contentField: UITextView = {
        let contentField = UITextView()
        contentField.text = "Insert note content"
        contentField.textColor = UIColor.lightGray
        contentField.translatesAutoresizingMaskIntoConstraints = false
        contentField.font = UIFont.systemFont(ofSize: 16)
        contentField.layer.borderWidth = 0.5
        contentField.layer.borderColor = borderColor.cgColor
        contentField.layer.cornerRadius = CGFloat(10)
        contentField.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return contentField
    }()
    
    lazy var photoCollectionView: UICollectionView = {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        //layout.itemSize = CGSize(width: view.frame.width/3, height: view.frame.width/3)
        layout.scrollDirection = .vertical
        let photoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        photoCollectionView.register(NotePhotographCell.self, forCellWithReuseIdentifier: "notePhotoCell")
        photoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        photoCollectionView.backgroundColor = .white
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        
        return photoCollectionView
    }()
    
    //ViewModel
    let viewModel: EditNoteViewModel
    
    init(viewModel: EditNoteViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        view.addSubview(titleField)
        view.addSubview(contentField)
        view.addSubview(photoCollectionView)
        
        configureTheView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewWasLoaded()
        contentField.delegate = self
    }
    
    func configureTheView() {
        
        //Constraints
        NSLayoutConstraint.activate([
            titleField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            titleField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            titleField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
        
        NSLayoutConstraint.activate([
            contentField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            contentField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            contentField.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 16),
            contentField.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        NSLayoutConstraint.activate([
            photoCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            photoCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            photoCollectionView.topAnchor.constraint(equalTo: contentField.bottomAnchor, constant: 16),
            photoCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 16),
            //photoCollectionView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        UISearchBar.appearance().tintColor = .mainColor
        self.navigationController?.navigationBar.tintColor = .mainColor
        
        
        //populate data
        titleField.text = viewModel.note?.title
        contentField.text = viewModel.note?.content
        contentField.textColor = UIColor.black
        
        //Save button
        let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(noteSaveButtonTapped))
        leftBarButtonItem.tintColor = .mainColor
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        //Add image button
        let addImage = UIImage(systemName: "photo.fill.on.rectangle.fill")
        let rightBarButtonItem = UIBarButtonItem(image: addImage, style: .plain, target: self, action: #selector(addImageButtontapped))
        rightBarButtonItem.tintColor = .mainColor
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
    }
    
    @objc func noteSaveButtonTapped() {
        
        //mandar datos al viewmodel
        guard let title = titleField.text, !title.isEmpty else { return }
        guard let content = contentField.text else { return }
        viewModel.noteSaveButtonTapped(title: title, content: content)
        
        print("save button tapped")
    }
    
    
    @objc func addImageButtontapped() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        
        // necesitamos presentar los mediatypes disponibles en este caso solo photolibrary.
        if  UIImagePickerController.isSourceTypeAvailable(.photoLibrary),
            let availabletypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
            picker.mediaTypes = availabletypes
        }
        
        present(picker, animated: true, completion: nil)
        
    }
}

extension EditNoteViewController: EditNoteViewDelegate {
    
    func newNoteImage(at newIndexPath: IndexPath) {
        photoCollectionView.insertItems(at: [newIndexPath])
    }
    
}

extension EditNoteViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = photoCollectionView.dequeueReusableCell(withReuseIdentifier: "notePhotoCell", for: indexPath) as? NotePhotographCell, let cellViewModel = viewModel.viewModel(at: indexPath) {
            cell.viewModel = cellViewModel
            return cell
        }
        
        fatalError()
    }
    
    
}

extension EditNoteViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth/3.8, height: screenWidth/3.8)
    }
}

extension EditNoteViewController: UICollectionViewDelegate {
    
}


extension EditNoteViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Insert note content"
            textView.textColor = UIColor.lightGray
        }
    }
    
}

extension EditNoteViewController: UINavigationControllerDelegate {
    
}

extension EditNoteViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true) { [weak self] in
            
            if let urlImage = info[.imageURL] as? URL {
                self?.viewModel.addNotePhoto(with: urlImage)
            }
        }
        
    }
}
