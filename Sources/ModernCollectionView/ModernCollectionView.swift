//
//  MordernCollectionView.swift
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
    
    public private(set) var diffableDataSource: UICollectionViewDiffableDataSource<SectionID, ItemID>!
    public private(set) var cellRegistrations: OrderedDictionary<CellID, UICollectionView.CellRegistration<UICollectionViewCell, ItemID>> = [:]
    public private(set) var headerViews: [Int: UICollectionView.SupplementaryRegistration<UICollectionViewCell>] = [:]
    public private(set) var footerViews: [Int: UICollectionView.SupplementaryRegistration<UICollectionViewCell>] = [:]

    public init(
        collectionViewLayoutHandler: (() -> UICollectionViewLayout),
        cellRegistrationHandlers: OrderedDictionary<CellID, UICollectionView.CellRegistration<UICollectionViewCell, ItemID>.Handler> = [:],
        headerViewHandlers: [Int: () -> UIContentConfiguration] = [:],
        footerViewHandlers: [Int: () -> UIContentConfiguration] = [:]
    ) {
        
        super.init(frame: .zero, collectionViewLayout: collectionViewLayoutHandler())
        
        set(cellRegistrationHandlers: cellRegistrationHandlers)
        
        self.diffableDataSource = UICollectionViewDiffableDataSource<SectionID, ItemID>(collectionView: self, cellProvider: { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(
                using: self.cellRegistrations.elements[indexPath.section].value,
                for: indexPath,
                item: itemIdentifier
            )
        })
        
        self.headerViews = Dictionary(uniqueKeysWithValues: headerViewHandlers.compactMap({ sectionIndex, _ in
            let value = UICollectionView.SupplementaryRegistration<UICollectionViewCell>(elementKind: UICollectionView.elementKindSectionHeader) {[weak self] (supplementaryView, elementKind, indexPath) in
                guard let self, let headerViewHandler = headerViewHandlers[indexPath.section] else { fatalError() }
                supplementaryView.contentConfiguration = headerViewHandler()
            }
            return (sectionIndex, value)
        }))
        
        self.footerViews = Dictionary(uniqueKeysWithValues: footerViewHandlers.compactMap({ sectionIndex, _ in
            let value = UICollectionView.SupplementaryRegistration<UICollectionViewCell>(elementKind: UICollectionView.elementKindSectionFooter) {[weak self] (supplementaryView, elementKind, indexPath) in
                guard let self, let footerViewHandler = footerViewHandlers[indexPath.section] else { fatalError() }
                supplementaryView.contentConfiguration = footerViewHandler()
            }
            return (sectionIndex, value)
        }))
    }
    
    public convenience init(collectionViewLayoutHandler: (() -> UICollectionViewLayout), cellRegistrationHandlers: [UICollectionView.CellRegistration<UICollectionViewCell, ItemID>.Handler]) where CellID == Int {
        
        self.init(collectionViewLayoutHandler: collectionViewLayoutHandler, cellRegistrationHandlers: OrderedDictionary<CellID, UICollectionView.CellRegistration<UICollectionViewCell, ItemID>.Handler>(
            uniqueKeysWithValues: cellRegistrationHandlers.enumerated().compactMap { offset, element in
                (offset, element)
            }
        ))
    }
    
    public convenience init(
        collectionViewLayoutHandler: (() -> UICollectionViewLayout),
        _ cellRegistrationHandler: @escaping UICollectionView.CellRegistration<UICollectionViewCell, ItemID>.Handler) where CellID == Int {
            self.init(collectionViewLayoutHandler: collectionViewLayoutHandler, cellRegistrationHandlers: [cellRegistrationHandler])
        }
    
    public convenience init(
        collectionViewLayoutHandler: (() -> UICollectionViewLayout),
        cellRegistrationHandler: @escaping UICollectionView.CellRegistration<UICollectionViewCell, ItemID>.Handler) where CellID == Int {
            self.init(collectionViewLayoutHandler: collectionViewLayoutHandler, cellRegistrationHandlers: [cellRegistrationHandler])
        }
}

