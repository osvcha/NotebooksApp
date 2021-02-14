//
//  NotebookCell.swift
//  Notebooks
//
//  Created by Osvaldo Chaparro on 09/02/2021.
//

import UIKit

class NotebookCell: UITableViewCell {
    
    static let identifier = "NotebookCell"
    let cellStyle = CellStyle.subtitle
    
       
    
    private let myImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18.0)
        return titleLabel
    }()
    
    private let dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textColor = .mainColor
        dateLabel.font = UIFont(name: "HelveticaNeue", size: 14.0)
        return dateLabel
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: cellStyle, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(myImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var viewModel: NotebookCellViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            titleLabel.text = viewModel.textLabelText
            dateLabel.text = viewModel.detailTextLabel
            myImageView.image = UIImage(named: viewModel.notebookImageName ?? "")
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        NSLayoutConstraint.activate([
            myImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8),
            myImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 8),
            myImageView.heightAnchor.constraint(equalToConstant: 64),
            myImageView.widthAnchor.constraint(equalToConstant: 52),
            
            titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),
            titleLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 72),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            
            
        ])



//        myImageView.frame = CGRect(x: 5, y: 5, width: 80, height: contentView.frame.height-10)
//        textLabel?.frame = CGRect(x: myImageView.frame.width, y: 10, width: contentView.frame.width-myImageView.frame.width-5, height: 20)
//        detailTextLabel?.frame = CGRect(x: myImageView.frame.width, y: 30, width: contentView.frame.width-myImageView.frame.width-5, height: 20)
    }
    


    
    
}

