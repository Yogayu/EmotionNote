//
//  DataManager.swift
//  HiHair
//
//  Created by youxinyu on 15/11/23.
//  Copyright © 2015年 yogayu.github.io. All rights reserved.
//

import Foundation

class DataManager {
    
    class func getFaceDataFromFileWithSuccess(success: ((data: NSData) -> Void)) {
        //1
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            //2
            let filePath = NSBundle.mainBundle().pathForResource("Face",ofType:"json")
            do {
                let data = try NSData(contentsOfFile:filePath!,
                    options: NSDataReadingOptions.DataReadingUncached)
                success(data: data)
                print("sucess to load file!")
            } catch let error as NSError {
                var readError:NSError?
                readError = error
                print(readError)
            } catch {
                fatalError()
            }
        })
    }
}