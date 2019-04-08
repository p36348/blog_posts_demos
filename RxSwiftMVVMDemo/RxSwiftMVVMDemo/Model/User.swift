//
//  User.swift
//  RxSwiftMVVMDemo
//
//  Created by P36348 on 24/03/2019.
//  Copyright © 2019 P36348. All rights reserved.
//

import Foundation

class User {
    var username: String
    var uid: String
    var date: Date
    
    init(username: String, uid: String, date: Date) {
        self.username = username
        self.uid = uid
        self.date = date
    }
}
