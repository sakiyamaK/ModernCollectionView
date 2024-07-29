//
//  MordernCollectionViewController.swift
//
//
//  Created by sakiyamaK on 2024/06/15.
//

// https://github.com/apple/swift-collections が必要

import UIKit
import Collections

public class ModernCollectionView<SectionID, ItemID, CellID>: UICollectionView where
    SectionID: Hashable, SectionID: Sendable,
    ItemID: Hashable, ItemID: Sendable,
    CellID: Hashable, CellID: Sendable {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private(set) var diffableDatasource: UICollectionViewDiffableDataSource<SectionID, ItemID>!
    private(set) var cellRegistrations: OrderedDictionary<CellID, UICollectionView.CellRegistration<UICollectionViewCell, ItemID>> = [:]
    
    @discardableResult
    func set(cellRegistrationHandlers: OrderedDictionary<CellID, UICollectionView.CellRegistration<UICollectionViewCell, ItemID>.Handler>) -> Self {
        for (key, cellRegistrationHandler) in cellRegistrationHandlers {
            self.cellRegistrations[key] = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        }
        return self
    }
    
    @discardableResult
    func set(cellRegistrationHandlers: [UICollectionView.CellRegistration<UICollectionViewCell, ItemID>.Handler]) -> Self where CellID == Int {
        for (idx, cellRegistrationHandler) in cellRegistrationHandlers.enumerated() {
            self.cellRegistrations[idx] = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        }
        return self
    }
    
    public init(collectionViewLayoutBuilder: (() -> UICollectionViewLayout)) {
        
        super.init(frame: .zero, collectionViewLayout: collectionViewLayoutBuilder())
                
        self.diffableDatasource = UICollectionViewDiffableDataSource<SectionID, ItemID>(collectionView: self, cellProvider: { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(
                using: self.cellRegistrations.elements[indexPath.section].value,
                for: indexPath,
                item: itemIdentifier
            )
        })
    }
    
    public init(collectionViewLayoutBuilder: (() -> UICollectionViewLayout), cellRegistrationHandlers: OrderedDictionary<CellID, UICollectionView.CellRegistration<UICollectionViewCell, ItemID>.Handler>) {
        
        super.init(frame: .zero, collectionViewLayout: collectionViewLayoutBuilder())
        
        for (key, cellRegistrationHandler) in cellRegistrationHandlers {
            self.cellRegistrations[key] = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        }
        
        self.diffableDatasource = UICollectionViewDiffableDataSource<SectionID, ItemID>(collectionView: self, cellProvider: { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(
                using: self.cellRegistrations.elements[indexPath.section].value,
                for: indexPath,
                item: itemIdentifier
            )
        })
    }
    
    public init(collectionViewLayoutBuilder: (() -> UICollectionViewLayout), cellRegistrationHandlers: [UICollectionView.CellRegistration<UICollectionViewCell, ItemID>.Handler]) where CellID == Int {

        super.init(frame: .zero, collectionViewLayout: collectionViewLayoutBuilder())
        
        for (idx, cellRegistrationHandler) in cellRegistrationHandlers.enumerated() {
            self.cellRegistrations[idx] = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        }
        
        self.diffableDatasource = UICollectionViewDiffableDataSource<SectionID, ItemID>(collectionView: self, cellProvider: { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(
                using: self.cellRegistrations.elements[indexPath.section].value,
                for: indexPath,
                item: itemIdentifier
            )
        })
    }
    
    public convenience init(
        collectionViewLayoutBuilder: (() -> UICollectionViewLayout),
        _ cellRegistrationHandler: @escaping UICollectionView.CellRegistration<UICollectionViewCell, ItemID>.Handler) where CellID == Int {
        self.init(collectionViewLayoutBuilder: collectionViewLayoutBuilder, cellRegistrationHandlers: [cellRegistrationHandler])
    }
    
    public convenience init(
        collectionViewLayoutBuilder: (() -> UICollectionViewLayout),
        cellRegistrationHandler: @escaping UICollectionView.CellRegistration<UICollectionViewCell, ItemID>.Handler) where CellID == Int {
        self.init(collectionViewLayoutBuilder: collectionViewLayoutBuilder, cellRegistrationHandlers: [cellRegistrationHandler])
    }
                
    @discardableResult
    public func apply(datasource: [SectionID: [ItemID]], animatingDifferences: Bool) -> Self {
        var snapshot = NSDiffableDataSourceSnapshot<SectionID, ItemID>()
        snapshot.appendSections(datasource.keys.map({ $0 }))
        for (section, items) in datasource {
            snapshot.appendItems(items, toSection: section)
        }
        diffableDatasource.apply(snapshot, animatingDifferences: animatingDifferences)
        
        return self
    }
    
    @discardableResult
    public func apply(datasource: [[ItemID]], animatingDifferences: Bool) -> Self where SectionID == Int {
        var snapshot = NSDiffableDataSourceSnapshot<SectionID, ItemID>()
        snapshot.appendSections(Array((0..<datasource.count)))
        for (section, items) in datasource.enumerated() {
            snapshot.appendItems(items, toSection: section)
        }
        diffableDatasource.apply(snapshot, animatingDifferences: animatingDifferences)
        
        return self
    }
    
    @discardableResult
    public func reload(items: [ItemID], animatingDifferences: Bool) -> Self {
        var snapshot = diffableDatasource.snapshot()
        snapshot.reloadItems(items)
        diffableDatasource.apply(snapshot, animatingDifferences: animatingDifferences)
        
        return self
    }
    
    @discardableResult
    public func reload(sections: [SectionID], animatingDifferences: Bool) -> Self {
        var snapshot = diffableDatasource.snapshot()
        snapshot.reloadSections(sections)
        diffableDatasource.apply(snapshot, animatingDifferences: animatingDifferences)
        return self
    }
}
