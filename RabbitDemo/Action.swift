//
//  Action.swift
//  RabbitDemo
//
//  Created by Hiroyuki Nakamura on 2015/12/05.
//  Copyright © 2015 Hiroyuki Nakamura. All rights reserved.
//

import Foundation

let baseURL = "https://rabbit-todo.herokuapp.com"

//
// MARK: Todo
//
struct AddTodo: RBAction {
    let title: String
}

struct ToggleTodo: RBAction {
    let index: Int
}


struct FetchRequestTodo: RBAction {}

struct FetchReceivedTodo: RBAction {
    let json: String
}

struct FetchErrorTodo: RBAction {
    let msg: String
}

struct FetchTodoAsync: RBAsyncAction{
    func asyncAction(dispatch: (RBAction) -> (), getState: () -> RBState){
        dispatch(FetchRequestTodo())
        requestWithURL("\(baseURL)/todos", method: "GET", data: nil, completionHandler: {
            data, res, err in
            let statusCode: Int? = ((res as? NSHTTPURLResponse)?.statusCode)
            
            if(res == nil || statusCode != 200){
                dispatch(FetchErrorTodo(msg: "Loading todo. status=\(statusCode)"));
            }else{
                let json = NSString(data: data!, encoding:NSUTF8StringEncoding)
                dispatch(FetchReceivedTodo(json: json as! String))
            }
        })
    }
}

struct AddTodoAsync: RBAsyncAction {
    var title: String
    
    func asyncAction(dispatch: (RBAction) -> (), getState: () -> RBState){
        let data = JSON(["title": title]).toString().dataUsingEncoding(NSUTF8StringEncoding)
        dispatch(FetchRequestTodo())
        
        requestWithURL("\(baseURL)/todos", method: "POST", data: data, completionHandler: {
            data, res, err in
            let statusCode: Int? = ((res as? NSHTTPURLResponse)?.statusCode)
            
            if(res == nil || statusCode != 200){
                dispatch(PostErrorTodo(msg: "Posting todo. status=\(statusCode)"));
            }else{
                dispatch(AddTodo(title: self.title))
            }
        })

    }
}

struct ToggleTodoAsync: RBAsyncAction {
    var index: Int
    
    func asyncAction(dispatch: (RBAction) -> (), getState: () -> RBState){
        let state = getState() as! AppState
        let todo = state.todos[index]
        let data = JSON(["completed":!todo.completed]).toString().dataUsingEncoding(NSUTF8StringEncoding)

        dispatch(FetchRequestTodo())
        requestWithURL("\(baseURL)/todos/\(todo.id)", method: "PUT", data: data, completionHandler: {
            data, res, err in
            let statusCode: Int? = ((res as? NSHTTPURLResponse)?.statusCode)
            
            if(res == nil || statusCode != 200){
                dispatch(PostErrorTodo(msg: "Toggling todo. status=\(statusCode)"));
            }else{
                dispatch(ToggleTodo(index: self.index))
            }
        })
    }
}
struct PostErrorTodo: RBAction {
    let msg: String
}


//
// MARK: Filter
//
struct SetFilter: RBAction {
    let filter: TodoFilter
}

struct FetchRequestFilter: RBAction {}

struct FetchReceivedFilter: RBAction {
    let json: String
}

struct FetchErrorFilter: RBAction {
    let msg: String
}

struct FetchFilterAsync: RBAsyncAction {
    func asyncAction(dispatch: (RBAction) -> (), getState: () -> RBState){
        dispatch(FetchRequestFilter())
        requestWithURL("\(baseURL)/appsettings", method: "GET", data: nil, completionHandler: {
            data, res, err in
            let statusCode: Int? = ((res as? NSHTTPURLResponse)?.statusCode)
            
            if(res == nil || statusCode != 200){
                dispatch(FetchErrorFilter(msg: "Loading app settings. status=\(statusCode)"));
            }else{
            let json = NSString(data: data!, encoding:NSUTF8StringEncoding)
                dispatch(FetchReceivedFilter(json: json as! String))
            }
        })
    }
}


//
// MARK: HTTP Access
//
func requestWithURL(url: String, method: String, data: NSData?, completionHandler: ((data: NSData?, res: NSURLResponse?, err: NSError?) -> Void)?){
    let dataURL = NSURL(string: url)
    let dataReq = NSMutableURLRequest(URL: dataURL!)
    let config = NSURLSessionConfiguration.defaultSessionConfiguration()
    let session = NSURLSession(configuration: config)
    dataReq.HTTPMethod = method
    dataReq.HTTPBody = data
    
    let task: NSURLSessionDataTask
    if let handler = completionHandler {
        task = session.dataTaskWithRequest(dataReq, completionHandler: handler)
    }else {
        task = session.dataTaskWithRequest(dataReq)
    }
    
    task.resume()
}

