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

/*
func mergeSort(array: [Double]) -> [Double] {
    guard array.count > 1 else { return array }    // 1
    
    let middleIndex = array.count / 2              // 2
    
    let leftArray = mergeSort(Array(array[0..<middleIndex]))             // 3
    
    let rightArray = mergeSort(Array(array[middleIndex..<array.count]))  // 4
    
    return merge(leftPile: leftArray, rightPile: rightArray)             // 5
}

func merge(leftPile leftPile: [Double], rightPile: [Double]) -> [Double] {
    // 1
    var leftIndex = 0
    var rightIndex = 0
    
    // 2
    var orderedPile = [Double]()
    
    // 3
    while leftIndex < leftPile.count && rightIndex < rightPile.count {
        if leftPile[leftIndex] < rightPile[rightIndex] {
            orderedPile.append(leftPile[leftIndex])
            leftIndex += 1
        } else if leftPile[leftIndex] > rightPile[rightIndex] {
            orderedPile.append(rightPile[rightIndex])
            rightIndex += 1
        } else {
            orderedPile.append(leftPile[leftIndex])
            leftIndex += 1
            orderedPile.append(rightPile[rightIndex])
            rightIndex += 1
        }
    }
    
    // 4
    while leftIndex < leftPile.count {
        orderedPile.append(leftPile[leftIndex])
        leftIndex += 1
    }
    
    while rightIndex < rightPile.count {
        orderedPile.append(rightPile[rightIndex])
        rightIndex += 1
    }
    
    return orderedPile
}
 */