//
//  MainTabBarController.swift
//  textnavigationcontroller
//
//  Created by Stanislav on 11.01.2023.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTabBar()

        // Do any additional setup after loading the view.
    }
    
    private func setupTabBar() {
        tabBar.backgroundColor = .systemBackground
        tabBar.tintColor = .black
        tabBar.unselectedItemTintColor = .lightGray
    }
    
    private func setupViews() {
        let secondVC = AllFilesViewController()
        let firstVC = LastDownloadViewController()
        let thirdVC = ProfileViewController()
        setViewControllers([firstVC, secondVC, thirdVC], animated: true)
        
        guard let items = tabBar.items else { return }
        items[0].image = UIImage(named: "lastfiles")
        items[1].image = UIImage(named: "Vector-3")
        items[2].image = UIImage(named: "pngwing.com")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
