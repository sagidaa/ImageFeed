//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Sagida on 15.05.2026.
//

import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {

    // MARK: - Constants
    
    private enum LayoutConstants {
        static let horizontalInset: CGFloat = 16
        static let verticalInset: CGFloat = 4
        static let spacing: CGFloat = 8
        static let cornerRadius: CGFloat = 16
        
        static let buttonSize: CGFloat = 44
        static let gradientHeight: CGFloat = 30
    }
    
    // MARK: - Properties
    
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    
    private lazy var fullSizeImageView = UIImageView()
    private lazy var gradientView = UIImageView()
    private lazy var dateLabel = UILabel()
    private lazy var likeButton = UIButton()
    
    private lazy var imageSkeletonView: GradientSkeletonView = {
        let view = GradientSkeletonView()
        view.layer.cornerRadius = LayoutConstants.cornerRadius
        return view
    }()
    
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
        
        imageSkeletonView.stopAnimating()
        
        [imageSkeletonView, gradientView, dateLabel, likeButton].forEach {
            $0.isHidden = true
        }
    }
    
    // MARK: - Configuration
    
    func configure(imageURL: URL?, placeholder: UIImage?, date: String, isLiked: Bool, completion: @escaping() -> Void) {
        dateLabel.text = date
        setIsLiked(isLiked)
        
        setImageState(.loading)
        
        fullSizeImageView.kf.setImage(with: imageURL, placeholder: placeholder) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let imageResult):
                setImageState(.finished(imageResult.image))
                completion()
                
            case .failure:
                setImageState(.error)
                fullSizeImageView.image = placeholder
            }
        }
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let image = UIImage(resource: isLiked ? .likeButtonOn : .likeButtonOff)
        likeButton.setImage(image, for: .normal)
    }
    
    // MARK: - Private Methods
    
    private func setImageState(_ state: FeedCellImageState) {
        switch state {
        case .loading:
            imageSkeletonView.isHidden = false
            imageSkeletonView.startAnimating()
            
            [gradientView, dateLabel, likeButton].forEach {
                $0.isHidden = true
            }
            
        case .error:
            imageSkeletonView.stopAnimating()
            imageSkeletonView.isHidden = true
            
            [gradientView, dateLabel, likeButton].forEach {
                $0.isHidden = false
            }
            
        case .finished(let image):
            imageSkeletonView.stopAnimating()
            imageSkeletonView.isHidden = true
            fullSizeImageView.image = image
            
            [gradientView, dateLabel, likeButton].forEach {
                $0.isHidden = false
            }
        }
    }
    
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
        
        likeButton.addTarget(self, action: #selector(likeButtonClicked), for: .touchUpInside)
        
        [fullSizeImageView, imageSkeletonView, gradientView, dateLabel, likeButton].forEach {
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
            
            imageSkeletonView.topAnchor.constraint(equalTo: fullSizeImageView.topAnchor),
            imageSkeletonView.leadingAnchor.constraint(equalTo: fullSizeImageView.leadingAnchor),
            imageSkeletonView.trailingAnchor.constraint(equalTo: fullSizeImageView.trailingAnchor),
            imageSkeletonView.bottomAnchor.constraint(equalTo: fullSizeImageView.bottomAnchor),
            
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
    
    // MARK: - Actions
    
    @objc private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
}
