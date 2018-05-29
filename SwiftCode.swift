//MARK:- ImagePicker
extension SwiftCodes {
    //MARK: Picker function
    func displayUploadImageDialog(btnSelected: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        let alertController = UIAlertController(title: "", message: "Action on Upload", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action"), style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
            alertController.dismiss(animated: true) {() -> Void in }
        })
        alertController.addAction(cancelAction)
        let takePhotoAction = UIAlertAction(title: NSLocalizedString("Take Photo", comment: "Take Photo action"), style: .default, handler: {(_ action: UIAlertAction) -> Void in
            if UI_USER_INTERFACE_IDIOM() == .pad {
                OperationQueue.main.addOperation({() -> Void in
                    picker.sourceType = .camera
                    self.present(picker, animated: true) {() -> Void in }
                })
            }
            else {
                if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let passwordAlert = UIAlertController(title: "Error", message: "Device has no camera", preferredStyle: .alert)
                    let yesButton = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                        //Handel your yes please button action here
                        passwordAlert.dismiss(animated: true) {() -> Void in }
                    })
                    passwordAlert.addAction(yesButton)
                    self.present(passwordAlert, animated: true) {() -> Void in }
                }
                else {
                    picker.sourceType = .camera
                    self.present(picker, animated: true) {() -> Void in }
                }
            }
        })
        alertController.addAction(takePhotoAction)
        let cameraRollAction = UIAlertAction(title: NSLocalizedString("Camera Roll", comment: "Camera Roll action"), style: .default, handler: {(_ action: UIAlertAction) -> Void in
            if UI_USER_INTERFACE_IDIOM() == .pad {
                OperationQueue.main.addOperation({() -> Void in
                    picker.sourceType = .photoLibrary
                    self.present(picker, animated: true) {() -> Void in }
                })
            }
            else {
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true) {() -> Void in }
            }
        })
        alertController.addAction(cameraRollAction)
        alertController.view.tintColor = Colors.NavTitleColor
        present(alertController, animated: true) {() -> Void in }
    }
    
    //MARK: Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var user = PFUser.current()
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let imageData = UIImageJPEGRepresentation(image, 0.05)
        let imageFile = PFFile(name:"image.jpg", data:imageData!)
        user!["profilePicture"] = imageFile;
        user?.saveInBackground(block: nil)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Picker Cancel Delegate
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK:- Append New Line Instead of Writting
extension SwiftCodes {  //-------- Need to use the further Extensions also
    //MARK: String Extension
    //extension String
    //{
        func appendLineToURL(fileURL: URL) throws
        {
            try (self + "\n").appendToURL(fileURL: fileURL)
        }
        func appendToURL(fileURL: URL) throws
        {
            let data = self.data(using: String.Encoding.utf8)!
            try data.append(fileURL: fileURL)
        }
    //}
    //MARK: NSData Extension
    //extension Data
    //{
        func append(fileURL: URL) throws {
            if let fileHandle = FileHandle(forWritingAtPath: fileURL.path)
            {
                defer
                {
                    fileHandle.closeFile()
                }
                
                fileHandle.seekToEndOfFile()
                fileHandle.write(self)
            }
            else
            {
                try write(to: fileURL, options: .atomic)
            }
        //}
    }
    
