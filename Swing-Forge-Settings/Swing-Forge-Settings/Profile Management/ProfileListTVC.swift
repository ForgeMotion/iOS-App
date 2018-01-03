//
//  ProfileListTVC.swift
//  Swing-Forge-Settings
//
//  Created by Julian Bryant on 1/5/16.
//  Copyright © 2016 TMConsult. All rights reserved.
//

import UIKit
import CoreData
//import BLE
//import DeleteMe

class ProfileListTVC: UITableViewController, BLEDelegate, CBCentralManagerDelegate {

    var userProfiles:NSArray = []
    
    var bleShield:BLE?
    var deviceIsConnected:Bool = false
    var centralManager:CBCentralManager?
    
    var bleDevicesArray:NSMutableArray = []
    
    var profileToLoad:UserProfile?
    
    
    @IBOutlet var connectionButton:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bleShield = BLE()
        bleShield?.controlSetup()
        bleShield?.delegate = self
        
        centralManager?.delegate = self
        
        /*
        bleShield = [[BLE alloc] init];
        [bleShield controlSetup];
        bleShield.delegate = self;
        */

        
        /*
        connectionButton.backgroundImageForState(UIControlState.Normal, barMetrics: UIBarMetrics.Default) = UIImage(named: "iconDonate@2x.png")
        
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"Test"];
        button.layer.backgroundColor = [UIColor redColor].CGColor;
        button.layer.cornerRadius = 4.0;
        
        UIBarButtonItem* buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.toolbarItems = @[buttonItem];
        */
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Load Profiles from local database
        getUserProfiles()
        self.tableView.reloadData()
        
        //Show user if device is connected
        toggleConnectedButtonState()
        
        
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if #available(iOS 10.0, *) {
            switch central.state{
            case CBManagerState.poweredOff:
                print("Julian CoreBluetooth BLE hardware is powered off")
            case CBManagerState.poweredOn:
                print("Julian CoreBluetooth BLE hardware is powered on and ready")
            case CBManagerState.unauthorized:
                print("Julian CoreBluetooth BLE state is unauthorized")
            case CBManagerState.unknown:
                print("Julian CoreBluetooth BLE state is unknown")
            case CBManagerState.unsupported:
                print("Julian CoreBluetooth BLE hardware is unsupported on this platform")
            default:
                break
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    @IBAction func connectOrDisconnect(){
        if (deviceIsConnected){
            disconnectDevice()
        } else {
            doScan()
        }
    }
    
    @IBAction func doScan(){
        
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            loadingNotification?.mode = MBProgressHUDMode.indeterminate
            loadingNotification?.labelText = "Scanning for Devices"
        
        
        if ((bleShield!.activePeripheral) != nil){
            
            if(bleShield!.activePeripheral.state == CBPeripheralState.connected){
                bleShield?.cm.cancelPeripheralConnection(bleShield!.activePeripheral)
                return
            }
        }
        
        if ((bleShield!.peripherals != nil)){
            bleShield!.peripherals = nil;
        }
        
        //Look for peripherals for 5 sec
        bleShield?.findPeripherals(5)
        
        //Create a timer to check the number of peripheals available after 5 sec.
        Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(ProfileListTVC.connectionTimerFired), userInfo: nil, repeats: false)
        
    }
    
    func disconnectDevice(){
        if ((bleShield!.activePeripheral) != nil){
            
            if(bleShield!.activePeripheral.state == CBPeripheralState.connected){
                bleShield?.cm.cancelPeripheralConnection(bleShield!.activePeripheral)
                //[[bleShield CM] cancelPeripheralConnection:[bleShield activePeripheral]];
                return
            }
        }
        
        if ((bleShield!.peripherals != nil)){
            bleShield!.peripherals = nil;
        }
    }
    
