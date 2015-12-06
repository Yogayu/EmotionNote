//
//  Note.swift
//  EmotionNote
//
//  Created by youxinyu on 15/12/3.
//  Copyright © 2015年 yogayu.github.io. All rights reserved.
//

import UIKit

class Note: NSObject, NSCoding {
    // MARK: Properties
    var content: String
    var emotion: String
    var emotionPhoto: UIImage?
    var time: String
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("notes")
    
    // MARK: Types
    struct PropertyKey {
        static let contentKey = "content"
        static let emotionKey = "emotion"
        static let emotionPhotoKey = "emotionPhoto"
        static let timeKey = "time"
    }
    
    // MARK: Initialization
    init?(content: String, emotion: String, emotionPhoto: UIImage?, time: String) {
        // Initialize stored properties.
        self.content = content
        self.emotion = emotion
        self.emotionPhoto = emotionPhoto
        self.time = time
        
        super.init()
        
        if content.isEmpty{
            return nil
        }
    }
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(content,
            forKey: PropertyKey.contentKey)
        aCoder.encodeObject(emotion,
            forKey: PropertyKey.emotionKey)
        aCoder.encodeObject(emotionPhoto,
            forKey: PropertyKey.emotionPhotoKey)
        aCoder.encodeObject(time,
            forKey: PropertyKey.timeKey)
    }
    required convenience init?(coder aDecoder: NSCoder) {
        let content = aDecoder.decodeObjectForKey(
            PropertyKey.contentKey) as! String
        let emotion = aDecoder.decodeObjectForKey(
            PropertyKey.emotionKey) as! String
        let emotionPhoto = aDecoder.decodeObjectForKey(
            PropertyKey.emotionPhotoKey) as? UIImage
        let time = aDecoder.decodeObjectForKey(
            PropertyKey.timeKey) as! String
        // Must call designated initializer.
        self.init(content: content, emotion: emotion, emotionPhoto: emotionPhoto, time: time)
    }
    
}