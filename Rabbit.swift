//
//  Rabbit.swift
//  Rabbit is very primitive implementation fo Redux wrriten in Swift.
//
//  Created by Hiroyuki Nakamura on 2015/12/05.
//  Copyright © 2015 Hiroyuki Nakamura. All rights reserved.
//

import Foundation

//
// State
//
public protocol RBState {}


//
// Action
//
public protocol RBAction {}

public protocol RBAsyncAction: RBAction {
    func asyncAction(dispatch: (RBAction)->(), getState: () -> RBState)
}


//
// Store
//
public protocol RBStoreDelegate: AnyObject {
    func storeUpdate(action: RBAction)
}

public class RBStore<S: RBState> {
    public typealias Unsubscribe = () -> ()
    
    var debugLog = false
    var state: S
    var reducer: (S, action:RBAction) -> S
    var listeners: [RBStoreDelegate]
    let sem = dispatch_semaphore_create(1)

    public init(reducer: (S, action:RBAction) -> S, initState: S){
        self.state = initState
        self.reducer = reducer
        self.listeners = []
    }
    
    public func getState() -> S{
        return self.state
    }
    
    public func dispatch(action: RBAction){
        if let action = action as? RBAsyncAction {
            action.asyncAction(self.dispatch, getState: self.getState)
        }else{
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER)
            self.state = self.reducer(self.state, action: action)
            if (self.debugLog){ NSLog("\(action) -> \(self.state)") }
            for listener in self.listeners {
                listener.storeUpdate(action)
            }
            dispatch_semaphore_signal(sem)
        }
    }
    
    public func subscribe(listener: RBStoreDelegate) -> Unsubscribe{
        self.listeners.append(listener)
        return {
            self.unsubscribe(listener)
        }
    }
    
    public func unsubscribe(listener: RBStoreDelegate) {
        for (index, removeTarget) in self.listeners.enumerate() {
            if (removeTarget === listener) {
                self.listeners.removeAtIndex(index)
            }
        }
    }
}
