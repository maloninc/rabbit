//
//  State.swift
//  RabbitDemo
//
//  Created by Hiroyuki Nakamura on 2015/12/05.
//  Copyright © 2015 Hiroyuki Nakamura. All rights reserved.
//

import Foundation

//
// MARK: Todo
//
struct Todo {
    var id: Int
    var title: String
    var completed: Bool
    
    init(title: String){
        self.id = -1
        self.title = title
        self.completed = false
    }
}

extension Todo{
    init (json: JSON){
        self.id = json["id"].asInt!
        self.title = json["title"].asString!
        self.completed = json["completed"].asBool!
    }
}

//
// MARK: Filter
//
enum TodoFilter: String {
    case All          = "ALL"
    case Completed    = "COMPLETED"
    case NotCompleted = "NOT_COMPLETED"
}

//
// MARK: Loading status
//
enum LoadingType{
    case Loading
    case Completed
    case Error(msg:String)
    
    func errorMsg() -> String{
        switch self {
        case .Error(let msg):
            return msg
        default:
            return ""
        }
    }
}

func ==(a: LoadingType, b: LoadingType) -> Bool {
    switch (a, b) {
    case (.Error(msg: _), .Error(msg: _)):
        return true
    case (.Loading, .Loading):
        return true
    case (.Completed, .Completed):
        return true
    default:
        return false
    }
}

struct  LoadingState {
    var todos: LoadingType
    var filter: LoadingType
}


//
// MARK: App status
//
struct AppState: RBState {
    var todos: [Todo]
    var filter: TodoFilter
    var loading: LoadingState
    
    func filteredTodos() -> [Todo]{
        let todos = self.todos.filter({ (todo: Todo) -> Bool in
            if self.filter == .All {
                return true
            }else if filter == .Completed {
                return todo.completed
            }else if filter == .NotCompleted {
                return !todo.completed
            }
            return true
        })
        
        return todos
    }
}


