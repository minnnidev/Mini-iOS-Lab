//
//  DistinctSectionViewController.swift
//  Compositional-Layout
//
//  Created by 김민 on 2022/12/12.
//

import UIKit

import SnapKit
import Then

// MARK: - DistinctSectionViewController

class DistinctSectionViewController: UIViewController {

    
    // MARK: - Enum
    
    enum SectionLayoutKind: Int, CaseIterable {
        case list, grid1, grid2
        
        var columnInt: Int {
            switch self {
            case .list:
                return 1
            case .grid1:
                return 5
            case .grid2:
                return 2
            }
        }
    }
    
    enum Item: Hashable {
        case list(ListModel)
        case grid(GridModel)
    }
    
    // MARK: - Typealias
    
    typealias DataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Item>
    
    // MARK: - Variable
    
    var dataSource: DataSource! = nil
    
    // MARK: - UI Component
    
    private lazy var distinctCollectionView: UICollectionView = {
        let layout = createLayout()
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()

    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        config()
    }
}

// MARK: - Extension

extension DistinctSectionViewController {
    
    // MARK: - Layout
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let sectionLayoutKind = SectionLayoutKind(rawValue: sectionIndex) else {return nil}
            print(sectionLayoutKind)
            let columns = sectionLayoutKind.columnInt
            print(columns)
            
            var itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            if columns == 5 {
                itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2),
                                                  heightDimension: .fractionalHeight(1.0))
            } else if columns == 2 {
                itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                  heightDimension: .fractionalHeight(1.0))
            }
            
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            
            let groupHeight = columns == 1 ?
            NSCollectionLayoutDimension.absolute(44) :
            NSCollectionLayoutDimension.fractionalWidth(0.2)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: groupHeight)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: columns)
            
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        }
        
        return layout
        
    }
    
    private func setLayout() {
        
        view.addSubview(distinctCollectionView)
        
        distinctCollectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
        
        
    }
    
    // MARK: - Config
    
    private func config() {
        view.backgroundColor = .white
        
        let listCellRegisteration = UICollectionView.CellRegistration<ListCollectionViewCell, Item> { cell, indexPath, itemIdentifier in
            if case let Item.list(item) = itemIdentifier {
                cell.dataBind(text: item.name)
            }
        }
        
        let gridCellRegisteration = UICollectionView.CellRegistration<GridCollectionViewCell, Item> { cell, indexPath, itemIdentifier in
            
            if case let Item.grid(item) = itemIdentifier {
                cell.nameLabel.text = item.name
            }
        }

        
        dataSource = DataSource(collectionView: distinctCollectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let section = SectionLayoutKind(rawValue: indexPath.section)
            
            switch section {
            case .list:
                return collectionView.dequeueConfiguredReusableCell(using: listCellRegisteration, for: indexPath, item: itemIdentifier)
            case .grid1:
                return collectionView.dequeueConfiguredReusableCell(using: gridCellRegisteration, for: indexPath, item: itemIdentifier)
            case .grid2:
                return collectionView.dequeueConfiguredReusableCell(using: gridCellRegisteration, for: indexPath, item: itemIdentifier)
            default:
                return UICollectionViewCell()
            }
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind,Item>()
        snapshot.appendSections([.list, .grid1, .grid2])
        _ = listData.map { snapshot.appendItems([.list($0)], toSection: .list) }
        _ = gridOneData.map { snapshot.appendItems([.grid($0)], toSection: .grid1) }
        _ = gridTwoData.map { snapshot.appendItems([.grid($0)], toSection: .grid2) }
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
  