    //MARK: Usage
    func updateCsvFile(filename: String) -> Void
    {
        //Name for file
        let fileName = "\(filename).csv"
        let path1 = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentDirectoryPath:String = path1[0]
        //path of file
        let path = NSURL(fileURLWithPath: documentDirectoryPath).appendingPathComponent(fileName)
        
        //Loop to save array //details below header
        for detail in DetailArray
        {
            let newLine = "\(detail.RecordString),\(detail.Name),\(detail.Date),\(detail.time),\(detail.FqMyDietOutput),\(detail.CaloriesMyDietOutput),\(detail.FatMyDietOutput),\(detail.FqMaintDietOutput),\(detail.CaloriesMaintDietOutput),\(detail.FatMaintDietOutput),\(detail.ProteinsOutput),\(detail.netCarbsOutput),\(detail.WeightSliderVal),\(detail.BodyFatSliderVal),\(detail.ActivitySliderVal),\(detail.ProteinSliderVal),\(detail.DietSliderVal),\(detail.FatsSliderVal),\(detail.RMSSDSliderVal),\(detail.BGSliderVal),\(detail.ProteinSliderLabelVal),\(detail.DietSliderLabelVal),\(detail.FatsSliderLabelVal),\(detail.AFI),\(detail.FQI),\(detail.userAppleID)\n"
            
            //Saving handler
            do
            {
                //save
                WrapperClass.saveLastArrayRecordInDefaultsForReference(ArrayValue: newLine)
                try newLine.appendToURL(fileURL: path!)
                showToast(message: "Record is saved")
            }
            catch
            {
                //if error exists
                print("Failed to create file")
                print("\(error)")
            }
            
            print(path ?? "not found")
        }
        //removing all arrays value after saving data
        DetailArray.removeAll()
    }
}


//MARK:- MFMail Composer
extension SwiftCodes : MFMailComposeViewControllerDelegate
{
    //MARK: Configuring email
    func configuredMailComposeViewController() -> MFMailComposeViewController
    {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["info@mitokinetics.com"])
        mailComposerVC.setSubject("MitoCalc Request")
        if (WrapperClass.FileExists()) {
            // locate folder containing pdf file
            let documentsPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
            let pdfFileName = (documentsPath as NSString).appendingPathComponent("mitocalc.csv")
            let fileData = NSData(contentsOfFile: pdfFileName)
            mailComposerVC.addAttachmentData(fileData! as Data, mimeType: "text/csv", fileName: "mitocalc.csv")
        }
        mailComposerVC.setMessageBody("", isHTML: false)
        return mailComposerVC
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    internal func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // Usage
    @IBAction func composeMailBtnAction(_ sender: Any)
    {
        let mailComposeViewController = configuredMailComposeViewController()
        
        if MFMailComposeViewController.canSendMail()
        {
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
        else{ }
    }
}

//MARK:- Document Directory Code
extension SwiftCodes
{
    //MARK: Save File
    /**
     * Usage - getDocumentsDirectory().appendingPathComponent("\(audioName).wav")
     */
    func getDocumentsDirectory() -> URL
    {
        //Get Basic URL
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        /// Enter a Directory Name in which files will be saved
        let dataPath1 = documentsDirectory.appendingPathComponent("folder_name_enter")
        let dataPath = dataPath1.appendingPathComponent("folder inside directory if required (name)")
        //Handler
        do
        {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError
        {
            print("Error creating directory: \(error.localizedDescription)")
        }
        return dataPath
    }
    
    //MARK: Remove Files
    /**
     * Directly Call this function
     */
    func clearAllFilesFromTempDirectory()
    {
        let fileManager = FileManager.default
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let tempDirPath = dirPath.appending("/folder_name/\(inside_directoryName)")
        
        do {
            let folderPath = tempDirPath
            let paths = try fileManager.contentsOfDirectory(atPath: tempDirPath)
            for path in paths
            {
                try fileManager.removeItem(atPath: "\(folderPath)/\(path)")
            }
        }
        catch let error as NSError
        {
            print(error.localizedDescription)
        }
    }
}

//MARK:- Open location in Maps
extension SwiftCodes
{
    // ----> Keys Required
    /*
     <key>LSApplicationQueriesSchemes</key>
     <array>
     <string>googlechromes</string>
     <string>comgooglemaps</string>
     </array>
    */
    
    //MARK: Open Google maps
    func openGoogleMaps(){
        // Open in Google Maps
        if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL))
        {
            /// Driving google map
            ///"comgooglemaps://?saddr=&daddr=40.765819,-73.975866&directionsmode=driving"
            UIApplication.shared.open(URL.init(string: "comgooglemaps://?center=40.765819,-73.975866&zoom=14&views=traffic&q=40.765819,-73.975866")!, options: [:], completionHandler: nil)
        }
        else
        {
            print("Can't use Google Maps");
        }
    }
    
