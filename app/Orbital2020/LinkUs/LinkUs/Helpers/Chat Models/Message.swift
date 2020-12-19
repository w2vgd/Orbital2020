//
//  Message.swift
//  LinkUs
//
//  Created by macos on 5/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import Foundation
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

