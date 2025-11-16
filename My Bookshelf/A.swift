//
//  A.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 14.11.25.
//

/*

BookApp/
 ├─ App/
 │   ├─ AppDelegate.swift
 │   ├─ SceneDelegate.swift
 │   ├─ RootTabBarController.swift
 │   └─ Navigation/
 │       └─ AppCoordinator.swift        // optional
 │
 ├─ Resources/
 │   ├─ Assets.xcassets
 │   ├─ Colors.xcassets
 │   ├─ Fonts/
 │   └─ Localizable.strings
 │
 ├─ Core/
 │   ├─ Networking/
 │   │   ├─ APIClient.swift
 │   │   └─ Endpoints/
 │   │       └─ OpenLibraryAPI.swift
 │   ├─ Models/
 │   │   ├─ Book.swift
 │   │   ├─ WorkSummary.swift
 │   │   ├─ WorkDetail.swift
 │   │   └─ UserLibraryModels.swift     // ShelfCollection, ListItem etc.
 │   ├─ Persistence/
 │   │   ├─ CoreDataStack.swift
 │   │   ├─ ShelfRepository.swift
 │   │   └─ FavoritesRepository.swift
 │   ├─ ImageLoading/
 │   │   └─ ImageLoader.swift
 │   └─ Utilities/
 │       ├─ Reusable.swift              // protocols, helpers
 │       └─ UIHelpers.swift
 │
 ├─ Features/
 │   ├─ Shelf/
 │   │   ├─ ShelfViewController.swift
 │   │   ├─ ShelfViewModel.swift
 │   │   ├─ ShelfCollectionCell.swift
 │   │   ├─ ShelfBooksViewController.swift
 │   │   ├─ ShelfBooksViewModel.swift
 │   │   └─
 │   │
 │   ├─ Explore/
 │   │   ├─ ExploreViewController.swift
 │   │   ├─ ExploreViewModel.swift
 │   │   ├─ BookCell.swift
 │   │   ├─ BookSectionHeaderView.swift
 │   │   ├─ SearchResultsViewController.swift (optional)
 │   │   └─ ExploreCoordinator.swift (optional)
 │   │
 │   ├─ Lists/
 │   │   ├─ ListsViewController.swift
 │   │   ├─ ListsViewModel.swift
 │   │   └─ ListBookCell.swift
 │   │
 │   ├─ Settings/
 │   │   ├─ SettingsViewController.swift
 │   │   └─ SettingsViewModel.swift
 │   │
 │   └─ Common/
 │       ├─ BookDetailViewController.swift
 │       ├─ BookDetailViewModel.swift
 │       └─ CommonCells/
 │           └─ BasicBookCell.swift
 │
 └─ Tests/
     ├─ NetworkingTests/
     ├─ ModelDecodingTests/
     └─ PersistenceTests/



*/
