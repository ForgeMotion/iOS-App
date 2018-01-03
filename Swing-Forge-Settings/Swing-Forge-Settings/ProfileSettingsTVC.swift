//
//  ProfileSettingsTVC.swift
//  Swing-Forge-Settings
//
//  Created by Julian Bryant on 1/9/16.
//  Copyright © 2016 TMConsult. All rights reserved.
//

import UIKit
import CoreData

class ProfileSettingsTVC: UITableViewController, UITextFieldDelegate {

    
    /*
    First profile is a "Factory Default" profile.
    Profile has default settings.
    This profile cannot be deleted or edited (settings view options should be greyed out)
    App will always have at least the Factory Default profile (need to setup in App Delegate)
    */
    
    var moc:NSManagedObjectContext?
    
    var viewMode = "addProfile"
    var thisUserProfile:UserProfile?
    
    @IBOutlet weak var profileNameField: UITextField!
    
    @IBOutlet weak var tiltForwardSwitch: UISwitch!
    @IBOutlet weak var tiltForwardLabel: UILabel!
    @IBOutlet weak var tiltForwardStepper: UIStepper!
    
    @IBOutlet weak var tiltBackwardSwitch: UISwitch!
    @IBOutlet weak var tiltBackwardLabel: UILabel!
    @IBOutlet weak var tiltBackwardStepper: UIStepper!
    
    @IBOutlet weak var swayRightSwitch: UISwitch!
    @IBOutlet weak var swayRightLabel: UILabel!
    @IBOutlet weak var swayRightStepper: UIStepper!
    
    @IBOutlet weak var swayLeftSwitch: UISwitch!
    @IBOutlet weak var swayLeftLabel: UILabel!
    @IBOutlet weak var swayLeftStepper: UIStepper!
    
    @IBOutlet weak var swingBackSwitch: UISwitch!
    @IBOutlet weak var swingBackLabel: UILabel!
    @IBOutlet weak var swingBackStepper: UIStepper!
    
    @IBOutlet weak var swingEndSwitch: UISwitch!
    @IBOutlet weak var swingEndLabel: UILabel!
    @IBOutlet weak var swingEndStepper: UIStepper!
    
    @IBOutlet weak var gripSegmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.moc = appDelegate.managedObjectContext
        
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let thisProfile = self.thisUserProfile {
            setProfileInfoToUIControls()
        } else {
            createProfile()
        }
        
        /*
        if(self.viewMode == "addProfile"){
            createProfile()
        } else {
            setProfileInfoToUIControls()
        }
        */
        
