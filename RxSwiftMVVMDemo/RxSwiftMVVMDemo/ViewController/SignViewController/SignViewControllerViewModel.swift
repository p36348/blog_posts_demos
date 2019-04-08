//
//  SignViewControllerViewModel.swift
//  RxSwiftMVVMDemo
//
//  Created by P36348 on 24/03/2019.
//  Copyright © 2019 P36348. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SignViewControllerViewModel {
    // input
    var usernameInput: BehaviorRelay<String> = BehaviorRelay(value: "")
    var passwordInput: BehaviorRelay<String> = BehaviorRelay(value: "")
    // output
    var usernameInputEnable: Observable<Bool>
    var passwordInputEnable: Observable<Bool>
    var submitEnable: BehaviorRelay<Bool> = BehaviorRelay(value: true)
    var submitTitle: BehaviorRelay<String> = BehaviorRelay(value: "Submit")
    var indicatorHidden: Observable<Bool>
    var stateHidden: Observable<Bool>
    var state: Observable<String> {
        return _internalState.asObservable()
    }
    // 登录状态
    private var signState: BehaviorSubject<String> = BehaviorSubject(value: "")
    // 内部状态
    private var _internalState: BehaviorSubject<String> = BehaviorSubject(value: "")
    
    private weak var disposeBag: DisposeBag!
    
    init(disposeBag: DisposeBag!) {
        self.disposeBag = disposeBag
        
        UserService.shared.rx_signState.subscribe(onNext: { (state) in
            print("state changed:", state)
        }).disposed(by: self.disposeBag)
        
        let isSigning: Observable<Bool> = UserService.shared.rx_signState
            .map({
            switch $0 {
            case .signingIn, .signingOut:
                return true
            default:
                return false
            }
        })
        
        let isUnsigned = UserService.shared.rx_signState.map({state -> Bool in
            if case SignState.unsigned = state {
                return true
            }else {
                return false
            }
        })
        
        self.usernameInputEnable = isUnsigned
        
        self.passwordInputEnable = Observable.combineLatest(
            self.usernameInput,
            isSigning,
            isUnsigned
            )
            .map({$0.0.count >= 4 && !$0.1 && $0.2})
            .observeOn(MainScheduler.asyncInstance)
        
        self.indicatorHidden = isSigning.map({!$0})
        self.stateHidden = self.indicatorHidden.map({!$0})
        Observable.combineLatest(
            self.usernameInput,
            self.passwordInput,
            isSigning
            )
            .map({ ($0.0.count >= 4) && (!$0.1.isEmpty) && !$0.2 })
            .bind(to: self.submitEnable)
            .disposed(by: self.disposeBag)
        
        UserService.shared.rx_signState.map({state -> String in
            if case SignState.signed(_) = state {
                return "SignOut"
            }else {
                return "Submit"
            }
        })
            .bind(to: self.submitTitle)
            .disposed(by: self.disposeBag)
        
        // 用户输入状态
        let inputState: Observable<String> = Observable.combineLatest(
            self.usernameInput,
            self.passwordInput
            )
            .map({ val in
                let username = val.0, password = val.1
                
                if username.isEmpty {
                    return "请填写用户名"
                }else if username.count < 4 {
                    return "用户名太短, 应该大于4位"
                }else if password.isEmpty {
                    return "请填写密码"
                }
                return ""
            })
        
        // 登录状态和用户输入状态合并就是最终状态
        Observable.merge(self.signState, inputState)
            .bind(to: self._internalState)
            .disposed(by: self.disposeBag)
    }
    
    func handleClickSubmit() {
        switch UserService.shared.state {
        case SignState.signed(_) :
            self.performSignOut()
        case SignState.unsigned:
            self.performSignin()
        default:
            fatalError()
        }
    }
    
    func performSignOut() {
        UserService.shared.performSignout()
            .subscribe(onNext: {[unowned self] _ in self.updateState("已经退出登录")})
            .disposed(by: self.disposeBag)
    }
    
    func performSignin() {
        Observable.combineLatest(self.usernameInput, self.passwordInput)
            .take(1)
            .flatMap({[unowned self] in self.performSignin(username: $0, password: $1)})
            .subscribe(onNext: {[unowned self] in self.updateState($0)})
            .disposed(by: self.disposeBag)
    }
    
    func performSignin(username: String, password: String) -> Observable<String> {
        return UserService.shared.performSignin(username: username, password: password)
            .map({"当前用户: \($0.username)\n登录时间: \($0.date)"})
            .catchError({Observable.of(($0 as NSError).domain)})
    }
    
    func updateState(_ value: String) {
        signState.onNext(value)
    }
}
