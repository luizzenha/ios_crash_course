//	
// Copyright © Essential Developer. All rights reserved.
//

import Foundation

struct ListItemViewModel {
    var title: String
    var subTitle: String
    
}

extension ListItemViewModel {
    
    init( transfer: Transfer, longDateStyle: Bool ) {
        let numberFormatter = Formatters.number
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = transfer.currencyCode
        
        let amount = numberFormatter.string(from: transfer.amount as NSNumber)!
        self.title = "\(amount) • \(transfer.description)"
        
        let dateFormatter = Formatters.date
        if longDateStyle {
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            self.subTitle = "Sent to: \(transfer.recipient) on \(dateFormatter.string(from: transfer.date))"
        } else {
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            self.subTitle = "Received from: \(transfer.sender) on \(dateFormatter.string(from: transfer.date))"
        }
        
    }
}

extension ListItemViewModel {
    
    init( friend: Friend) {
        title = friend.name
        subTitle = friend.phone
        
    }
}


extension ListItemViewModel {
    
    init( card: Card) {
        title = card.number
        subTitle = card.holder
        
    }
}
