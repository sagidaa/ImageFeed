//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Sagida on 15.05.2026.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - Constants
    
    private enum LayoutConstants {
        static let horizontalInset: CGFloat = 16
        static let verticalInset: CGFloat = 4
        static let spacing: CGFloat = 8
        static let cornerRadius: CGFloat = 16
        
        static let buttonSize: CGFloat = 44
        static let gradientHeight: CGFloat = 30
    }
    
    // MARK: - UI Elements
    
    private lazy var photoImageView = UIImageView()
    private lazy var gradientView = UIImageView()
    private lazy var dateLabel = UILabel()
    private lazy var likeButton = UIButton()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
                
        setupViews()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Configuration
    
    func configure(image: UIImage, date: String, isLiked: Bool) {
        photoImageView.image = image
        dateLabel.text = date
        
        let likeImage = isLiked ? UIImage(resource: .likeButtonOn) : UIImage(resource: .likeButtonOff)
        likeButton.setImage(likeImage, for: .normal)
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .ypBlack
        contentView.backgroundColor = .ypBlack
        
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
        photoImageView.layer.cornerRadius = LayoutConstants.cornerRadius
        
        gradientView.contentMode = .scaleToFill
        gradientView.image = .gradientView
        
        dateLabel.font = .systemFont(ofSize: 13, weight: .regular)
        dateLabel.textColor = .ypWhite
        
        
        [photoImageView, gradientView, dateLabel, likeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: LayoutConstants.verticalInset),
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: LayoutConstants.horizontalInset),
            photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -LayoutConstants.horizontalInset),
            photoImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -LayoutConstants.verticalInset),
            
            gradientView.heightAnchor.constraint(equalToConstant: LayoutConstants.gradientHeight),
            gradientView.leadingAnchor.constraint(equalTo: photoImageView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: photoImageView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: photoImageView.bottomAnchor),
            
            dateLabel.leadingAnchor.constraint(equalTo: photoImageView.leadingAnchor, constant: LayoutConstants.spacing),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: photoImageView.trailingAnchor, constant: -LayoutConstants.spacing),
            dateLabel.bottomAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: -LayoutConstants.spacing),
            
            likeButton.heightAnchor.constraint(equalToConstant: LayoutConstants.buttonSize),
            likeButton.widthAnchor.constraint(equalToConstant: LayoutConstants.buttonSize),
            likeButton.topAnchor.constraint(equalTo: photoImageView.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: photoImageView.trailingAnchor)
        ])
    }
}
