//
// Copyright © Essential Developer. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
	var items = [Any]()
	
	var retryCount = 0
	var maxRetryCount = 0
	var shouldRetry = false
	
	var longDateStyle = false
	
	var fromReceivedTransfersScreen = false
	var fromSentTransfersScreen = false
	var fromCardsScreen = false
	var fromFriendsScreen = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
		
		if fromFriendsScreen {
			shouldRetry = true
			maxRetryCount = 2
			
			title = "Friends"
			
			navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFriend))
			
		} else if fromCardsScreen {
			shouldRetry = false
			
			title = "Cards"
			
			navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCard))
			
		} else if fromSentTransfersScreen {
			shouldRetry = true
			maxRetryCount = 1
			longDateStyle = true

			navigationItem.title = "Sent"
			navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(sendMoney))

		} else if fromReceivedTransfersScreen {
			shouldRetry = true
			maxRetryCount = 1
			longDateStyle = false
			
			navigationItem.title = "Received"
			navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Request", style: .done, target: self, action: #selector(requestMoney))
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if tableView.numberOfRows(inSection: 0) == 0 {
			refresh()
		}
	}
	
	@objc private func refresh() {
		refreshControl?.beginRefreshing()
		if fromFriendsScreen {
			FriendsAPI.shared.loadFriends { [weak self] result in
				DispatchQueue.mainAsyncIfNeeded {
					self?.handleAPIResult(result)
				}
			}
		} else if fromCardsScreen {
			CardAPI.shared.loadCards { [weak self] result in
				DispatchQueue.mainAsyncIfNeeded {
					self?.handleAPIResult(result)
				}
			}
		} else if fromSentTransfersScreen || fromReceivedTransfersScreen {
			TransfersAPI.shared.loadTransfers { [weak self] result in
				DispatchQueue.mainAsyncIfNeeded {
					self?.handleAPIResult(result)
				}
			}
		} else {
			fatalError("unknown context")
		}
	}
	
	private func handleAPIResult<T>(_ result: Result<[T], Error>) {
		switch result {
		case let .success(items):
			if fromFriendsScreen && User.shared?.isPremium == true {
				(UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate).cache.save(items as! [Friend])
			}
			self.retryCount = 0
			
			var filteredItems = items as [Any]
			if let transfers = items as? [Transfer] {
				if fromSentTransfersScreen {
					filteredItems = transfers.filter(\.isSender)
				} else {
					filteredItems = transfers.filter { !$0.isSender }
				}
			}
			
			self.items = filteredItems
			self.refreshControl?.endRefreshing()
			self.tableView.reloadData()
			
		case let .failure(error):
			if shouldRetry && retryCount < maxRetryCount {
				retryCount += 1
				
				refresh()
				return
			}
			
			retryCount = 0
			
			if fromFriendsScreen && User.shared?.isPremium == true {
				(UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate).cache.loadFriends { [weak self] result in
					DispatchQueue.mainAsyncIfNeeded {
						switch result {
						case let .success(items):
							self?.items = items
							self?.tableView.reloadData()
							
						case let .failure(error):
							let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
							alert.addAction(UIAlertAction(title: "Ok", style: .default))
							self?.presenterVC.present(alert, animated: true)
						}
						self?.refreshControl?.endRefreshing()
					}
				}
			} else {
				let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "Ok", style: .default))
				self.presenterVC.present(alert, animated: true)
				self.refreshControl?.endRefreshing()
			}
		}
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		items.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let item = items[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "ItemCell")
        let configItem: ListItemViewModel
        if let friend = item as? Friend {
            configItem = ListItemViewModel(friend: friend)
        } else if let card = item as? Card {
            configItem = ListItemViewModel(card: card)
        } else if let transfer = item as? Transfer {
            configItem = ListItemViewModel(transfer: transfer, longDateStyle: longDateStyle)
        } else {
            fatalError("unknown item: \(item)")
        }
		cell.configure(configItem)
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let item = items[indexPath.row]
		if let friend = item as? Friend {
			let vc = FriendDetailsViewController()
			vc.friend = friend
			navigationController?.pushViewController(vc, animated: true)
		} else if let card = item as? Card {
			let vc = CardDetailsViewController()
			vc.card = card
			navigationController?.pushViewController(vc, animated: true)
		} else if let transfer = item as? Transfer {
			let vc = TransferDetailsViewController()
			vc.transfer = transfer
			navigationController?.pushViewController(vc, animated: true)
		} else {
			fatalError("unknown item: \(item)")
		}
	}
	
	@objc func addCard() {
		navigationController?.pushViewController(AddCardViewController(), animated: true)
	}
	
	@objc func addFriend() {
		navigationController?.pushViewController(AddFriendViewController(), animated: true)
	}
	
	@objc func sendMoney() {
		navigationController?.pushViewController(SendMoneyViewController(), animated: true)
	}
	
	@objc func requestMoney() {
		navigationController?.pushViewController(RequestMoneyViewController(), animated: true)
	}
}

extension UITableViewCell {
	func configure(_ item: ListItemViewModel) {
        textLabel?.text = item.title
        detailTextLabel?.text = item.subTitle
	}
}