public extension ModernCollectionView {
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
    
    @discardableResult
    func set(headerViewHandlers: [Int: () -> UIContentConfiguration]) -> Self {
        self.headerViews = Dictionary(uniqueKeysWithValues: headerViewHandlers.compactMap({ sectionIndex, _ in
            let value = UICollectionView.SupplementaryRegistration<UICollectionViewCell>(elementKind: UICollectionView.elementKindSectionHeader) {[weak self] (supplementaryView, elementKind, indexPath) in
                guard let headerViewHandler = headerViewHandlers[indexPath.section] else { fatalError() }
                supplementaryView.contentConfiguration = headerViewHandler()
            }
            return (sectionIndex, value)
        }))
        return self
    }
    
    @discardableResult
    func set(headerConfigurationDic: [Int: UIContentConfiguration]) -> Self {
        self.headerViews = Dictionary(uniqueKeysWithValues: headerConfigurationDic.compactMap({ sectionIndex, _ in
            let value = UICollectionView.SupplementaryRegistration<UICollectionViewCell>(elementKind: UICollectionView.elementKindSectionHeader) { (supplementaryView, elementKind, indexPath) in
                guard let headerConfiguration = headerConfigurationDic[indexPath.section] else { fatalError() }
                supplementaryView.contentConfiguration = headerConfiguration
            }
            return (sectionIndex, value)
        }))
        return self
    }

    @discardableResult
    func set(footerViewHandlers: [Int: () -> UIContentConfiguration]) -> Self {
        self.footerViews = Dictionary(uniqueKeysWithValues: footerViewHandlers.compactMap({ sectionIndex, _ in
            let value = UICollectionView.SupplementaryRegistration<UICollectionViewCell>(elementKind: UICollectionView.elementKindSectionFooter) { (supplementaryView, elementKind, indexPath) in
                guard let footerViewHandler = footerViewHandlers[indexPath.section] else { fatalError() }
                supplementaryView.contentConfiguration = footerViewHandler()
            }
            return (sectionIndex, value)
        }))
        return self
    }
    
    @discardableResult
    func apply(dataSource: OrderedDictionary<SectionID, [ItemID]>, animatingDifferences: Bool) -> Self {
        
        diffableDataSource.supplementaryViewProvider = {[weak self] collectionView, kind, indexPath in
            guard let self else { fatalError() }
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                guard let headerView = self.headerViews[indexPath.section] else { fatalError() }
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerView, for: indexPath)
            case UICollectionView.elementKindSectionFooter:
                guard let footerView = self.footerViews[indexPath.section] else { fatalError() }
                return collectionView.dequeueConfiguredReusableSupplementary(using: footerView, for: indexPath)
            default:
                fatalError()
            }
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<SectionID, ItemID>()
        snapshot.appendSections(dataSource.keys.map({ $0 }))
        for (section, items) in dataSource {
            snapshot.appendItems(items, toSection: section)
        }
        diffableDataSource.apply(snapshot, animatingDifferences: animatingDifferences)
        
        return self
    }
    
    @discardableResult
    func apply(dataSource: [[ItemID]], animatingDifferences: Bool) -> Self where SectionID == Int {
        apply(dataSource: OrderedDictionary(uniqueKeysWithValues: dataSource.enumerated().compactMap({ index, element in
            (index, element)
        })), animatingDifferences: animatingDifferences)
    }
    
    @discardableResult
    func reload(items: [ItemID], animatingDifferences: Bool) -> Self {
        var snapshot = diffableDataSource.snapshot()
        snapshot.reloadItems(items)
        diffableDataSource.apply(snapshot, animatingDifferences: animatingDifferences)
        
        return self
    }
    
    @discardableResult
    func reload(sections: [SectionID], animatingDifferences: Bool) -> Self {
        var snapshot = diffableDataSource.snapshot()
        snapshot.reloadSections(sections)
        diffableDataSource.apply(snapshot, animatingDifferences: animatingDifferences)
        return self
    }
}
