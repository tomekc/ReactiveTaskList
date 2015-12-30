//
//  Commands.swift
//  ReactiveList
//
//  Created by Tomek on 28.12.2015.
//  Copyright © 2015 Tomek Cejner. All rights reserved.
//

import Foundation

class MarkAsDoneCommand: TaskMutatingCommand, CustomStringConvertible {
    
    let itemTitle:String
    
    init(_title:String) {
        self.itemTitle = _title
    }
    
    func handle(input: TaskListModel) -> TaskListModel {
        var ret = input
        var item = ret.tasks.filter ({ $0.title == itemTitle }).first
        item?.state = .Done
        
        let modifiedTasks = ret.tasks.map { (ti:TaskItem) -> TaskItem in
            var i = ti
            if ti.title == itemTitle {
                i.state = .Done
            }
            return i
        }
        ret.tasks = modifiedTasks
        return ret
    }
    
    var description:String {
        get {
            return "MarkAsDone[\(self.itemTitle)]"
        }
    }
    
}
