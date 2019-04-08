//
//  SignViewController.swift
//  RxSwiftMVVMDemo
//
//  Created by P36348 on 24/03/2019.
//  Copyright © 2019 P36348. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SignViewController: UIViewController {
    // 懒加载, 传入disposeBag
    lazy var viewModel: SignViewControllerViewModel = SignViewControllerViewModel(disposeBag: self.disposeBag)
    // UI
    @IBOutlet weak var usernameTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    // deinit之后释放subscribtions
    let disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.bindObservables()
    }
    
    func bindObservables() {
        // 数据输入 viewModel
        self.usernameTf.rx.text.orEmpty
            .bind(to: self.viewModel.usernameInput)
            .disposed(by: self.disposeBag)
        
        self.passwordTf.rx.text.orEmpty
            .bind(to: self.viewModel.passwordInput)
            .disposed(by: self.disposeBag)
        
        self.submitButton.rx.tap
            .subscribe(onNext: {_ in self.viewModel.handleClickSubmit()})
            .disposed(by: self.disposeBag)
        
        
        // viewModel 数据输出
        self.viewModel.submitEnable
            .bind(to: self.submitButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        self.viewModel.usernameInputEnable
            .bind(to: self.usernameTf.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        self.viewModel.passwordInputEnable
            .bind(to: self.passwordTf.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        self.viewModel.submitTitle
            .bind(to: self.submitButton.rx.title())
            .disposed(by: self.disposeBag)
        
        self.viewModel.state
            .bind(to: self.stateLabel.rx.text)
            .disposed(by: self.disposeBag)
        
        self.viewModel.indicatorHidden
            .bind(to: self.indicatorView.rx.isHidden)
            .disposed(by: self.disposeBag)
        
        self.viewModel.indicatorHidden
            .map({!$0})
            .bind(to: self.indicatorView.rx.isAnimating)
            .disposed(by: self.disposeBag)
        
        self.viewModel.stateHidden
            .bind(to: self.stateLabel.rx.isHidden)
            .disposed(by: self.disposeBag)
    }
}



