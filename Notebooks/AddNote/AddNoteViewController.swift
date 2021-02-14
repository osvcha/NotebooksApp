//
//  AddNoteViewController.swift
//  Notebooks
//
//  Created by Osvaldo Chaparro on 12/02/2021.
//

import UIKit

class AddNoteViewController: UIViewController {
    
    let borderColor: UIColor = .mainColor
    
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
        
    let viewModel: AddNoteViewModel

    init(viewModel: AddNoteViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white

        view.addSubview(titleField)
        view.addSubview(contentField)
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

        let submitButton = UIButton(type: .system)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.setTitle(NSLocalizedString("Submit", comment: ""), for: .normal)
        submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        submitButton.backgroundColor = .mainColor
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)

        view.addSubview(submitButton)
        NSLayoutConstraint.activate([
            submitButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            submitButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            submitButton.topAnchor.constraint(equalTo: contentField.bottomAnchor, constant: 16)
        ])

        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "multiply"), style: .plain, target: self, action: #selector(cancelButtonTapped))
        rightBarButtonItem.tintColor = .black
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentField.delegate = self
    }
    
    
    @objc fileprivate func cancelButtonTapped() {
        viewModel.cancelButtonTapped()
    }

    @objc fileprivate func submitButtonTapped() {
        guard let title = titleField.text, !title.isEmpty else { return }
        guard let content = contentField.text else { return }
        viewModel.submitButtonTapped(title: title, content: content)
    }

    fileprivate func showErrorAddingNoteAlert() {
        let message = NSLocalizedString("Error adding note", comment: "")
        showAlert(message)
    }
    
}

extension AddNoteViewController: AddNoteViewDelegate {
    func errorAddingNote() {
        showErrorAddingNoteAlert()
    }
}


extension AddNoteViewController: UITextViewDelegate {
    
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
