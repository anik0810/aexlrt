//import HealthKit
//import UIKit
//
//class HealthDataExporter {
//    private let healthStore = HKHealthStore()
//    private let fileManager = FileManager.default
//    
//    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
//        let readTypes: Set<HKSampleType> = [
//            HKObjectType.quantityType(forIdentifier: .heartRate)!,
//            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
//            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
//        ]
//        
//        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
//            completion(success, error)
//        }
//    }
//    
//    func fetchDataAndExport() {
//        let startDate = Calendar.current.date(from: DateComponents(year: 2024, month: 11, day: 11))!
//        let endDate = Calendar.current.date(from: DateComponents(year: 2024, month: 11, day: 15))!
//        
//        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
//        
//        let types: [HKQuantityTypeIdentifier] = [
//            .heartRate,
//            .activeEnergyBurned,
//            .distanceWalkingRunning
//        ]
//        
//        var allData: [[String]] = [["Date", "Type", "Value", "Unit"]]
//        
//        let dispatchGroup = DispatchGroup()
//        
//        for typeIdentifier in types {
//            guard let quantityType = HKObjectType.quantityType(forIdentifier: typeIdentifier) else { continue }
//            
//            dispatchGroup.enter()
//            
//            let query = HKSampleQuery(sampleType: quantityType, predicate: datePredicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, results, error in
//                guard let samples = results as? [HKQuantitySample], error == nil else {
//                    print("Error fetching \(typeIdentifier): \(String(describing: error))")
//                    dispatchGroup.leave()
//                    return
//                }
//                
//                for sample in samples {
//                    let date = sample.startDate
//                    let value = sample.quantity.doubleValue(for: sample.quantityType.defaultUnit)
//                    let unit = sample.quantityType.defaultUnit.unitString
//                    print("Sample: Date=\(date), Type=\(typeIdentifier.rawValue), Value=\(value), Unit=\(unit)")
//                    allData.append([self.formatDate(date), typeIdentifier.rawValue, "\(value)", unit])
//                }
//                
//                dispatchGroup.leave()
//            }
//            
//            healthStore.execute(query)
//        }
//        
//        dispatchGroup.notify(queue: .main) {
//            self.exportToXLS(data: allData)
//        }
//    }
//    
//    private func formatDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .short
//        return formatter.string(from: date)
//    }
//    
//    private func exportToXLS(data: [[String]]) {
//        let csvString = data.map { $0.joined(separator: ",") }.joined(separator: "\n")
//        
//        do {
//            let fileURL = try self.saveCSVToFile(data: csvString)
//            print("File saved at: \(fileURL)")
//        } catch {
//            print("Error saving file: \(error)")
//        }
//    }
//    
//    private func saveCSVToFile(data: String) throws -> URL {
//        let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let fileURL = directory.appendingPathComponent("HealthData.csv")
//        
//        try data.write(to: fileURL, atomically: true, encoding: .utf8)
//        return fileURL
//    }
//}
//
//extension HKQuantityType {
//    var defaultUnit: HKUnit {
//        switch self.identifier {
//        case HKQuantityTypeIdentifier.heartRate.rawValue:
//            return HKUnit(from: "count/min")
//        case HKQuantityTypeIdentifier.activeEnergyBurned.rawValue:
//            return HKUnit.kilocalorie()
//        case HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue:
//            return HKUnit.meter()
//        default:
//            return HKUnit.count()
//        }
//    }
//}