    func connectionTimerFired(){
        
        if let myDevices = bleShield?.peripherals {
            print("Good! Found \(bleShield!.peripherals.count) peripherals.")
            
            let selectPeripheralController:UIAlertController = UIAlertController(title: "Which Device?", message: "Select the device you want to connect to.", preferredStyle: UIAlertControllerStyle.alert)
            
            for peripheral in myDevices  {
            //for peripheral in bleShield!.peripherals  {
                let thisPeripheral = peripheral as! CBPeripheral
                
                
                var myName = ""
                if let thisName = thisPeripheral.name {
                    myName = thisName
                } else {
                    myName = "[No Name]"
                }
                
                //let thisLabel = "\(myName) (\(thisPeripheral.identifier.UUIDString))"
                let thisLabel = "\(myName)"
                let deviceAction:UIAlertAction = UIAlertAction(title: thisLabel, style: .default){ action -> Void in
                    
                    self.connectToPeripheral(thisPeripheral)
                    
                    
                }
                selectPeripheralController.addAction(deviceAction)
            }
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                //Just dismiss the action sheet
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            }
            selectPeripheralController.addAction(cancelAction)
            
            present(selectPeripheralController, animated: true, completion: nil)
            
        } else {
            UtilityMethods.showAlertInView("Error!", message: "Cannot find a device to connect to. Make sure Bluetooth is enabled on both the phone and the device and try again.", presentingViewController: nil)
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
        }
        
