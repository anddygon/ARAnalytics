//
//  Dictionary+GoogleAnalytics.swift
//  Pods
//
//  Created by lee on 2017/3/20.
//
//

import Foundation


extension Dictionary {
    
    var category: Value? {
        set{
            if let v = newValue {
                updateValue(v, forKey: "category" as! Key)
            }else{
                removeValue(forKey: "category" as! Key)
            }
        }
        get{
            return self["category" as! Key]
        }
    }
    
    var label: Value? {
        set{
            if let v = newValue {
                updateValue(v, forKey: "label" as! Key)
            }else{
                removeValue(forKey: "label" as! Key)
            }
        }
        get{
            return self["label" as! Key]
        }
    }
    
    var value: Value? {
        set{
            if let v = newValue {
                updateValue(v, forKey: "value" as! Key)
            }else{
                removeValue(forKey: "value" as! Key)
            }
        }
        get{
            return self["value" as! Key]
        }
    }
    
    
}
