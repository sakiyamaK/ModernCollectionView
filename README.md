
ModernCollectionView is a DSL to make CompositionalLayout, DiffableDatasources and UIContentConfiguration easy on an iOS.

## Contents

- [Installation](#installation)
- [Usage](#usage)
- [License](#license)

## Installation

### Swift Package Manager

[Swift Package Manager](https://swift.org/package-manager/) is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

To integrate ModernCollectionView into your Xcode project using Swift Package Manager, add it to the dependencies value of your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/sakiyamaK/ModernCollectionView", .upToNextMajor(from: "0.0.2"))
]
```

---

## Usage

### Quick Start

## ModernCollectionView

```swift:ModernCollectionViewController.swift

import UIKit
import ModernCollectionView

class ModernCollectionViewController: UIViewController {
    
    private let datasourceWithSection = [
        ModernCollectionViewSection.section1: Array(0..<10),
        ModernCollectionViewSection.section2: Array(20..<30)
    ]
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let collectionView = ModernCollectionView(collectionViewLayoutBuilder: {
            UICollectionViewCompositionalLayout.list(using: .init(appearance: .grouped))
        }, cellRegistrationHandlers: [
            .section1: { (cell, indexPath, item) -> Void in
                cell.contentConfiguration = ModernContentView1.Configuration(item: item)
            },
            .section2: { (cell, indexPath, item) -> Void in
                cell.contentConfiguration = ModernContentView1.Configuration(item: item)
            }
        ]).apply(datasource: datasourceWithSection, animatingDifferences: false)
        
        // autolayout
        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
    }

}
```

## UICollectionView

If you use a regular UICollectionView without the library, it would look like this.

```swift:NormollCectionView.swift
public class NormalCollectionViewController: UIViewController {
    
    private var datasourceWithSection = [
        ModernCollectionViewSection.section1: Array(0..<10),
        ModernCollectionViewSection.section2: Array(20..<30)
    ]
    
    private var diffableDatasource: UICollectionViewDiffableDataSource<ModernCollectionViewSection, Int>!

    private var cell1: UICollectionView.CellRegistration<UICollectionViewCell, Int> = .init(handler: { cell, indexPath, item in
        cell.contentConfiguration = ModernContentView1.Configuration(item: item)
    })
    private var cell2: UICollectionView.CellRegistration<UICollectionViewCell, Int> = .init(handler: { cell, indexPath, item in
        cell.contentConfiguration = ModernContentView2.Configuration(item: item)
    })
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout.list(using: .init(appearance: .grouped)))
        
        // autolayout
        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        
        diffableDatasource = .init(collectionView: collectionView, cellProvider: { [weak self]  collectionView, indexPath, itemIdentifier in
            guard let self else { fatalError() }
            let section = ModernCollectionViewSection(rawValue: indexPath.section)!
            let item = self.datasourceWithSection[section]![indexPath.item]
            return switch section {
            case .section1:
                collectionView.dequeueConfiguredReusableCell(using: cell1, for: indexPath, item: item)
            case .section2:
                collectionView.dequeueConfiguredReusableCell(using: cell2, for: indexPath, item: item)
            }
        })

        var snapshot = NSDiffableDataSourceSnapshot<ModernCollectionViewSection, Int>()
        snapshot.appendSections(datasourceWithSection.map({ $0.key }))
        for (section, items) in datasourceWithSection {
            snapshot.appendItems(items, toSection: section)
        }
        diffableDatasource.apply(snapshot, animatingDifferences: true)
    }
}
```

## Others

other sourcecodes

```swift:others.swift

enum ModernCollectionViewSection: Hashable, Sendable {
    case section1, section2
}

class ModernContentView: UIView, UIContentView {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    struct Configuration: UIContentConfiguration, Equatable {
        
        let item: Int
        
        func makeContentView() -> UIView & UIContentView {
            ModernContentView1(configuration: self)
        }
        
        public func updated(for state: UIConfigurationState) -> Self {
            self
        }
    }
    
    var configuration: UIContentConfiguration {
        didSet { configure() }
    }
    
    init(configuration: Configuration) {
        self.configuration = configuration
        super.init(frame: .zero)
        
        // view layout
    }
    
    private var fixedConfiguration: Configuration {
        configuration as! Configuration
    }
    
    private func configure() {
        // update view
    }
}
```

## License

ModernCollectionView is released under the MIT license. See LICENSE for details.