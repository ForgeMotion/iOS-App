//
//  CoreDataMethods.swift
//  Swing-Forge-Settings
//
//  Created by Julian Bryant on 1/10/16.
//  Copyright © 2016 TMConsult. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataMethods: NSObject {
    
    class func getUserProfiles() ->NSArray{
        
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
            

            return resultArray
            
            
            
        } catch {
            
            
            return NSArray()
        }
        
    }
    
    class func deleteProfile(_ thisProfile:UserProfile){
        
        let managedObjectContext:NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        managedObjectContext.delete(thisProfile)
        
        saveContext()
    }
    
    class func saveContext(){
        
        let managedObjectContext:NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        
        do {
            try managedObjectContext.save()
            
            print("Save successful.")
            
        } catch {
            print("Failed to save MOC!")
            
        }
        
        //let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //appDelegate.saveContext()
    }
}
