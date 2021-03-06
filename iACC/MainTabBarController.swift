//	
// Copyright © Essential Developer. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    private var friendCache: FriendsCache!
    
    convenience init(friendCache : FriendsCache) {
        self.init(nibName: nil, bundle: nil)
        self.friendCache = friendCache
        self.setupViewController()
    }
    
    private func setupViewController() {
        viewControllers = [
            makeNav(for: makeFriendsList(), title: "Friends", icon: "person.2.fill"),
            makeTransfersList(),
            makeNav(for: makeCardsList(), title: "Cards", icon: "creditcard.fill"),
            makeNav(for: makeArtichelList(), title: "Articles", icon: "book.fill" )
        ]
    }
    
    private func makeNav(for vc: UIViewController, title: String, icon: String) -> UIViewController {
        vc.navigationItem.largeTitleDisplayMode = .always
        
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem.image = UIImage(
            systemName: icon,
            withConfiguration: UIImage.SymbolConfiguration(scale: .large)
        )
        nav.tabBarItem.title = title
        nav.navigationBar.prefersLargeTitles = true
        return nav
    }
    
    private func makeTransfersList() -> UIViewController {
        let sent = makeSentTransfersList()
        sent.navigationItem.title = "Sent"
        sent.navigationItem.largeTitleDisplayMode = .always
        
        let received = makeReceivedTransfersList()
        received.navigationItem.title = "Received"
        received.navigationItem.largeTitleDisplayMode = .always
        
        let vc = SegmentNavigationViewController(first: sent, second: received)
        vc.tabBarItem.image = UIImage(
            systemName: "arrow.left.arrow.right",
            withConfiguration: UIImage.SymbolConfiguration(scale: .large)
        )
        vc.title = "Transfers"
        vc.navigationBar.prefersLargeTitles = true
        return vc
    }
    
    private func makeFriendsList() -> ListViewController {
        let vc = ListViewController()
        let isPremium =  User.shared?.isPremium == true
        let apiAdapter = FriendsAPIItemsServiceAdapter(
            api: FriendsAPI.shared,
            cache: isPremium ? friendCache : NullFriendsCache(),
            select: { [weak vc] item in
                vc?.select(friend: item)
            }).retry(2)
        let cacheAdapter = CachedFriendsItemsServiceAdapter(cache: friendCache, select: { [weak vc] item in
            vc?.select(friend: item)
        })
        
        vc.service = isPremium ? apiAdapter.fallBack(cacheAdapter) : apiAdapter
        


        vc.title = "Friends"
        
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: vc, action: #selector(addFriend))
        return vc
    }
    
    private func makeSentTransfersList() -> ListViewController {
        let vc = ListViewController()
        vc.service = SentTransfersAPIItemsServiceAdapter(
            api: TransfersAPI.shared,
            select: {
                [weak vc] item in
                vc?.select(transfer: item)
            }).retry(1)

        vc.navigationItem.title = "Sent"
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: vc, action: #selector(sendMoney))
        return vc
    }
    
    private func makeReceivedTransfersList() -> ListViewController {
        let vc = ListViewController()
        vc.service = ReceivedTransfersAPIItemsServiceAdapter(
            api: TransfersAPI.shared,
            select: {
                [weak vc] item in
                vc?.select(transfer: item)
            }).retry(1)
        vc.navigationItem.title = "Received"
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Request", style: .done, target: vc, action: #selector(requestMoney))
        return vc
    }
    
    private func makeCardsList() -> ListViewController {
        let vc = ListViewController()
        vc.service = CardAPIItemsServiceAdapter(api: CardAPI.shared, select: {
            [weak vc] item in vc?.select(card: item)
        })
        vc.title = "Cards"
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: vc, action: #selector(addCard))
        
        return vc
    }
    
    private func makeArtichelList() -> ListViewController {
        let vc = ListViewController()
        vc.service = ArticleAPIItemsSerivceAdapter(api: ArticlesAPI.shared, select: {
            [weak vc] item in vc?.select(article: item)
        })
        vc.title = "Article"
        
        return vc
    }
    
}
