//
//  PersistenceController.swift
//  Contec Spirometer
//
//  Created by Tikhon Petrishchev on 15.09.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import CoreData

class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        Seed().prepareData(for: viewContext)
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ContecSpirometer")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            print("Core Data failed to save model: \(error.localizedDescription)")
        }
    }
    
    func addFVCDataBEXPmodel(fVCDataBEXP: FVCDataBEXP, context: NSManagedObjectContext) {
        let fVCDataBEXPmodel = FVCDataBEXPmodel(context: context)
        fVCDataBEXPmodel.id = UUID()
        fVCDataBEXPmodel.date = fVCDataBEXP.date
        fVCDataBEXPmodel.measureType = Int64(fVCDataBEXP.measureType)
        fVCDataBEXPmodel.gender = Int16(fVCDataBEXP.gender.rawValue)
        fVCDataBEXPmodel.height = Int64(fVCDataBEXP.height)
        fVCDataBEXPmodel.standartType = Int64(fVCDataBEXP.standartType)
        fVCDataBEXPmodel.drug = Int64(fVCDataBEXP.drug)
        fVCDataBEXPmodel.fvc = fVCDataBEXP.FVC
        fVCDataBEXPmodel.fev05 = fVCDataBEXP.FEV05
        fVCDataBEXPmodel.fev1 = fVCDataBEXP.FEV1
        fVCDataBEXPmodel.fev1_fvc = fVCDataBEXP.FEV1_FVC
        fVCDataBEXPmodel.fev3 = fVCDataBEXP.FEV3
        fVCDataBEXPmodel.fev6 = fVCDataBEXP.FEV6
        fVCDataBEXPmodel.pef = fVCDataBEXP.PEF
        fVCDataBEXPmodel.fef25 = fVCDataBEXP.FEF25
        fVCDataBEXPmodel.fef50 = fVCDataBEXP.FEF50
        fVCDataBEXPmodel.fef75 = fVCDataBEXP.FEF75
        fVCDataBEXPmodel.fef2575 = fVCDataBEXP.FEF2575
        fVCDataBEXPmodel.peft = Int64(fVCDataBEXP.PEFT)
        fVCDataBEXPmodel.evol = Int64(fVCDataBEXP.EVOL)
        
        save(context: context)
    }
    
    struct Seed {
        func getSingleFvcDataBexpItem(for viewContext: NSManagedObjectContext) -> FVCDataBEXPmodel {
            let fVCDataBEXPmodel = FVCDataBEXPmodel(context: viewContext)
            fVCDataBEXPmodel.id = UUID()
            fVCDataBEXPmodel.date = Date()
            fVCDataBEXPmodel.measureType = Int64.random(in: 0...4)
            fVCDataBEXPmodel.gender = Int16.random(in: 0...1)
            fVCDataBEXPmodel.age = Int64.random(in: 0...110)
            fVCDataBEXPmodel.height = Int64.random(in: 70...210)
            fVCDataBEXPmodel.standartType = Int64.random(in: 1...3)
            fVCDataBEXPmodel.drug = Int64.random(in: 0...210)
            fVCDataBEXPmodel.fvc = Double.random(in: 0...500)
            fVCDataBEXPmodel.fev05 = Double.random(in: 0...500)
            fVCDataBEXPmodel.fev1 = Double.random(in: 0...500)
            fVCDataBEXPmodel.fev1_fvc = Double.random(in: 0...500)
            fVCDataBEXPmodel.fev3 = Double.random(in: 0...500)
            fVCDataBEXPmodel.fev6 = Double.random(in: 0...500)
            fVCDataBEXPmodel.pef = Double.random(in: 0...500)
            fVCDataBEXPmodel.fef25 = Double.random(in: 0...500)
            fVCDataBEXPmodel.fef50 = Double.random(in: 0...500)
            fVCDataBEXPmodel.fef75 = Double.random(in: 0...500)
            fVCDataBEXPmodel.fef2575 = Double.random(in: 0...500)
            fVCDataBEXPmodel.peft = Int64.random(in: 0...500)
            fVCDataBEXPmodel.evol = Int64.random(in: 0...500)
            return fVCDataBEXPmodel
        }
        
        func prepareData(for viewContext: NSManagedObjectContext) {
            // ** Prepare all sample data for previews here ** //
            
            for _ in 0..<10 {
                _ = getSingleFvcDataBexpItem(for: viewContext)
            }
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}


extension FVCDataBEXPmodel {
    
}
