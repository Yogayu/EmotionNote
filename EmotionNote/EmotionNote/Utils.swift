//
//  Utils.swift
//  EmotionNote
//
//  Created by youxinyu on 16/4/16.
//  Copyright © 2016年 yogayu.github.io. All rights reserved.
//

import Foundation

// TODO: Get Random number
func randomIn(min min: Int, max: Int) -> Int{
    return Int(arc4random()) % (max - min + 1) + min
}
// TODO: Sort emotion. Well, just bubble sort
func bubbolSort(var array: [Double]) -> [Double] {
    for var i = array.count-1;i>1; i--
    {
        for var j = 0;j < i;j++
        {
            if array[j] > array[j + 1]
            {
                let temp = array[j]
                array[j] = array[j+1]
                array[j+1] = temp
            }
        }
    }
    return array
}
