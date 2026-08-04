//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Sagida on 15.05.2026.
//

import UIKit
import Kingfisher

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
    
    private lazy var fullSizeImageView = UIImageView()
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        fullSizeImageView.kf.cancelDownloadTask()
        fullSizeImageView.image = nil
        dateLabel.text = nil
        likeButton.setImage(nil, for: .normal)
    }
    
    // MARK: - Configuration
    
    func configure(imageURL: URL?, placeholder: UIImage?, date: String, isLiked: Bool, completion: @escaping() -> Void) {
        dateLabel.text = date
        
        let likeImage = isLiked ? UIImage(resource: .likeButtonOn) : UIImage(resource: .likeButtonOff)
        likeButton.setImage(likeImage, for: .normal)
        
        fullSizeImageView.kf.setImage(with: imageURL, placeholder: placeholder) { result in
            guard case .success = result else { return }
            completion()
        }
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .ypBlack
        contentView.backgroundColor = .ypBlack
        
        fullSizeImageView.contentMode = .scaleAspectFill
        fullSizeImageView.clipsToBounds = true
        fullSizeImageView.layer.cornerRadius = LayoutConstants.cornerRadius
        fullSizeImageView.kf.indicatorType = .activity
        
        gradientView.contentMode = .scaleToFill
        gradientView.image = .gradientView
        
        dateLabel.font = .systemFont(ofSize: 13, weight: .regular)
        dateLabel.textColor = .ypWhite
        
        
        [fullSizeImageView, gradientView, dateLabel, likeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            fullSizeImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: LayoutConstants.verticalInset),
            fullSizeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: LayoutConstants.horizontalInset),
            fullSizeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -LayoutConstants.horizontalInset),
            fullSizeImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -LayoutConstants.verticalInset),
            
            gradientView.heightAnchor.constraint(equalToConstant: LayoutConstants.gradientHeight),
            gradientView.leadingAnchor.constraint(equalTo: fullSizeImageView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: fullSizeImageView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: fullSizeImageView.bottomAnchor),
            
            dateLabel.leadingAnchor.constraint(equalTo: fullSizeImageView.leadingAnchor, constant: LayoutConstants.spacing),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: fullSizeImageView.trailingAnchor, constant: -LayoutConstants.spacing),
            dateLabel.bottomAnchor.constraint(equalTo: fullSizeImageView.bottomAnchor, constant: -LayoutConstants.spacing),
            
            likeButton.heightAnchor.constraint(equalToConstant: LayoutConstants.buttonSize),
            likeButton.widthAnchor.constraint(equalToConstant: LayoutConstants.buttonSize),
            likeButton.topAnchor.constraint(equalTo: fullSizeImageView.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: fullSizeImageView.trailingAnchor)
        ])
    }
}
