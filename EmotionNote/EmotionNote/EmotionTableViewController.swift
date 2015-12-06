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
        
        if let savedNotes = loadNotes() {
            notes += savedNotes
        } else {
            // Load the sample data.
            loadSampleNotes()
        }
    }
    
    func loadSampleNotes() {
        let photo1 = UIImage(named: "face1")!
        let note1 = Note(content: "What a wonderful day!", emotion: "How happy you are!", emotionPhoto: photo1, time: "15-12-03")!
        
        let photo2 = UIImage(named: "face2")!
        let note2 = Note(content: "I miss you so much.", emotion:"You look a little upset.",emotionPhoto: photo2, time: "15-12-02")!
        
        let photo3 = UIImage(named: "face3")!
        let note3 = Note(content: "Should we have another dream?",emotion: "Everything is going ok, right?", emotionPhoto: photo3, time: "15-11-30")!
        notes += [note1,note2,note3]
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