        /*
        if ([self.viewMode isEqualToString:@"addProfile"]) {
            //We're creating a new profile
            
            [self createProfile];
            [self setProfileInfoToUIControls];
            
        } else {
            //We're just editing the profile that was passed to the View Controller.
            [self setProfileInfoToUIControls];
        }
        */
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        saveUIValuesToProfile()
        self.thisUserProfile = nil
    }
    
    func createProfile(){
        
        let newUserProfile:UserProfile = NSEntityDescription.insertNewObject(forEntityName: "UserProfile", into: self.moc!) as! UserProfile
        
        newUserProfile.profileName = "New Profile"
        
        //CoreDataMethods.saveContext()
        
        //Should be contingent on sucessful save.
        //setProfileInfoToUIControls()
        
        do {
            try self.moc!.save()
            self.thisUserProfile = newUserProfile
            
            print("Save successful.")
            setProfileInfoToUIControls()
            
        } catch {
            print("Failed to save MOC!")
            
        }
        
        
    }
    
    func setProfileInfoToUIControls(){
        
        let currentProfile = self.thisUserProfile!
        
        var settingsAreEditable = true
        if (currentProfile.isFactoryDefault?.boolValue == true){
            settingsAreEditable = false
        }
        
        self.profileNameField.text = currentProfile.profileName
        
        if((currentProfile.rHanded?.boolValue) == true){
            self.gripSegmentedControl.selectedSegmentIndex = 0
        } else {
            self.gripSegmentedControl.selectedSegmentIndex = 1
        }
        
        profileNameField.text = currentProfile.profileName
        
        //displayValue = (currentProfile.pFwdLimit?.integerValue)! / 10
        
        tiltForwardLabel.text = "\((currentProfile.pFwdLimit?.doubleValue)! / 10)"
        tiltForwardSwitch.isOn = (currentProfile.pFwdLimitOn?.boolValue)!
        tiltForwardSwitch.isEnabled = settingsAreEditable
        tiltForwardStepper.value = (currentProfile.pFwdLimit?.doubleValue)!
        tiltForwardStepper.isEnabled = settingsAreEditable
        
        tiltBackwardLabel.text = "\((currentProfile.pBackLimit?.doubleValue)! / 10)"
        tiltBackwardSwitch.isOn = (currentProfile.pBackLimitOn?.boolValue)!
        tiltBackwardSwitch.isEnabled = settingsAreEditable
        tiltBackwardStepper.value = (currentProfile.pBackLimit?.doubleValue)!
        tiltBackwardStepper.isEnabled = settingsAreEditable
        
        swayRightLabel.text = "\((currentProfile.rRightLimit?.doubleValue)! / 10)"
        swayRightSwitch.isOn = (currentProfile.rRightLimitOn!.boolValue)
        swayRightSwitch.isEnabled = settingsAreEditable
        swayRightStepper.value = (currentProfile.rRightLimit?.doubleValue)!
        swayRightStepper.isEnabled = settingsAreEditable
        
        swayLeftLabel.text = "\((currentProfile.rLeftLimit?.doubleValue)! / 10)"
        swayLeftSwitch.isOn = (currentProfile.rLeftLimitOn!.boolValue)
        swayLeftSwitch.isEnabled = settingsAreEditable
        swayLeftStepper.value = (currentProfile.rLeftLimit?.doubleValue)!
        swayLeftStepper.isEnabled = settingsAreEditable
        
        //let backDisplayValue = (currentProfile.yBackLimit?.doubleValue)! / 10
        
        swingBackLabel.text = "\((currentProfile.yBackLimit?.intValue)! / 10)"
        swingBackSwitch.isOn = (currentProfile.yBackLimitOn!.boolValue)
        swingBackSwitch.isEnabled = settingsAreEditable
        swingBackStepper.value = (currentProfile.yBackLimit?.doubleValue)!
        swingBackStepper.isEnabled = settingsAreEditable
        
        swingEndLabel.text = "\((currentProfile.yFwdLimit?.intValue)! / 10)"
        swingEndSwitch.isOn = (currentProfile.yFwdLimitOn!.boolValue)
        swingEndSwitch.isEnabled = settingsAreEditable
        swingEndStepper.value = (currentProfile.yFwdLimit?.doubleValue)!
        swingEndStepper.isEnabled = settingsAreEditable
    }
    
    func saveUIValuesToProfile(){
        self.thisUserProfile!.profileName = self.profileNameField.text;
        
        self.thisUserProfile!.pFwdLimit = NSNumber(value: self.tiltForwardStepper.value as Double)
        self.thisUserProfile!.pBackLimit = NSNumber(value: self.tiltBackwardStepper.value as Double)
        self.thisUserProfile!.rRightLimit = NSNumber(value: self.swayRightStepper.value as Double)
        self.thisUserProfile!.rLeftLimit = NSNumber(value: self.swayLeftStepper.value as Double)
        self.thisUserProfile!.yBackLimit = NSNumber(value: self.swingBackStepper.value as Double)
        self.thisUserProfile!.yFwdLimit = NSNumber(value: self.swingEndStepper.value as Double)

        self.thisUserProfile!.pFwdLimitOn = NSNumber(value: self.tiltForwardSwitch.isOn as Bool)
        self.thisUserProfile!.pBackLimitOn = NSNumber(value: self.tiltBackwardSwitch.isOn as Bool)
        self.thisUserProfile!.rRightLimitOn = NSNumber(value: self.swayRightSwitch.isOn as Bool)
        self.thisUserProfile!.rLeftLimitOn = NSNumber(value: self.swayLeftSwitch.isOn as Bool)
        self.thisUserProfile!.yBackLimitOn = NSNumber(value: self.swingBackSwitch.isOn as Bool)
        self.thisUserProfile!.yFwdLimitOn = NSNumber(value: self.swingEndSwitch.isOn as Bool)
        
        
        
        if (self.gripSegmentedControl.selectedSegmentIndex==0) {
            self.thisUserProfile!.rHanded = NSNumber(value: true as Bool)
            
        } else {
            self.thisUserProfile!.rHanded = NSNumber(value: false as Bool)
            
        }
        
        do {
            try self.moc?.save()
            //self.thisUserProfile = newUserProfile
            //setProfileInfoToUIControls()
            print("MOC save successful.")
            
        } catch {
            print("Failed to save MOC!")
            
        }
    }
    
    @IBAction func stepperValueChanged(_ stepper:UIStepper){
        //[NSString stringWithFormat:@"%i",(int)sender.value];
        
        let displayValue:Double = (stepper.value / 10)
        
        switch stepper.tag {
        case 0:
            tiltForwardLabel.text = "\(displayValue)"
            //tiltForwardLabel.text = "\(stepper.value)"
            
        case 1:
            tiltBackwardLabel.text = "\(displayValue)"
            
        case 2:
            swayRightLabel.text = "\(displayValue)"
            
        case 3:
            swayLeftLabel.text = "\(displayValue)"
            
        case 4:
            swingBackLabel.text = "\(Int(displayValue))"
            
        case 5:
            swingEndLabel.text = "\(Int(displayValue))"
            
        default:
            swingEndLabel.text = "\(Int(displayValue))"
        }
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        profileNameField.resignFirstResponder()
        return true
    }
    
    // MARK: - Table view data source
    /*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    */
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
