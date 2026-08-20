//
//  ImagesListPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Sagida on 19.08.2026.
//

@testable import ImageFeed
import UIKit

@MainActor
final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    
    private(set) var viewDidLoadCalled = false
    private(set) var displayedPhotoIndexPath: IndexPath?
    private(set) var selectedPhotoIndexPath: IndexPath?
    private(set) var likeTappedIndexPath: IndexPath?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didDisplayPhoto(at indexPath: IndexPath) {
        displayedPhotoIndexPath = indexPath
    }
    
    func didSelectPhoto(at indexPath: IndexPath) {
        selectedPhotoIndexPath = indexPath
    }
    
    func didTapLike(at indexPath: IndexPath) {
        likeTappedIndexPath = indexPath
    }
}
