//
//  SelectableSegment.swift
//  SegmentedCollection
//
//  Created by Trabajo on 24/09/21.
//

import Foundation

struct SelectableSegment:Hashable{
    let title:String
    let id:UUID = UUID()
    let locked:Bool
    
    internal init(title: String, locked:Bool = false) {
        self.title = title
        self.locked = locked
    }
}
