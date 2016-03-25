//
//  Quick.swift
//  LocationPrivacy
//
//  Created by sgript on 25/03/2016.
//  Copyright © 2016 Shazaib Ahmad. All rights reserved.
//

import Foundation

public class Quick {
    func partition(inout dataList: [Double], low: Int, high: Int) -> Int { // https://gist.github.com/fjcaetano/b0c00a889dc2a17efad9#gistcomment-1338271
        var pivotPos = low
        let pivot = dataList[low]
        
        for var i = low + 1; i <= high; i++ {
            if dataList[i] < pivot && ++pivotPos != i {
                (dataList[pivotPos], dataList[i]) = (dataList[i], dataList[pivotPos])
            }
        }
        (dataList[low], dataList[pivotPos]) = (dataList[pivotPos], dataList[low])
        return pivotPos
    }
    
    func quickSort(inout dataList: [Double], left: Int, right: Int) {
        if left < right {
            let pivotPos = partition(&dataList, low: left, high: right)
            quickSort(&dataList, left: left, right: pivotPos - 1)
            quickSort(&dataList, left: pivotPos + 1, right: right)
        }
    }
}