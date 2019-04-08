//
//  UserService.swift
//  RxSwiftMVVMDemo
//
//  Created by P36348 on 24/03/2019.
//  Copyright © 2019 P36348. All rights reserved.
//

import UIKit
import RxSwift

enum SignState {
   case signed(User), signingIn, unsigned, signingUp, signingOut
}

class UserService {

    static let shared: UserService = UserService()
    
    var state: SignState = .unsigned {
        didSet {
            internalSignState.onNext(state)
        }
    }
    
    var rx_signState: Observable<SignState>
    
    private let internalSignState: ReplaySubject<SignState> = ReplaySubject.create(bufferSize: 1)
    
    private init() {
        rx_signState = internalSignState.startWith(self.state)

    }
    
    func performSignin(username: String, password: String) -> Observable<User> {
        print("call perform signin")
        // fake request
        self.state = .signingIn
        return Observable.create({ [unowned self] (observer) -> Disposable in
            Thread.sleep(forTimeInterval: 1)
            let user = User(username: username, uid: "007", date: Date())
            Thread.sleep(forTimeInterval: 1)
            observer.onNext(user)
            self.state = .signed(user)
            return Disposables.create()
        })
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.default))
        .observeOn(MainScheduler.asyncInstance)
    }
    
    func performSignout() -> Observable<String> {
        print("call perform signout")
        // fake request
        self.state = .signingOut
        return Observable.create({ (observer) -> Disposable in
            Thread.sleep(forTimeInterval: 3)
            observer.onNext("已经退出登录")
            self.state = .unsigned
            return Disposables.create()
        })
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.default))
            .observeOn(MainScheduler.asyncInstance)
    }
}
