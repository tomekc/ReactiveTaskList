//
//  Flow.swift
//  ReactiveList
//
//  Created by Tomek on 28.12.2015.
//  Copyright © 2015 Tomek Cejner. All rights reserved.
//

import Foundation

protocol Reducer {
    typealias Model
    func reduce(object:Model) -> Model
}

class ImmutableModel<T> {

    init(initialState:T) {
        self.state = initialState
    }
    
    var state:T
    
}