//
//  OnboardingCollectionViewCell.swift
//  diplom
//
//  Created by Stanislav on 08.01.2023.
//

import UIKit

class OnboardingCollectionViewCell: UICollectionViewCell {
    
    static let identifier = String(describing: OnboardingCollectionViewCell.self)
    
    @IBOutlet weak var mainTitleOnSlide: UILabel!
    @IBOutlet weak var slideImageView: UIImageView!
    
    func setup(_ slide: OnboardingSlideModel) {
        slideImageView.image = slide.slideImage
        mainTitleOnSlide.text = slide.title
    }
}
