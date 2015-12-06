//
//  Reducer.swift
//  RabbitDemo
//
//  Created by Hiroyuki Nakamura on 2015/12/05.
//  Copyright © 2015 Hiroyuki Nakamura. All rights reserved.
//

import Foundation

//
// MARK: Todo
//
func todos(var todos: [Todo], action: RBAction) -> [Todo] {
    switch action {
    case let action as AddTodo:
        todos.append(Todo(title: action.title))
        
    case let action as ToggleTodo:
        todos[action.index].completed = !todos[action.index].completed
        
    case let action as FetchReceivedTodo:
        let dic = JSON(string: action.json)
        var result = [Todo]()
        for (_, val) in dic{
            result.append(Todo(json: val))
        }
        return result
        
    default:
        break
    }
    return todos
}


//
// MARK: Filter
//
func filter(filter: TodoFilter, action: RBAction) -> TodoFilter {
    switch action {
    case let action as SetFilter:
        return action.filter
        
    case let action as FetchReceivedFilter:
        let dic = JSON(string: action.json)
        for (_, val) in dic{
            if val["name"].asString! == "filter" {
                return TodoFilter(rawValue: val["value"].asString!)!
            }
        }

    default:
        break
    }
    return filter
}

//
// MARK: Loading status
//
func loading(var state: LoadingState, action: RBAction) -> LoadingState{
    switch action {
    case _ as FetchRequestTodo:
        state.todos = .Loading
        
    case _ as FetchReceivedTodo, _ as AddTodo, _ as ToggleTodo:
        state.todos = .Completed
        
    case let action as FetchErrorTodo:
        state.todos = .Error(msg: action.msg)
        
    case _ as FetchRequestFilter:
        state.filter = .Loading
        
    case _ as FetchReceivedFilter:
        state.filter = .Completed
     
    case let action as FetchErrorFilter:
        state.filter = .Error(msg: action.msg)

    case let action as PostErrorTodo:
        state.todos = .Error(msg: action.msg)

    default:
        break
    }
    return state
}



//
// MARK: App status
//
func todoApp(state: AppState, action: RBAction) -> AppState {
    let appState = state
    return AppState(
        todos:  todos(appState.todos, action: action),
        filter: filter(appState.filter, action: action),
        loading: loading(appState.loading, action: action)
    )
}
