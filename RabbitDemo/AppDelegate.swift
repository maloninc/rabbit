//
//  AppDelegate.swift
//  RabbitDemo
//
//  Created by Hiroyuki Nakamura on 2015/12/05.
//  Copyright © 2015 Hiroyuki Nakamura. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var store: RBStore<AppState>

    override init(){
        let state = AppState(todos: [], filter: .All, loading: LoadingState(todos: .Completed, filter: .Completed))
        store = RBStore<AppState>(reducer:todoApp, initState: state)
        store.debugLog = true
    }
}

