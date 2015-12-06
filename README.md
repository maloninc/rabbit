Rabbit
==========
Rabbit is very primitive implementation of [Redux] written in Swift. It has just an unidirectional structure, and doesn't include any view frameworks. 

[Redux]: http://redux.js.org/

Prerequisite
------------

Swift 2.0 or later. (I did not check if it works in Swift 1.x)


Install
-----

Just add [Rabbit.swift] to your project.

[Rabbit.swift]: https://github.com/maloninc/rabbit/blob/master/Rabbit.swift

Architecture
-----------

Although the architecture of Rabbit is based on [Redux], I implemented only few features for now. It has only `state`, `store`, `reducer`, `action` and `async action`. There are no `middleware`, `combineReducers` or such kind of utilities.


Usage
-----

You have to define `state`, `action` and `reducer`. After that, `RBStore` provided by Rabbit handles all event in your app and tells your app what is happening and what state is if you `subscribe` it.


### Define State

For example, creating a simple todo app, you might define as the followings.

`AppState` (name whatever you want) is the only state you should care about and has to conform to protocol `RBState`.

In this case the app have two kinds of state, one is todo list and the other is filtering condition such as showing all items or only showing completed items.

````swift
struct AppState: RBState {
    var todos: [Todo]
    var filter: TodoFilter

    ...
}

struct Todo {
    var id: Int
    var title: String
    var completed: Bool

    ...
}

enum TodoFilter: String {
    case All          = "ALL"
    case Completed    = "COMPLETED"
    case NotCompleted = "NOT_COMPLETED"
}
````

### Define Action

Actions have to conform to protocol `RBAction`. Unlike Redux, actions do not have `type` property because we can identify type of actions by types of Swift. Also there is no action creator because `struct` of Swift has default initializer and it works as action creator.

In this case, we have three actions, adding, toggling completion and setting filter.

````swift
struct AddTodo: RBAction {
    let title: String
}

struct ToggleTodo: RBAction {
    let id: Int
}

struct SetFilter: RBAction {
    let filter: TodoFilter
}
````

### Define Reducer

Reducers have to be pure functions which shape as `(state, action) -> state` and should never perform any side effects like calling API.
Each reducers focus on specific state and reduce it according as an action.

Thanks to value type feature of Swift, these reducers won't perform any side effect such as mutating Array of `todos` in the argument.

````swift
func filter(filter: TodoFilter, action: RBAction) -> TodoFilter {
    switch action {
    case let action as SetFilter:
        return action.filter
        
    default:
        break
    }
    return filter
}

func todos(var todos: [Todo], action: RBAction) -> [Todo] {
    switch action {
    case let action as AddTodo:
        todos.append(Todo(title: action.title))
        
    case let action as ToggleTodo:
        todos[action.id].completed = !todos[action.id].completed
        
    default:
        break
    }
    return todos
}

func todoApp(state: AppState, action: RBAction) -> AppState {
    let appState = state
    return AppState(
        todos:  todos(appState.todos, action: action),
        filter: filter(appState.filter, action: action)
    )
}

````

### Subscribe Store
In your app, you should create `RBStore` instance with your app `state`. Also you should subscribe it so that you can update view when actions change the state. You can access current state by calling `getState()` method in `RBStore`.

````swift
let state = AppState(todos: [], filter: .All))
store = RBStore<AppState>(reducer: todoApp, initState: state)

store.subscribe({action in
    let currentState = store.getState()
    //update view
})

````

### Async Action
In this example, there is no server access. However in real world you might want to save todo data on a server. In that case you might need async actions.
As explained in original [Redux] website, the basic idea of async actions is creating a thunk instead of creating action `struct`. In Rabbit you can create async actions by conforming to `RBAsyncAction`. It has to have a function named as `ascynAction` which takes two arguments of `dispatch` and `getState`. You can use these two functions so that an async action calls REST APIs and dispatches "sync action" such as `FetchReceivedTodo` or `FetchErrorTodo`.

As you can see the following example, you can call `dispatch` method with async action same as normal action.

````swift
struct FetchTodoAsync: RBAsyncAction{
    func asyncAction(dispatch: (RBAction) -> (), getState: () -> RBState){
        dispatch(FetchRequestTodo())
        requestAPI(url,
            success: { json in
                dispatch(FetchReceivedTodo(json))
            },
            error: { statusCode in
                dispatch(FetchErrorTodo(statusCode));
            }
        })
    }
}

store.dispatch(FetchTodoAsync())
````