    //MARK: Open Mapkit
    func openMapKit(){
        /// Open in Mapkit
        let latitude:CLLocationDegrees = 40.773379
        let longitude: CLLocationDegrees = -73.964546
        let regiondistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionspan  = MKCoordinateRegionMakeWithDistance(coordinates, regiondistance, regiondistance)
        let options = [MKLaunchOptionsMapCenterKey:regionspan.center]
        
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapitem = MKMapItem(placemark: placemark)
        mapitem.name = "Lawyer Location"
        mapitem.openInMaps(launchOptions: options)
    }
}

//MARK:- Move ScrollView Up Automatically
extension SwiftCodes {
    //MARK: Add Observer - Keyboard
    /**
     This function is used to Add All observers required for Keyboard
     */
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //MARK: Remove Observer - Keyboard
    /**
     This function is used to Remove All observers added
     */
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //MARK: Keyboard Show
    /**
     This is used to add the Keyboard Height to ScrollView for scrolling Effect
     - parameter notification : notification instance
     */
    @objc func keyboardWasShown(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            var contentInset:UIEdgeInsets = self.mainScrollView.contentInset
            contentInset.bottom = keyboardSize.height
            mainScrollView.contentInset = contentInset
        }
    }
    
    //MARK: Keyboard Hide
    /**
     This is used to retain the orignal Height of View
     - parameter notification : notification instance
     */
    @objc func keyboardWillBeHidden(_ notification: Notification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        mainScrollView.contentInset = contentInset
    }
}

//MARK: Data to server
func dataToServer() {
    //        let manager = Alamofire.SessionManager.default
    //        manager.session.configuration.timeoutIntervalForRequest = 120
    Alamofire.upload(multipartFormData: { (multipartFormData) in
        var type = String()
        if (self.vehicleTyprTF.text == "Deluxe" || self.vehicleTyprTF.text == "deluxe") {
            type = "2"
        } else {
            type = "1"
        }
        
        let parameters = [
            "vehicle_make": self.carMakeTF.text!,
            "vehicle_model": self.carModelTF.text!,
            "vehicle_number": self.carNumberTF.text!,
            "user_token": self.userIdString,
            "driver_licence_number": self.licenceNumber.text!,
            "vehicle_type": type,
            "vehicle_year": self.modelYearTF.text!,
            "vehicle_color": self.vehiclaColorTF.text!,
            "seating_capacity": self.seatingCapacityTF.text!] as [String : AnyObject]
        multipartFormData.append(self.licenceImageString, withName: "user_licence_file", fileName: "image.jpeg", mimeType: "image/jpeg")
        multipartFormData.append(self.insuranceImageString, withName: "vehicle_insurance", fileName: "image.jpeg", mimeType: "image/jpeg")
        multipartFormData.append(self.userImageString, withName: "user_profile_image", fileName: "image.jpeg", mimeType: "image/jpeg")
        for (key, value) in parameters {
            multipartFormData.append(value.data(using: String.Encoding.utf8.rawValue)!, withName: key)
        }
        
    }, to:"\(appDelegate.baseURL)/upload-document",
        encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    debugPrint(response)
                    if response.result.isSuccess {
                        let jsonDict = response.result.value as! NSDictionary
                        AFWrapperClass.svprogressHudDismiss(view: self)
                        let dic:NSDictionary = jsonDict as NSDictionary
                        if (dic.object(forKey: "code")) as! String == "1" {
                            let alert = FCAlertView()
                            alert.blurBackground = false
                            alert.cornerRadius = 15
                            alert.bounceAnimations = true
                            alert.dismissOnOutsideTouch = false
                            alert.delegate = self
                            alert.makeAlertTypeSuccess()
                            alert.showAlert(withTitle: "CabScout", withSubtitle: "Documents Uploaded successfully, Your profile is under verification.", withCustomImage: nil, withDoneButtonTitle: nil, andButtons: nil)
                            alert.hideDoneButton = true;
                            alert.addButton("OK", withActionBlock:
                                {
                                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                                    self.navigationController?.pushViewController(viewController, animated: true)
                            })
                        }else
                        {
                            AFWrapperClass.customAlertShow(view: self, msg: dic.object(forKey: "message") as! String , type: "w")
                        }
                    }else
                    {
                        AFWrapperClass.svprogressHudDismiss(view: self)
                        let error : NSError = response.result.error! as NSError
                        AFWrapperClass.svprogressHudDismiss(view: self)
                        AFWrapperClass.customAlertShow(view: self, msg: error.localizedDescription, type: "w")
                    }
                }
                upload.uploadProgress(closure: {
                    progress in
                    print(progress.fractionCompleted)
                })
            case .failure(let encodingError):
                print(encodingError)
                AFWrapperClass.svprogressHudDismiss(view: self)
                AFWrapperClass.customAlertShow(view: self, msg: encodingError.localizedDescription, type: "w")
            }
    })
}

