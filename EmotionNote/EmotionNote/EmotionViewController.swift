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
                loadImgInfo(noteimage)
            }
            */
        }
        resultTextView.font = UIFont(name: "Avenir Next", size: 18)
        resultTextView.textColor = UIColor(red:0.227, green:0.552, blue:0.568, alpha:1)
        resultTextView.textAlignment = NSTextAlignment.Center
        
        
        hideHowDoYouFeelIfNeeded()
        checkEmptyNoteContent()
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
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: hide the placeHolder
    func textViewDidBeginEditing(textView: UITextView) {
        saveButton.enabled = true
        howDoUTextField.hidden = true
    }
    func textViewDidEndEditing(textView: UITextView) {
        howDoUTextField.hidden = true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        contentTextField.resignFirstResponder()
    }

    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        emotionView.image = selectedImage
        loadImgInfo(selectedImage)
    
        dismissViewControllerAnimated(true, completion: nil)
    }
    // MARK: select Image
    @IBAction func selectImageFromPhotoLibrary(sender: UITapGestureRecognizer) {
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
                imagePickerController.allowsEditing = true
                imagePickerController.mediaTypes = [kUTTypeImage as NSString as String]
                imagePickerController.delegate = self
                self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
                self.presentViewController(imagePickerController, animated: true, completion: nil)
            }else{
                print("Camera is not available")
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive, handler: nil)
        chooseAWay.addAction(takePhoto)
        chooseAWay.addAction(photoLib)
        chooseAWay.addAction(cancel)
        
        self.presentViewController(chooseAWay, animated: true, completion: nil)
        
        
    }
    // MARK: Using camera
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
    
    // MARK: cancel
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
        print("JSON String:\(jsonNum)")
        
        let noFace:UIAlertController = UIAlertController(title: "WOW", message: "I can't see you clearly, Could you show me another face?", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        noFace.addAction(okAction)
        
        // Those code is written in a huarry,
        // don't follow me!!
        // I mean it!!
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
                    "fear","happiness","neutral","sadness","surprise"]
                let origArrayCopy = origArray
                
                var sortArray:[Double] = [angry,contempt,disgust,fear,happiness,neutral,sadness,surprise]
                
                // store origArray
                for var i = 0; i<sortArray.count; i++ {
                    origArray[i] = "\(sortArray[i])"
                }
                
                sortArray = bubbolSort(sortArray)
                
                for var i = sortArray.count-1;i>=0; i-- {
                    for var j = origArray.count-1;j>=0;j-- {
                        if(String(sortArray[i]) == origArray[j]){
                            print("numArray[\(i)] is equalwellIamTest[\(j)]")
                            print("numArray \(i) is \(origArrayCopy[j])")
                            if i == 7{
                                result += showFirEmotion("\(origArrayCopy[j])")
                            }else if i == 6{
                                result += showSedEmotion("\(origArrayCopy[j])")
                            }
                        }
                    }
                }
                // TODO: Add the result to the content
                resultTextView.text = result
                print("hasFace is not null,it's \(hasFace)")
            }else
            {
                print("Image size is invalid")
                self.presentViewController(noFace, animated: true, completion: nil)
            }
        }else
        {
            print("No face finding in the picture")
            self.presentViewController(noFace, animated: true, completion: nil)
        }
        
    }
    // TODO: Sort emotion. Well, just bubble sort
    func bubbolSort(var array: [Double]) -> [Double] {
        for var i = array.count-1;i>1; i-- {
            for var j = 0;j < i;j++ {
                if array[j] > array[j + 1] {
                    let temp = array[j]
                    array[j] = array[j+1]
                    array[j+1] = temp
                }
            }
        }
        return array
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
    
    // TODO: Get Random number
    func randomIn(min min: Int, max: Int) -> Int{
        return Int(arc4random()) % (max - min + 1) + min}
    
    // MARK: Upload image
    func loadImgInfo(uploadimage:UIImage){
        // init paramters Dictionary
        let parameters = [
            "entities" : "true",
            "faceRectangles": "true",
        ]
        let image = uploadimage
        let imageData = UIImagePNGRepresentation(image)
        
        // CREATE AND SEND REQUEST
        let urlRequest = urlRequestWithComponents("https://api.projectoxford.ai/emotion/v1.0/recognize", parameters: parameters, imageData: imageData!)
        print("begin to upload image.")
        Alamofire.upload(urlRequest.0, data: urlRequest.1)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                //print("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
            }
            .responseJSON {(_, _, data) -> Void in
                let emotion = JSON(data.value ?? [])
                debugPrint(emotion)
                self.configureWithEmotion(emotion)
        }
    }
    
    // this function creates the required URLRequestConvertible and NSData we need to use Alamofire.upload
    func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, String>, imageData:NSData) -> (URLRequestConvertible, NSData) {
        // create url request to send
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        mutableURLRequest.setValue("6e231ef52099425b90918984897ce508", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        mutableURLRequest.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")

        // create upload data to send
        let uploadData = NSMutableData()
        // add image
        uploadData.appendData(imageData)
        // add parameters
        for (key, value) in parameters {
            uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }
}

