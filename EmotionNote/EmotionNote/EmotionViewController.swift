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

class EmotionViewController: UIViewController,UITextViewDelegate,
    UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    // MARK: Properties
    var note: Note?
    var emotion:JSON?
    var time:String = ""
    @IBOutlet weak var emotionView: UIImageView!
    @IBOutlet weak var contentTextField: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var howDoUTextField: UITextField!
    @IBOutlet weak var resultTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        contentTextField.delegate = self
        //contentTextField.becomeFirstResponder()
        
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
            }*/
            
        }
        resultTextviewStyle()
       
        hideHowDoYouFeelIfNeeded()
        checkEmptyNoteContent()
    }
    func resultTextviewStyle(){
        resultTextView.font = UIFont(name: "Avenir Next", size: 18)
        resultTextView.textColor = UIColor.whiteColor()
        resultTextView.textAlignment = NSTextAlignment.Center
    }
    
    // MARK: Make the content show
    override func viewWillAppear(animated: Bool)  {
        super.viewWillAppear(animated)
        // observe keyboard events
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    override func viewWillDisappear(animated: Bool)  {
        super.viewWillDisappear(animated)
        // remove keyboard observation
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillShowNotification, object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillHideNotification, object:nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: Hide the placeHolder
    func textViewDidBeginEditing(textView: UITextView) {
        checkEmptyNoteContent()
        howDoUTextField.hidden = true
    }
    func textViewDidChange(textView: UITextView) {
        checkEmptyNoteContent()
    }
    func textViewDidEndEditing(textView: UITextView) {
        howDoUTextField.hidden = true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        contentTextField.resignFirstResponder()
    }
    
    
//    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
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
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
//        print("Picker returned successfully")
//        let mediaType:AnyObject? = info[UIImagePickerControllerMediaType]
//        if let type:AnyObject = mediaType{
//            if type is String{
//                let stringType = type as! String
//                if stringType == kUTTypeMovie as NSString{
//                    let urlOfVideo = info[UIImagePickerControllerMediaURL] as? NSURL
//                    if let url = urlOfVideo{
//                        print("Video URL = \(url)")
//                    }
//                }
//                else if stringType == kUTTypeImage as NSString as NSString{
//                    /* Let's get the metadata. This is only for images--not videos */
//                    let metadata = info[UIImagePickerControllerMediaMetadata]
//                        as? NSDictionary
//                    if let theMetaData = metadata{
//                        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
//                        if let theImage = image{
//                            print("Image Metadata = \(theMetaData)")
//                            print("Image = \(theImage)")
//                            
//                                emotionView.image = theImage
//                                ENService.loadImgInfo(emotionView.image!) { (JSON) -> () in
//                                        self.configureWithEmotion(JSON)
//                                    }
//                        } }
//                }
//            } }
//        picker.dismissViewControllerAnimated(true, completion: nil)
//    }
    
    // MARK: select Image
    
    @IBAction func selectImage(sender: UITapGestureRecognizer){
        // Hide the keyboard.
        contentTextField.resignFirstResponder()
        let imagePickerController = UIImagePickerController()
        
        let chooseAWay:UIAlertController = UIAlertController(title: "Choose a way", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        // Choose from photo library
        let photoLib = UIAlertAction(title: "Choose from photo library", style: UIAlertActionStyle.Default){
            (action: UIAlertAction!) -> Void in
            
            imagePickerController.sourceType = .PhotoLibrary
            imagePickerController.delegate = self
            self.presentViewController(imagePickerController, animated: true, completion: nil)
        }
        // Take a picture
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
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive, handler: nil)
        chooseAWay.addAction(takePhoto)
        chooseAWay.addAction(photoLib)
        chooseAWay.addAction(cancel)
        
        self.presentViewController(chooseAWay, animated: true, completion: nil)
        
        
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
    
    // MARK: Cancel
    @IBAction func cancel(sender: UIBarButtonItem) {
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMealMode {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
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
    
    // MARK:keyboard notifications
    func keyboardWillShow(notification: NSNotification) {
        
        let frameValue = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardFrame = frameValue.CGRectValue()
        let animationDuration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        
        let isPortrait = UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)
        let keyboardHeight = isPortrait ? keyboardFrame.size.height : keyboardFrame.size.width
        
        var contentInset = self.contentTextField.contentInset
        let heightSpace:CGFloat = 30
        print(keyboardHeight)
        contentInset.bottom = keyboardHeight - heightSpace
        
        var scrollIndicatorInsets = self.contentTextField.scrollIndicatorInsets
        scrollIndicatorInsets.bottom = keyboardHeight - heightSpace
        
        UIView.animateWithDuration(animationDuration.doubleValue, animations:({
            self.contentTextField.contentInset = contentInset
            self.contentTextField.scrollIndicatorInsets = scrollIndicatorInsets
        })
        )
    }
    func keyboardWillHide(notification: NSNotification) {
        let animationDuration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        
        var contentInset = self.contentTextField.contentInset
        contentInset.bottom = 0
        
        var scrollIndicatorInsets = self.contentTextField.scrollIndicatorInsets
        scrollIndicatorInsets.bottom = 0
        
        UIView.animateWithDuration(animationDuration.doubleValue, animations:({
            self.contentTextField.contentInset = contentInset
            self.contentTextField.scrollIndicatorInsets = scrollIndicatorInsets
        })
        )
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
                /*
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
                    }// end j
                }// end i
                
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
 
    // Show the emotion
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

