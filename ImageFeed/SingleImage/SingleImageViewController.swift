//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Sagida on 01.06.2026.
//

import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage?
    
    @IBOutlet private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
}
