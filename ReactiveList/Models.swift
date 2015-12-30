//
//  ViewModels.swift
//  ReactiveList
//
//  Created by Tomek Cejner on 26/12/15.
//  Copyright © 2015 Tomek Cejner. All rights reserved.
//

import Foundation

public enum TaskState {
    case Pending
    case Done
}

public struct TaskItem {
    var title:String
    var state:TaskState
    var estimate:Int
}

public struct TaskListModel {
    var tasks:[TaskItem]    
}

protocol TaskMutatingCommand {
    func handle(input:TaskListModel) -> TaskListModel
}