        /*
        if(bleShield!.peripherals.count > 0){
            print("Good! Found \(bleShield!.peripherals.count) peripherals.")
            
            
            //if(bleShield!.peripherals.count == 1){
                //There is only one so connect to it
                let thisPeripheral = bleShield!.peripherals.objectAtIndex(0) as! CBPeripheral
                connectToPeripheral(thisPeripheral)
                
            //} else {
                //There is more than one available, so give user option on which to connect to.
                let selectPeripheralController:UIAlertController = UIAlertController(title: "Which Device?", message: "Select the device you want to connect to.", preferredStyle: UIAlertControllerStyle.Alert)
                
                for peripheral in bleShield!.peripherals  {
                    let thisPeripheral = peripheral as! CBPeripheral
                    
                    var myName = ""
                    if let thisName = thisPeripheral.name {
                        myName = thisName
                    } else {
                        myName = "[No Name]"
                    }
                    
                    let thisLabel = "\(myName) (\(thisPeripheral.identifier.UUIDString))"
                    let deviceAction:UIAlertAction = UIAlertAction(title: thisLabel, style: .Default){ action -> Void in
                        
                        self.connectToPeripheral(thisPeripheral)
                        

                    }
                    selectPeripheralController.addAction(deviceAction)
                }
                
                let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
                    //Just dismiss the action sheet
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                }
                selectPeripheralController.addAction(cancelAction)
                
                presentViewController(selectPeripheralController, animated: true, completion: nil)
                
            //}
            
        } else {
            //print("I found nothing")
            
            UtilityMethods.showAlertInView("Error!", message: "Cannot find a device to connect to. Make sure Bluetooth is enabled on both the phone and the device and try again.", presentingViewController: nil)
            
        }
    */
    }
    
    
    func connectToPeripheral(_ deviceToConnectTo:CBPeripheral){
        print("Connecting to \(deviceToConnectTo.name) \(deviceToConnectTo.identifier)")
        
        UserDefaults.standard.set(deviceToConnectTo.name!, forKey: kUSERDEFAULT_PeripheralName)
        UserDefaults.standard.set(deviceToConnectTo.identifier.uuidString, forKey: kUSERDEFAULT_PeripheralID)
        UserDefaults.standard.synchronize()
        
        bleShield?.connectPeripheral(deviceToConnectTo)
        
        //Hide HUD
        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
    }
    
    /*
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Connected!")
    }
    */
    
    func bleDidConnect() {
        print("bleDidConnect")
        deviceIsConnected = true
        toggleConnectedButtonState()
        
        //Load a profile if one had been selected
        if (profileToLoad != nil){
            self.writeProfileToBLE(profileToLoad!)
            profileToLoad = nil
        }
        
    }
    
    func bleDidDisconnect() {
        print("bleDidDisconnect")
        deviceIsConnected = false
        toggleConnectedButtonState()
    }
    
    func toggleConnectedButtonState(){
        if(deviceIsConnected){
            //Connected UI
            let myImage = UIImage(named: "green22.png")
            connectionButton.setBackgroundImage(myImage, for: UIControlState(), barMetrics: UIBarMetrics.default)
            connectionButton.title = "OK"
            
        } else {
            let myImage = UIImage(named: "red22.png")
            connectionButton.setBackgroundImage(myImage, for: UIControlState(), barMetrics: UIBarMetrics.default)
            connectionButton.title = "No Device"
        }
    }
    
    func getUserProfiles() ->NSArray{
        
        let managedObjectContext:NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let request:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserProfile")
        
        /*
        let sortDescriptor = NSSortDescriptor(key: "category_name", ascending: true)
        let sortDescriptors = [sortDescriptor]
        request.sortDescriptors = sortDescriptors
        */
        
        /*
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.Indeterminate
            loadingNotification.labelText = "Scanning..."
        */
        
        
        do {
            let resultArray:NSArray = try managedObjectContext.fetch(request) as NSArray
            //print("results: \(resultArray.count)")
            self.userProfiles = resultArray
            self.tableView.reloadData()
            
            /*
            dispatch_async(dispatch_get_main_queue()) {
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            }
            */
            
            return resultArray
            
            
            
        } catch {
            DispatchQueue.main.async {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            }
            
            return NSArray()
        }
        
    }
    
    func writeProfileToBLE(_ profileToWrite:UserProfile){
        
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading Profile in Device"
        
        //Create message to send
        /*
        Send a sync byte (let's use 0xFF)
        Send the first four angles in tenths of a degree (e.g. 55 means 5.5 degrees)
        Send the last two angles as themselves
        Send one byte that represents all 7 binary values.
        E.g. 01010101 means: (leading zero is reserved) Forward is True, Backward is False, Right is True, Left is False, Backswing is True, Front swing is False and Right Handed is True.
        End the message with a newline (though I can't remember if the device wanted a newline or carriage return, so we may have to switch that).
        
        So, for example, the message that represents the screenshot (attached) would be:
        0xFF 50 75 40 40 40 40 0b01111111 \n
        */
        /*
        var myWriteString = "0xFF "
        
        myWriteString = myWriteString + "\(profileToWrite.pFwdLimit!.integerValue) "
        myWriteString = myWriteString + "\(profileToWrite.pBackLimit!.integerValue) "
        myWriteString = myWriteString + "\(profileToWrite.rRightLimit!.integerValue) "
        myWriteString = myWriteString + "\(profileToWrite.rLeftLimit!.integerValue) "

        myWriteString = myWriteString + "\(profileToWrite.yBackLimit!.integerValue / 10) "
        myWriteString = myWriteString + "\(profileToWrite.yFwdLimit!.integerValue / 10) "

        myWriteString = myWriteString + "0b"
        
        myWriteString = myWriteString + "\(profileToWrite.pFwdLimitOn!.integerValue)"
        myWriteString = myWriteString + "\(profileToWrite.pBackLimitOn!.integerValue)"
        myWriteString = myWriteString + "\(profileToWrite.rRightLimitOn!.integerValue)"
        myWriteString = myWriteString + "\(profileToWrite.rLeftLimitOn!.integerValue)"
        myWriteString = myWriteString + "\(profileToWrite.yBackLimitOn!.integerValue)"
        myWriteString = myWriteString + "\(profileToWrite.yFwdLimitOn!.integerValue)"
        myWriteString = myWriteString + "\(profileToWrite.rHanded!.integerValue) "
        
        myWriteString = myWriteString + "\n"
        */
        
        
        //var myWriteString = "123456789 123456789 12345"
        
        var temp:UInt8 = 0
        temp = (temp | UInt8(profileToWrite.pFwdLimitOn!.intValue)) << 1
        temp = (temp | UInt8(profileToWrite.pBackLimitOn!.intValue)) << 1
        temp = (temp | UInt8(profileToWrite.rRightLimitOn!.intValue)) << 1
        temp = (temp | UInt8(profileToWrite.rLeftLimitOn!.intValue)) << 1
        temp = (temp | UInt8(profileToWrite.yBackLimitOn!.intValue)) << 1
        temp = (temp | UInt8(profileToWrite.yFwdLimitOn!.intValue)) << 1
        temp = (temp | UInt8(profileToWrite.rHanded!.intValue))
        
        let commands = NSMutableData()
        let cmd : [UInt8] = [ 0xFF,
            UInt8(profileToWrite.pFwdLimit!.intValue),
            UInt8(profileToWrite.pBackLimit!.intValue),
            UInt8(profileToWrite.rRightLimit!.intValue),
            UInt8(profileToWrite.rLeftLimit!.intValue),
            UInt8(profileToWrite.yBackLimit!.intValue / 10),
            UInt8(profileToWrite.yFwdLimit!.intValue / 10),
            temp]
        
        commands.append(cmd, length: cmd.count)
        bleShield!.write(commands as Data!)
        
        /*
        var myWriteString = "2,"
        myWriteString = myWriteString + "\(profileToWrite.pFwdLimit!.integerValue),"
        myWriteString = myWriteString + "\(profileToWrite.pBackLimit!.integerValue),"
        myWriteString = myWriteString + "\(profileToWrite.rRightLimit!.integerValue),"
        myWriteString = myWriteString + "\(profileToWrite.rLeftLimit!.integerValue),"
        
        myWriteString = myWriteString + "\(profileToWrite.yBackLimit!.integerValue / 10),"
        myWriteString = myWriteString + "\(profileToWrite.yFwdLimit!.integerValue / 10),"

        
        myWriteString = myWriteString + "\(profileToWrite.pFwdLimitOn!.integerValue)"
        myWriteString = myWriteString + "\(profileToWrite.pBackLimitOn!.integerValue)"
        myWriteString = myWriteString + "\(profileToWrite.rRightLimitOn!.integerValue)"
        myWriteString = myWriteString + "\(profileToWrite.rLeftLimitOn!.integerValue)"
        myWriteString = myWriteString + "\(profileToWrite.yBackLimitOn!.integerValue)"
        myWriteString = myWriteString + "\(profileToWrite.yFwdLimitOn!.integerValue)"
        myWriteString = myWriteString + "\(profileToWrite.rHanded!.integerValue)"
        */

        
        
        //Send message
        //let myData = myWriteString.dataUsingEncoding(NSUTF8StringEncoding)
        //let myData = myWriteString.dataUsingEncoding(NSASCIIStringEncoding)
        //let myData = myWriteString.dataUsingEncoding(NSASCIIStringEncoding)
        //bleShield!.write(myData)
        
        
        //let mySampleData = DeleteMe.createSampleMessage()
        //bleShield!.write(mySampleData)
        
        
        //let text = "123Ö\n"
        /*
        let commands = NSMutableData()
        if let data = myWriteString.dataUsingEncoding(NSISOLatin1StringEncoding) {
            commands.appendData(data)
            print(commands) // 313233d6 0a>
            bleShield!.write(commands)
        } else {
            print("conversion failed")
        }
        */
        
        //Create a timer to check the number of peripheals available after 5 sec.
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ProfileListTVC.profileLoadingTimerFired), userInfo: nil, repeats: false)
        
        
        
        /*
        NSMutableData *commands = [[NSMutableData alloc] init];
        //Test
        [commands appendBytes:"\x1d\x21\x00" length:sizeof("\x1d\x21\x00") - 1];    // Cancel Expansion - Reference Star Portable Printer Programming Manual
        
        
        [commands appendBytes:"\x1d\x57\x40\x32"
        length:sizeof("\x1d\x57\x40\x32") - 1];    // Page Area Setting     <GS> <W> nL nH  (nL = 64, nH = 2)
        
        [commands appendBytes:"\x1b\x61\x01"
        length:sizeof("\x1b\x61\x01") - 1];    // Center Justification  <ESC> a n       (0 Left, 1 Center, 2 Right)
        
        NSString *locationString = [NSString stringWithFormat:@"Ace Parking\n\n"];
        [commands appendData:[locationString dataUsingEncoding:NSASCIIStringEncoding]];
        */
        
        /*
        //Send data
        NSString *myString1 = @"01111110";
        NSData *myData1 = [myString1 dataUsingEncoding:NSUTF8StringEncoding];
        
        [bleShield write:myData1];
        [bleShield write:myData1];
        
        float myNumber = -8.5;
        NSString *myStringyNumber = [NSString stringWithFormat:@"%f",myNumber];
        NSData *myData2 = [myStringyNumber dataUsingEncoding:NSUTF8StringEncoding];
        [bleShield write:myData2];
        */
        
    }
    
    func profileLoadingTimerFired(){
        
        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
        
        UtilityMethods.showAlertInView("Success", message: "Your profile is loaded.", presentingViewController: nil)
    }

    func confirmProfileDeletion(_ profileToDelete:UserProfile){
        let confirmAlertController:UIAlertController = UIAlertController(title: "Warning", message: "Are you sure you want to delete profile \"\(profileToDelete.profileName!)?\"", preferredStyle: UIAlertControllerStyle.alert)
        
        let deleteAction:UIAlertAction = UIAlertAction(title: "DELETE", style: .destructive){ action -> Void in
            
            CoreDataMethods.deleteProfile(profileToDelete)
            self.getUserProfiles()
            
            
        }
        confirmAlertController.addAction(deleteAction)
        
    
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Just dismiss the action sheet
            //MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        }
        confirmAlertController.addAction(cancelAction)
        
        present(confirmAlertController, animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return userProfiles.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if (userProfiles.count == 0){
            return "Tap + to create a profile."
            
        } else {
            return "Swipe Profile for Load and Delete Options."
            
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let profileCell = tableView.dequeueReusableCellWithIdentifier("ProfileCell", forIndexPath: indexPath) as! ProfileCell
        let profileCell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)

        let thisUserProfile:UserProfile = self.userProfiles.object(at: indexPath.row) as! UserProfile
        profileCell.textLabel?.text = thisUserProfile.profileName
        
        //For custom cell version
        //profileCell.profileNameLabel.text = thisUserProfile.profileName
        //profileCell.loadProfileBtn.layer.cornerRadius = 10
        
        return profileCell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        //Delete
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler: { (action, indexPath) -> Void in
            tableView.isEditing = false
            
            
            let thisUserProfile = self.userProfiles[indexPath.row] as! UserProfile
            self.confirmProfileDeletion(thisUserProfile)
            /*
            CoreDataMethods.deleteProfile(thisUserProfile)
            
            self.getUserProfiles()
            */
        })
        deleteAction.backgroundColor = UIColor.red
        
        
        
        //Load Profile
        let loadProfileAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Load", handler: { (action, indexPath) -> Void in
            tableView.isEditing = false
            
            let thisProfile = self.userProfiles.object(at: indexPath.row) as! UserProfile
            
            if(self.deviceIsConnected) {
                print("Load Profile")
                
                self.writeProfileToBLE(thisProfile)
                
            } else {
                self.profileToLoad = thisProfile
                self.doScan()
                //UtilityMethods.showAlertInView("Error", message: "No device is connected to the iPhone.", presentingViewController: nil)
            }
            
            
            
            
        })
        loadProfileAction.backgroundColor = UIColor.blue
        
        var arrayOfActions = NSArray()
        
        if (indexPath.row == 0){
            arrayOfActions = [loadProfileAction]
            
        } else {
            arrayOfActions = [deleteAction, loadProfileAction]
        }
        
        //let arrayOfActions: Array = [deleteAction, loadProfileAction]
        return arrayOfActions as? [UITableViewRowAction]
        
    }
    
    
    
    
    
    /*
    @IBAction func loadProfile(profileToLoad:UserProfile){
        
    }
    */
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // Intentionally blank. Required to use UITableViewRowActions
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "editProfile"){
            
            let selectedPath = self.tableView.indexPathForSelectedRow
            let profileIndex = selectedPath?.row
            let selectedProfile = self.userProfiles.object(at: profileIndex!)
            
            let profileSettingsVC = segue.destination as! ProfileSettingsTVC
            profileSettingsVC.thisUserProfile = selectedProfile as! UserProfile
            
        } 
    }

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
