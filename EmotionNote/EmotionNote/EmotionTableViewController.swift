//
//  EmotionTableViewController.swift
//  EmotionNote
//
//  Created by youxinyu on 15/12/1.
//  Copyright © 2015年 yogayu.github.io. All rights reserved.
//

import UIKit

class EmotionTableViewController: UITableViewController {
    
    var notes = [Note]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = editButtonItem()
        
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableViewAutomaticDimension
        
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        
        navigationController?.navigationBar.titleTextAttributes = ([NSForegroundColorAttributeName : UIColor.whiteColor()])
        
        
        preferredStatusBarStyle()
        
        if let savedNotes = loadNotes() {
            notes += savedNotes
        } else {
            loadSampleNotes()
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func loadSampleNotes() {
       
        let photo3 = UIImage(named: "face3")!
        let note3 = Note(content: "Where's is my mom? I couldn't find her anywhere. Why life is so annoying? Oh...",emotion: "It seems that you are angry.\nAnd you feel a little neutral.", emotionPhoto: photo3, time: "15-12-05")!
        
        let photo4 = UIImage(named: "face4")!
        let note4 = Note(content: "Love me? Change me then we can be together forever.", emotion: "I know you are in a happy mood.\nAnd you feel a bit of netural.", emotionPhoto: photo4, time: "15-12-05")!
        
        let photo5 = UIImage(named: "face5")!
        let note5 = Note(content: "What are you doing here? I am going to sleep. This my sweet dream.", emotion: "Do you enjoy your surprise emotion?\nAnd you feel a little fear.", emotionPhoto: photo5, time: "15-12-04")!
        
        let photo6 = UIImage(named: "face6")!
        let note6 = Note(content: "Why? Why? Tell me why? Am I not so good? Am I saying too much? I don't want to break with you. I can't image the life without you.", emotion:"How sad you are now!\nAnd it mix with some neutral emotion.",emotionPhoto: photo6, time: "15-12-02")!
        
        let photo7 = UIImage(named: "face7")!
        let note7 = Note(content: "Life is full of adventures. Find your dream and achieve it.",emotion: "You must feel very happy.\nAnd you may also somehow in a digust mood.", emotionPhoto: photo7, time: "15-12-04")!
        
        let photo8 = UIImage(named: "face8")!
        let note8 = Note(content: "Power is everything.", emotion: "I know you are in a neutral mood.\nAnd you feel a little sad.", emotionPhoto: photo8, time: "15-12-03")!
        
        let photo2 = UIImage(named: "face9")!
        let note2 = Note(content: "My dragon，why you take me there? I am the queen. I belong to somewehere else.", emotion:"I know you are in a neutral mood.\nAnd you feel a little sad. Drasgon's mother~",emotionPhoto: photo2, time: "15-12-02")!
        
        let photo1 = UIImage(named: "face10")!
        let note1 = Note(content: "See you at the star~",emotion: "You must feel very happy.\n", emotionPhoto: photo1, time: "15-12-01")!
        
        notes += [note3,note4,note5,note6,note7,note8,note1,note2]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "EmotionTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! EmotionTableViewCell
        // Fetches the appropriate meal for the data source layout.
        let note =  notes[indexPath.row]
        cell.contentLabel.text = note.content
        cell.emotionView.image = note.emotionPhoto
        cell.timeLabel.text = note.time
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            notes.removeAtIndex(indexPath.row)
            saveNotes()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // MARK: Unwind
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? EmotionViewController, note = sourceViewController.note {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing note
                notes[selectedIndexPath.row] = note
                tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
            } else {
                // Add a new note
                let newIndexPath = NSIndexPath(forRow: notes.count, inSection: 0)
                notes.append(note)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
            }
            // Save the note
            saveNotes()
        }
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let noteDetailViewController = segue.destinationViewController as! EmotionViewController
            
            // Get the cell that generated this segue.
            if let selectedNoteCell = sender as? EmotionTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedNoteCell)!
                let selectedNote = notes[indexPath.row]
                noteDetailViewController.note = selectedNote
            }
        }
        else if segue.identifier == "AddItem" {
            print("Adding new note.")
        }
    }
    
    // MARK: NSCoding
    func saveNotes() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(notes, toFile: Note.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save notes...")
        }
    }
    
    func loadNotes() -> [Note]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Note.ArchiveURL.path!) as? [Note]
    }
}
