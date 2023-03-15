//
//  ViewController.swift
//  diplom
//
//  Created by Stanislav on 07.01.2023.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var headTitle: UILabel!
    
    var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
            if currentPage == slides.count - 1 {
                nextButton.setTitle("Авторизоваться", for: .normal)
            } else {
                nextButton.setTitle("Далее", for: .normal)
            }
        }
    }
    var slides: [OnboardingSlideModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        slides = [
            OnboardingSlideModel(title: "Теперь все ваши документы в одном месте", slideImage: UIImage(named: "slideNum1")!),
            OnboardingSlideModel(title: "Доступ к файлам без интернета", slideImage: UIImage(named: "slideNum2")!),
            OnboardingSlideModel(title: "Делитесь вашими файлами с другими", slideImage: UIImage(named: "slideNum3")!),
        ]
        
    }

    @IBAction func nextSlide(_ sender: Any) {
        if currentPage == slides.count - 1 {
            let requestTokenViewController = YandexWebKitViewController()
            requestTokenViewController.authDelegate = self
            present(requestTokenViewController, animated: true)
        } else {
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }

    }
    
}

extension OnboardingViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.identifier, for: indexPath) as! OnboardingCollectionViewCell
        cell.setup(slides[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x / width)
        pageControl.currentPage = currentPage
    }
    
}

extension OnboardingViewController: YandexWebKitDelegate {
    func handleTokenChanged(token: String) {
        NetworkService.shared.token = token
        }
}
