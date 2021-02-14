//
//  NoteCell.swift
//  Notebooks
//
//  Created by Osvaldo Chaparro on 11/02/2021.
//

import UIKit

class NoteCell: UITableViewCell {
    
    static let identifier = "NoteCell"
    let cellStyle = CellStyle.subtitle
    
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18.0)
        return titleLabel
    }()
    
    private let detailLabel: UILabel = {
        let detailLabel = UILabel()
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.font = UIFont(name: "HelveticaNeue", size: 14.0)
        return detailLabel
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: cellStyle, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var viewModel: NoteCellViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            titleLabel.text = viewModel.textLabelText
            detailLabel.text = viewModel.detailTextLabel
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),
            titleLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 16),
            
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            detailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            
            
        ])

    }
    


    
    
}


