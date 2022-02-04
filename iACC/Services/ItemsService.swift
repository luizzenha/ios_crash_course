//
// Copyright © Essential Developer. All rights reserved.
//

import Foundation
import UIKit

protocol ItemService {
    func loadItems(completion: @escaping (_ result: Result<[ListItemViewModel], Error>) -> Void )
}

struct FriendsAPIItemsServiceAdapter : ItemService {
    let api: FriendsAPI
    let cache : FriendsCache
    let select : (Friend) -> Void
    
    func loadItems(completion: @escaping (Result<[ListItemViewModel], Error>) -> Void) {
        api.loadFriends {  result in
            DispatchQueue.mainAsyncIfNeeded {
                completion( result.map { items in
                    cache.save(items)
                    
                    return items.map { item in
                        ListItemViewModel(friend: item, selection: {
                            select(item)
                        })
                        
                    }
                })
            }
        }
    }
}


struct CardAPIItemsServiceAdapter : ItemService {
    let api: CardAPI
    let select : (Card) -> Void
    
    func loadItems(completion: @escaping (Result<[ListItemViewModel], Error>) -> Void) {
        api.loadCards { result in
            DispatchQueue.mainAsyncIfNeeded {
                completion(result.map { items in
                    items.map { item in
                        ListItemViewModel(card: item, selection: {
                            select(item)
                        })
                        
                    }
                })
            }
        }
    }
}

struct  TransfersAPIItemsServiceAdapter :ItemService {
    let api: TransfersAPI
    let select : (Transfer) -> Void
    let longDateStyle, fromSentTransfersScreen: Bool
    
    func loadItems (completion: @escaping (Result<[ListItemViewModel], Error>) -> Void) {
        api.loadTransfers { result in
            DispatchQueue.mainAsyncIfNeeded {
                completion(result.map { items in
                    items
                        .filter { fromSentTransfersScreen ? $0.isSender : !$0.isSender }
                        .map { item in
                            ListItemViewModel(transfer: item, longDateStyle: longDateStyle, selection: {
                                select(item)
                            })
                            
                        }
                })
            }
        }
    }
}
