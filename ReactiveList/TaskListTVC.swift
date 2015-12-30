//
//  TaskListTVC.swift
//  ReactiveList
//
//  Created by Tomek Cejner on 26/12/15.
//  Copyright © 2015 Tomek Cejner. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class TaskListTVC: UITableViewController {

    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String,TaskItem>>()
    let disposeBag = DisposeBag()
    
    var changes = Variable([TaskMutatingCommand]())
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.dataSource = nil
        self.tableView.delegate = nil
        
        dataSource.cellFactory = {
            (tv, ip, item:TaskItem) in
            let cell:UITableViewCell = tv.dequeueReusableCellWithIdentifier(R.reuseIdentifier.taskListCell, forIndexPath:ip)!
            cell.textLabel?.text = item.title
            cell.detailTextLabel?.text = "\(item.estimate) hrs"

            return cell
        }

        let pendingItemsOnly = { (item:TaskItem) -> Bool in item.state == .Pending }
        let doneItemsOnly = { (item:TaskItem) -> Bool in item.state == .Done }
        
        
        combineLatest(getDataSignal(), changes) { (src:TaskListModel, cmds:[TaskMutatingCommand]) -> TaskListModel in
            
            var ret:TaskListModel = src
            for c in cmds {
                ret = c.handle(ret)
            }
            
            return ret
        }.map {
            [
                SectionModel(model: "Pending", items: $0.tasks.filter(pendingItemsOnly) ),
                SectionModel(model: "Completed", items: $0.tasks.filter(doneItemsOnly) )
            ]
        }.bindTo(self.tableView.rx_itemsWithDataSource(dataSource))
        .addDisposableTo(disposeBag)
        
        self.tableView.rx_itemSelected.subscribeNext { (ip:NSIndexPath) -> Void in
            print("Selected item \(ip)")
            let cell = self.tableView.cellForRowAtIndexPath(ip)
            self.markAsDone(cell?.textLabel?.text ?? "")
        }.addDisposableTo(disposeBag)
       
        
        changes.subscribeNext { (commands:[TaskMutatingCommand]) -> Void in
            print("Commands changed: \(commands)")
        }.addDisposableTo(disposeBag)
    }
    
    func markAsDone(title:String) {
        var changeList:[TaskMutatingCommand] = changes.value
        changeList.append(MarkAsDoneCommand(_title: title))
        changes.value = changeList
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.taskListCell, forIndexPath: indexPath)!
        
        cell.textLabel?.text = "Foo"
        cell.detailTextLabel?.text = "1 hr"
        
        // Configure the cell...

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Pending"
        case 1: return "Done"
        default: return "?"
        }
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    
    // MARK: - Reactive extensions
    func getDataSignal() -> Observable<TaskListModel> {
        return RxSwift.create {
            observer in

            let tasks:[TaskItem] = [
                TaskItem(title:"Wash car", state: .Pending, estimate: 2),
                TaskItem(title:"Clean windows", state: .Pending, estimate: 4),
                TaskItem(title:"Replace bulbs", state: .Done, estimate: 1)
                
            ]
            let mockModel = TaskListModel(tasks:tasks)
            
            observer.onNext(mockModel)
            
            return AnonymousDisposable() {}
        }
    }
    
}
