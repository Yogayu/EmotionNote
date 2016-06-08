//
//  ViewController.swift
//  EmotionNote
//
//  Created by youxinyu on 15/12/1.
//  Copyright © 2015年 yogayu.github.io. All rights reserved.
//

import UIKit
import Alamofire
import MobileCoreServices

class EmotionViewController: UIViewController,UITextViewDelegate,UITextFieldDelegate,
    UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    var note: Note?
    var emotion:JSON?
    var time:String = ""
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emotionView: UIImageView!
    @IBOutlet weak var contentTextField: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var howDoUTextField: UITextField!
    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var selectImgView: UIView!
    @IBOutlet weak var textStackView: UIStackView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var finishView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contentTextField.delegate = self
        
        if let note = note {
            navigationItem.title = "My emotion"
            contentTextField.text   = note.content
            resultTextView.text = note.emotion
            emotionView.image = note.emotionPhoto
            time = note.time
            /*debug
            if let noteimage:UIImage = note.emotionPhoto {
                ENService.loadImgInfo(noteimage) { (JSON) -> () in
                    self.configureWithEmotion(JSON)}
            }
            */
        }
        setupUI()
        resultTextviewStyle()
        hideHowDoYouFeelIfNeeded()
        checkEmptyNoteContent()
    }
    
    func setupUI() {
        finishView.hidden = true
    }
    
    func resultTextviewStyle(){
        resultTextView.font = UIFont(name: "Avenir Next", size: 18)
        resultTextView.textColor = UIColor.whiteColor()
        resultTextView.textAlignment = NSTextAlignment.Center
    }
    
    // MARK: Make the content show
    override func viewWillAppear(animated: Bool)  {
        super.viewWillAppear(animated)
        
    }
    override func viewWillDisappear(animated: Bool)  {
        super.viewWillDisappear(animated)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func BgButttondidTouched(sender: AnyObject) {
        contentTextField.resignFirstResponder()
        finishView.hidden = true
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    // MARK: select Image
    @IBAction func selectImage(sender: UITapGestureRecognizer){
        // Hide the keyboard.
        contentTextField.resignFirstResponder()
        let imagePickerController = UIImagePickerController()
       
        // Show alert
        let chooseAWay:UIAlertController = UIAlertController(title: "Choose a way", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        // 1.Choose from photo library
        let photoLib = UIAlertAction(title: "Choose from photo library", style: UIAlertActionStyle.Default){
            (action: UIAlertAction!) -> Void in
            
            imagePickerController.sourceType = .PhotoLibrary
            imagePickerController.delegate = self
            self.presentViewController(imagePickerController, animated: true, completion: nil)
        }
        // 2.Take a picture
        let takePhoto = UIAlertAction(title: "Take a picture", style: UIAlertActionStyle.Default){
            (action: UIAlertAction!) -> Void in
            
            if self.isCameraAvailable() && self.doesCameraSupportTakingPhotos(){
                imagePickerController.sourceType = .Camera
                imagePickerController.allowsEditing = false
                imagePickerController.mediaTypes = [kUTTypeImage as NSString as String]
                imagePickerController.delegate = self
                self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
                self.presentViewController(imagePickerController, animated: true, completion: nil)
            }else{
                print("Camera is not available")
                let CameraIsnotAva = UIAlertController(title: "Check your camera", message: "Camera is not available", preferredStyle: UIAlertControllerStyle.Alert)
             
                self.presentViewController(CameraIsnotAva, animated: true, completion: nil)
                
            }
        }
        // 3. Cancel
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive, handler: nil)
        
        chooseAWay.addAction(takePhoto)
        chooseAWay.addAction(photoLib)
        chooseAWay.addAction(cancel)
        
        self.presentViewController(chooseAWay, animated: true, completion: nil)
    }
    // MARK: Cancel
    @IBAction func cancel(sender: UIBarButtonItem) {
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMealMode {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    // MARK: Save note
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            
            let content = contentTextField.text ?? ""
            let photo = emotionView.image
            let emotion = resultTextView.text ?? ""
            if time == ""{
                let now = NSDate()
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yy-MM-dd"
                time = dateFormatter.stringFromDate(now)
            }
            note = Note(content: content, emotion: emotion, emotionPhoto: photo, time: time)
        }
    }
    
    // MARK:
    func textViewDidBeginEditing(textView: UITextView) {
        // TODO: Hide the placeHolder
        checkEmptyNoteContent()
        howDoUTextField.hidden = true
        finishView.hidden = false
        scrollView.setContentOffset(CGPoint(x: 0, y: 240), animated: true)
    }
    
    func textViewDidChange(textView: UITextView) {
        checkEmptyNoteContent()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        howDoUTextField.hidden = true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("touched")
        contentTextField.resignFirstResponder()
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        emotionView.image = selectedImage
        resultTextView.text = "I am tring to feel your emotion, please wait~ "
        
        resultTextviewStyle()
        
        ENService.loadImgInfo(emotionView.image!) { (JSON) -> () in
            self.configureWithEmotion(JSON)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: Check camera
    func isCameraAvailable() -> Bool{
        return UIImagePickerController.isSourceTypeAvailable(.Camera)
    }
    
    func cameraSupportsMedia(mediaType: String,
            sourceType: UIImagePickerControllerSourceType) -> Bool{
            let availableMediaTypes = UIImagePickerController.availableMediaTypesForSourceType(sourceType)!
            as [String]
            for type in availableMediaTypes{ if type == mediaType{
            return true }
            }
            return false }
    func doesCameraSupportShootingVideos() -> Bool{
            return cameraSupportsMedia(kUTTypeMovie as NSString as String, sourceType: .Camera)
    }
    
    func doesCameraSupportTakingPhotos() -> Bool{
            return cameraSupportsMedia(kUTTypeImage as NSString as String, sourceType: .Camera)
    }
    
    func checkEmptyNoteContent(){
        // Disable the Save button if the text field is empty.
        let text = contentTextField.text ?? ""
        saveButton.enabled = !text.isEmpty
    }
    func hideHowDoYouFeelIfNeeded() {
        if (self.contentTextField.text.utf16.count > 0) {
            self.howDoUTextField.hidden = true
        }
        else {
            self.howDoUTextField.hidden = false
        }
    }
    
    // MARK:Face Emotion
    func configureWithEmotion(json: JSON) {
        let jsonNum = json.count
        
        let noFace:UIAlertController = UIAlertController(title: "WOW", message: "I can't see you clearly, Could you show me another face?", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        noFace.addAction(okAction)
        
        // Chenk if there has any face
        if jsonNum > 0 {
            if let hasFace = json[0]["faceRectangle"]["top"].number{
                /* debug
                let faceRectangleTop = Double(json[0]["faceRectangle"]["top"].number!)
                let faceRectangleLeft = Double(json[0]["faceRectangle"]["left"].number!)
                let faceRectangleWidth = Double(json[0]["faceRectangle"]["width"].number!)
                let faceRectangleHeight = Double(json[0]["faceRectangle"]["height"].number!)
                */
                let angry = Double(json[0]["scores"]["anger"].number!)
                let contempt = Double(json[0]["scores"]["contempt"].number!)
                let disgust = Double(json[0]["scores"]["disgust"].number!)
                let fear = Double(json[0]["scores"]["fear"].number!)
                let happiness = Double(json[0]["scores"]["happiness"].number!)
                let neutral = Double(json[0]["scores"]["neutral"].number!)
                let sadness = Double(json[0]["scores"]["sadness"].number!)
                let surprise = Double(json[0]["scores"]["surprise"].number!)
    
                var result = ""
                var origArray:[String] = ["angry","contempt","disgust",
                    "fear","happy","neutral","sad","surprise"]
                let origArrayCopy = origArray
                
                var sortArray:[Double] = [angry,contempt,disgust,fear,happiness,neutral,sadness,surprise]
                
                for var i = 0; i<sortArray.count; i++ {
                    origArray[i] = "\(sortArray[i])"
                }
                
                sortArray = bubbolSort(sortArray)
                // Change the emotion num to name
                for var i = sortArray.count-1;i>=0; i-- {
                    for var j = origArray.count-1;j>=0;j-- {
                        if(String(sortArray[i]) == origArray[j])
                        {
                            if i == 7
                            {
                                result += showFirEmotion("\(origArrayCopy[j])")
                            }else if i == 6
                            {
                                result += showSedEmotion("\(origArrayCopy[j])")
                            }
                        }
                    } // end j
                } // end i
                
                // TODO: Add the result to the content
                resultTextView.text = result
                resultTextviewStyle()
                print("Have faces, The top faceRectangle is \(hasFace)")
            }else
                {
                print("Image size is invalid")
                self.presentViewController(noFace, animated: true, completion: nil)
                resultTextView.text = "Send me a photo.\nI will tell you your emotion~ "
                resultTextviewStyle()
                }
        }else
        {
            print("No face finding in the picture")
            self.presentViewController(noFace, animated: true, completion: nil)
            resultTextView.text = "Send me a photo.\nI will tell you your emotion~ "
            resultTextviewStyle()
        }
        
    }
 
    // MARK:Show the emotion
    func showFirEmotion(let emo:String)->String{
        var sentences:String = ""
        let number = randomIn(min: 1, max: 5)
        switch number {
        case 1:
            print("number 1")
            sentences = "Your most strongest emotion is " + emo + "."
        case 2:
            print("number 2")
            sentences = "You must feel very " + emo + "."
        case 3:
            print("number 3")
            sentences = "I know you are in a " + emo + " mood."
        case 4:
            print("number 4")
            sentences = "How " + emo + " you are now!"
        case 5:
            print("number 5")
            sentences = "Do you enojy your " + emo + " emotion?"
        default:
            print("Wow, you caught me.")
        }
        return sentences
    }
    
    func showSedEmotion(let emo:String)->String{
        var sentences:String = ""
        let number = randomIn(min: 1, max: 5)
        switch number {
        case 1:
            print("number 1")
            sentences = "\nAnd you feel a little " + emo + "."
        case 2:
            print("number 2")
            sentences = "\nAnd you feel a bit of " + emo + "."
        case 3:
            print("number 3")
            sentences = "\nAnd you may also somehow in a " + emo + " mood."
        case 4:
            print("number 4")
            sentences = "\nAnd it mix with some " + emo + " emotion."
        case 5:
            print("number 5")
            sentences = "\nAnd you feel a little " + emo + "."
        default:
            print("Wow, you caught me.")
        }
        return sentences
    }
}

