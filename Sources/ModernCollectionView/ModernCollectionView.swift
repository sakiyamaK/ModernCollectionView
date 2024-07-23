//
//  MordernCollectionViewController.swift
//
//
//  Created by sakiyamaK on 2024/06/15.
//

// https://github.com/apple/swift-collections が必要

import UIKit
import Collections

public class ModernCollectionView<SectionIdentifierType, ItemIdentifierType>: UICollectionView where SectionIdentifierType : Hashable, SectionIdentifierType : Sendable, ItemIdentifierType : Hashable, ItemIdentifierType : Sendable {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private(set) var diffableDatasource: UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>!
    private(set) var cellRegistrations: OrderedDictionary<SectionIdentifierType, UICollectionView.CellRegistration<UICollectionViewCell, ItemIdentifierType>> = [:]
    
    init(collectionViewLayoutBuilder: (() -> UICollectionViewLayout),
         cellRegistrationHandlers: OrderedDictionary<SectionIdentifierType, UICollectionView.CellRegistration<UICollectionViewCell, ItemIdentifierType>.Handler>) {
        
        super.init(frame: .zero, collectionViewLayout: collectionViewLayoutBuilder())
        
        for (key, cellRegistrationHandler) in cellRegistrationHandlers {
            self.cellRegistrations[key] = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        }
        
        self.diffableDatasource = UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>(collectionView: self, cellProvider: { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(
                using: self.cellRegistrations.elements[indexPath.section].value,
                for: indexPath,
                item: itemIdentifier
            )
        })
    }
    
    init(collectionViewLayoutBuilder: (() -> UICollectionViewLayout),
         cellRegistrationHandlers: [UICollectionView.CellRegistration<UICollectionViewCell, ItemIdentifierType>.Handler]) where SectionIdentifierType == Int {

        super.init(frame: .zero, collectionViewLayout: collectionViewLayoutBuilder())
        
        for (idx, cellRegistrationHandler) in cellRegistrationHandlers.enumerated() {
            self.cellRegistrations[idx] = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        }
        
        self.diffableDatasource = UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>(collectionView: self, cellProvider: { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(
                using: self.cellRegistrations.elements[indexPath.section].value,
                for: indexPath,
                item: itemIdentifier
            )
        })
    }
    
    convenience init(collectionViewLayoutBuilder: (() -> UICollectionViewLayout),
                     _ cellRegistrationHandler: @escaping UICollectionView.CellRegistration<UICollectionViewCell, ItemIdentifierType>.Handler) where SectionIdentifierType == Int {
        self.init(collectionViewLayoutBuilder: collectionViewLayoutBuilder, cellRegistrationHandlers: [cellRegistrationHandler])
    }
    
    convenience init(collectionViewLayoutBuilder: (() -> UICollectionViewLayout),
                     cellRegistrationHandler: @escaping UICollectionView.CellRegistration<UICollectionViewCell, ItemIdentifierType>.Handler) where SectionIdentifierType == Int {
        self.init(collectionViewLayoutBuilder: collectionViewLayoutBuilder, cellRegistrationHandlers: [cellRegistrationHandler])
    }
                
    @discardableResult
    func apply(datasource: [SectionIdentifierType: [ItemIdentifierType]], animatingDifferences: Bool) -> Self {
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>()
        snapshot.appendSections(datasource.keys.map({ $0 }))
        for (section, items) in datasource {
            snapshot.appendItems(items, toSection: section)
        }
        diffableDatasource.apply(snapshot, animatingDifferences: animatingDifferences)
        
        return self
    }
    
    @discardableResult
    func apply(datasource: [[ItemIdentifierType]], animatingDifferences: Bool) -> Self where SectionIdentifierType == Int {
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>()
        snapshot.appendSections(Array((0..<datasource.count)))
        for (section, items) in datasource.enumerated() {
            snapshot.appendItems(items, toSection: section)
        }
        diffableDatasource.apply(snapshot, animatingDifferences: animatingDifferences)
        
        return self
    }

    
    @discardableResult
    func reload(items: [ItemIdentifierType], animatingDifferences: Bool) -> Self {
        var snapshot = diffableDatasource.snapshot()
        snapshot.reloadItems(items)
        diffableDatasource.apply(snapshot, animatingDifferences: animatingDifferences)
        
        return self
    }
    
    @discardableResult
    func reload(sections: [SectionIdentifierType], animatingDifferences: Bool) -> Self {
        var snapshot = diffableDatasource.snapshot()
        snapshot.reloadSections(sections)
        diffableDatasource.apply(snapshot, animatingDifferences: animatingDifferences)
        return self
    }
}
