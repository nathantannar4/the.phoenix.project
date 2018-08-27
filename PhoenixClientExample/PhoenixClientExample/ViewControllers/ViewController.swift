//
//  ViewController.swift
//  PhoenixClientExample
//
//  Created by Nathan Tannar on 2018-08-20.
//  Copyright © 2018 Nathan Tannar. All rights reserved.
//

import UIKit
import Promises


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let auth = Auth(username: "nathantannar", password: "password", email: "nathantannar4@gmail.com")
        Network.request(.signUp(auth), decodeAs: User.self)
            .then { user in
                return Network.request(.login(auth), decodeAs: BearerToken.self)
            }.then { _ in
                return Network.request(.verifyLogin)
            }.then { _ in
                print("Done")
            }.catch { error in
                print(error)
        }
    }


}

