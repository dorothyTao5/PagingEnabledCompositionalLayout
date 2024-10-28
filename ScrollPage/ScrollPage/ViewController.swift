//
//  ViewController.swift
//  ScrollPage
//
//  Created by dorothy on 2024/10/24.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    //MARK: - Property
    private var currentPage = 0
    private var willDisplayPage = 0
    private var endDisplaPage = 0
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: - Functions
    private func setupUI() {
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .white
        collectionView.collectionViewLayout = createCompositionalLayout()
        view.addSubview(collectionView)
    }
}

//MARK: - UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // assume there are X items per page
        let itemsCount = [70, 80, 9, 10]
        return itemsCount.randomElement() ?? 5
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // there are 4 pages in total
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .lightBackground
        cell.layer.borderColor = UIColor.border.cgColor
        cell.layer.borderWidth = 2
        
        // reuse issues need to be carefully handled!!
        let label = UILabel()
        label.text = "\(indexPath.section) -item:\(indexPath.item)"
        cell.contentView.addSubview(label)
        label.frame = cell.bounds
        return cell
    }
}

//MARK: - UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // there are multi items in a cell, but record section only once
        guard willDisplayPage != indexPath.section else { return }
        willDisplayPage = indexPath.section
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // compare with didEndDisplaying section and willDisplayPage section to determind if currentPage need to be updated
        guard currentPage == indexPath.section,
              currentPage != willDisplayPage else { return }
        currentPage = willDisplayPage
        print("🦸🧊 currentPage \(currentPage)")
        //TODO: switch tab...
    }
}

//MARK: - CollectionView Layout
extension ViewController {
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        //set the scroll direction to horizontal
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal

        //base size for the side
        let cvWidth = collectionView.bounds.size.width
        let baseWidth = cvWidth / 4
        let fixedSpace: CGFloat = 5

        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(baseWidth),
                                                heightDimension: .absolute(baseWidth))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // the size of the row
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(cvWidth),
                                                heightDimension: .absolute(baseWidth))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 4)// a row with a maximum of 4 items
        group.interItemSpacing = .fixed(fixedSpace)// the space between items

        // set a size for the page
        let groupSizePerPage = NSCollectionLayoutSize(widthDimension: .absolute(cvWidth),
                                                heightDimension: .absolute(collectionView.bounds.size.height))
        // the number of groups on a page.
        let aPageGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSizePerPage, subitem: group, count: Int(collectionView.bounds.size.height / baseWidth))
        
        // set a page as a section
        let section = NSCollectionLayoutSection(group: aPageGroup)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.interGroupSpacing = fixedSpace
        return UICollectionViewCompositionalLayout(section: section, configuration: config)
    }
}