//MARK:- ImagePicker Extension
extension SignUp: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    //MARK: Open Camera
    /**
     This function is used to open Camera for updating profile picture
     */
    private func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            imagePicker?.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker?.allowsEditing = true
            baseController?.present(imagePicker!, animated: true, completion: nil)
        }
        else {
            baseController?.BasicAlert("Service App", message: "No Camera Available", view: baseController!)
        }
    }
    
    //MARK: Open Gallery
    /**
     This function is used to open gallery to select a new profile image
     */
    private func openGallary() {
        imagePicker?.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker?.allowsEditing = true
        baseController?.present(imagePicker!, animated: true, completion: nil)
    }
    
    //MARK: UIImagePicker Controller Result Delegate
    /**
     Called when user selected a Image or a Movie from Gallery
     - parameter picker : The controller object managing the image picker interface
     - parameter info : A dictionary containing the original image and the edited image,
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker .dismiss(animated: true, completion: nil)
        if picker.sourceType == .camera {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                let newDict : [String:Any] = ["type":"image","data":UIImagePNGRepresentation(self.resizeImage(image: image, targetSize: CGSize(width: 600, height: 600)))!,"name":"\(UUID().uuidString).jpeg","image":UIImage.init(named: "pngType") ?? #imageLiteral(resourceName: "pngType")]
                globalArrays.documentDataDictArray?.append(newDict)
                self.documentTableView.reloadData()
                imagePicker = nil
            }
            else{
                imagePicker = nil
                baseController?.BasicAlert("Service App", message: "Error While Selecting Image", view: baseController!)
            }
        }
        else{
            /// Get File Name
            if let url = info[UIImagePickerControllerImageURL] as? URL {
                if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                    let newDict : [String:Any] = ["type":"image","data":UIImagePNGRepresentation(self.resizeImage(image: image, targetSize: CGSize(width: 600, height: 600)))!,"name":url.lastPathComponent,"image":UIImage.init(named: "pngType") ?? #imageLiteral(resourceName: "pngType")]
                    globalArrays.documentDataDictArray?.append(newDict)
                    self.documentTableView.reloadData()
                    imagePicker = nil
                }
                else {
                    imagePicker = nil
                    baseController?.BasicAlert("Service App", message: "Error While Selecting Image", view: baseController!)
                }
                imagePicker = nil
            }
            else {
                imagePicker = nil
                baseController?.BasicAlert("Service App", message: "Error While Selecting Image", view: baseController!)
            }
        }
    }
    
    //MARK: Picker did Cancel
    /**
     Called when user Cancel the picker
     - parameter picker : The controller object managing the image picker interface
     */
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        baseController?.dismiss(animated: true, completion: nil)
        imagePicker = nil
    }
}
