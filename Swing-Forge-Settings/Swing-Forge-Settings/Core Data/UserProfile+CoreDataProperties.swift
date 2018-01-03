//
//  UserProfile+CoreDataProperties.swift
//  Swing-Forge-Settings
//
//  Created by Julian Bryant on 1/20/16.
//  Copyright © 2016 TMConsult. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension UserProfile {

    @NSManaged var pBackLimit: NSNumber?
    @NSManaged var pBackLimitOn: NSNumber?
    @NSManaged var pFwdLimit: NSNumber?
    @NSManaged var pFwdLimitOn: NSNumber?
    @NSManaged var profileName: String?
    @NSManaged var rHanded: NSNumber?
    @NSManaged var rLeftLimit: NSNumber?
    @NSManaged var rLeftLimitOn: NSNumber?
    @NSManaged var rRightLimit: NSNumber?
    @NSManaged var rRightLimitOn: NSNumber?
    @NSManaged var yBackLimit: NSNumber?
    @NSManaged var yBackLimitOn: NSNumber?
    @NSManaged var yFwdLimit: NSNumber?
    @NSManaged var yFwdLimitOn: NSNumber?
    @NSManaged var isFactoryDefault: NSNumber?

}
