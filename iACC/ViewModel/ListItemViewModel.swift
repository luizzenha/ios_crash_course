//	
// Copyright © Essential Developer. All rights reserved.
//

import Foundation

struct ListItemViewModel {
    let title: String
    let subTitle: String
    let select: () -> Void
    
    init(item:Any, longDateStyle: Bool, selection: @escaping () -> Void ) {
        if let friend = item as? Friend {
            self.init(friend: friend, selection: selection)
        } else if let card = item as? Card {
            self.init(card: card,selection: selection)
        } else if let transfer = item as? Transfer {
            self.init( transfer: transfer, longDateStyle: longDateStyle, selection: selection)
        }else{
            fatalError("Unknow item type")
        }
    }
    
}

extension ListItemViewModel {
    
    init( transfer: Transfer, longDateStyle: Bool, selection: @escaping () -> Void ) {
        self.select = selection
        let numberFormatter = Formatters.number
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = transfer.currencyCode
        
        let amount = numberFormatter.string(from: transfer.amount as NSNumber)!
        title = "\(amount) • \(transfer.description)"
        
        let dateFormatter = Formatters.date
        if longDateStyle {
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            subTitle = "Sent to: \(transfer.recipient) on \(dateFormatter.string(from: transfer.date))"
        } else {
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            subTitle = "Received from: \(transfer.sender) on \(dateFormatter.string(from: transfer.date))"
        }
        
    }
}

extension ListItemViewModel {
    
    init( friend: Friend, selection: @escaping () -> Void ) {
        select = selection
        title = friend.name
        subTitle = friend.phone
        
    }
}


extension ListItemViewModel {
    
    init( card: Card , selection: @escaping () -> Void ) {
        select = selection
        title = card.number
        subTitle = card.holder
        
    }
}
