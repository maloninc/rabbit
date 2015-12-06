//
//  ViewController.swift
//  RabbitDemo
//
//  Created by Hiroyuki Nakamura on 2015/12/05.
//  Copyright © 2015 Hiroyuki Nakamura. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, RBStoreDelegate{
    @IBOutlet weak var todoTable: UITableView!
    @IBOutlet weak var todoEntry: UITextField!
    @IBOutlet weak var todoFilter: UISegmentedControl!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        // MARK: Subscribe store
        //
        _ = appDelegate.store.subscribe(self)
        
        
        //
        // MARK: Load initial data from server
        //
        appDelegate.store.dispatch(FetchTodoAsync())
        appDelegate.store.dispatch(FetchFilterAsync())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //
    // MARK: UI Action Handler
    //
    @IBAction func tapAddButton(sender: UIButton) {
        addTodo()
        todoEntry.endEditing(true)
    }
    
    func textFieldShouldReturn(textField:UITextField) -> Bool{
        addTodo()
        self.view.endEditing(true)
        return false
    }
    
    func addTodo(){
        if todoEntry.text != "" {
            appDelegate.store.dispatch(AddTodoAsync(title: todoEntry.text!))
            todoEntry.text = ""
        }
    }
    
    @IBAction func switchFilter(sender: UISegmentedControl) {
        switch(sender.selectedSegmentIndex){
        case 0:
            appDelegate.store.dispatch(SetFilter(filter: .All))
        case 1:
            appDelegate.store.dispatch(SetFilter(filter: .NotCompleted))
        case 2:
            appDelegate.store.dispatch(SetFilter(filter: .Completed))
        default:
            break
        }
    }
    
    

    //
    // MARK: TableView delegate
    //
    func tableView(tableView: UITableView,cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let state = appDelegate.store.getState()
        let todos = state.filteredTodos()
        let todo = todos[indexPath.row]

        var cell: UITableViewCell
        let cellId = "Cell"
        if let c = tableView.dequeueReusableCellWithIdentifier(cellId) {
            cell = c
        }else{
            cell = UITableViewCell.init(style: .Default, reuseIdentifier: cellId)
        }
        
        if todo.completed && state.filter == .All {
            // Completed task is written with strike line.
            cell.textLabel?.attributedText = NSAttributedString(
                string: todo.title,
                attributes:[NSStrikethroughStyleAttributeName:NSUnderlineStyle.StyleSingle.rawValue])
        }else{
            cell.textLabel?.attributedText = NSAttributedString(
                string: todo.title,
                attributes:nil)
        }

        return cell
    }

    func tableView(tableView: UITableView,numberOfRowsInSection section: Int) -> Int{
        let state = appDelegate.store.getState()
        return state.filteredTodos().count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        appDelegate.store.dispatch(ToggleTodoAsync(index:indexPath.row))
    }
    
    
    //
    // MARK: Event Listener conforming to RBStoreDelegate
    //
    func storeUpdate(action: RBAction) {
        let state = self.appDelegate.store.getState()
        
        // Show loading icon
        if (state.loading.todos == LoadingType.Loading || state.loading.filter == LoadingType.Loading) {
            self.activityIndicator.center = self.view.center
            self.view.addSubview(self.activityIndicator)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.activityIndicator.startAnimating()
            })
        }
        // Hide Loading Icon and redraw view
        else if (state.loading.todos == .Completed && state.loading.filter == .Completed) {
            dispatch_async(dispatch_get_main_queue(), {
                self.activityIndicator.stopAnimating()
                self.todoTable.reloadData()
                
                switch(state.filter){
                case .All:
                    self.todoFilter.selectedSegmentIndex = 0
                case .NotCompleted:
                    self.todoFilter.selectedSegmentIndex = 1
                case .Completed:
                    self.todoFilter.selectedSegmentIndex = 2
                }
            })
        }
        // Network error
        else if (state.loading.todos == .Error(msg:"") || state.loading.filter == .Error(msg:"")) {
            let msg = "Todos: \(state.loading.todos.errorMsg())\nFilter: \(state.loading.filter.errorMsg())"
            let alert = UIAlertController(title: "Network Error", message: msg, preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(defaultAction)
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(alert, animated: true, completion: nil)
            })
        }

    }
}

