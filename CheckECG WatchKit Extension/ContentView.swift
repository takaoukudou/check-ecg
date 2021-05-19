import SwiftUI
import HealthKit

struct ContentView: View {
    
    @State private var msg = "STANBY"
    @State private var msg_max = "MaxValue"
    @State private var msg_min = "MinValue"
    
    let myHealthStore = HKHealthStore()
    //     Healthデータへのアクセスを申請.
    private func requestAuthorization(){
        let types = Set(arrayLiteral:
                            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
                        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.oxygenSaturation)!,
                        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
        )
        
        
        // HealthStoreへのアクセス承認をおこなう.
        myHealthStore.requestAuthorization(toShare: types, read: types, completion: { (success, error) in
            if let e = error {
                print("Error: \(e.localizedDescription)")
            }
            print(success ? "Success" : "Failure")
        })
    }
    
    // Healthデータの取得
    private func readHeartRateData() {
        
        let typeOfHeartRate = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        
        let calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        
        let now = Date()
        
        let startDate = calendar.startOfDay(for: now)
        
        let endDate = calendar.date(byAdding: Calendar.Component.day, value: 1, to: startDate)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let statsOptions: HKStatisticsOptions = [HKStatisticsOptions.discreteMax, HKStatisticsOptions.discreteMin]
        
        let staticsQuery = HKStatisticsQuery(quantityType: typeOfHeartRate!, quantitySamplePredicate: predicate, options: statsOptions) { (query, result, error) in
            if let e = error {
                print("Error:\(e.localizedDescription)")
                return
            }
            
            guard let max = result?.maximumQuantity()
            else {
                print("max is not found")
                return
            }
            guard let mim = result?.minimumQuantity()
            else {
                print("mini is not found")
                return
            }
            
            DispatchQueue.main.async {
                // 最大値のデータを取得.
                self.msg_max = "Max: \(max)"
                // 最小値のデータを取得.
                self.msg_min = "Min: \(mim)"
            }
        }
        
        self.myHealthStore.execute(staticsQuery)
        
    }
    
    var body: some View {
        VStack{
            Text("許可?")
                .onTapGesture
                {
                    self.requestAuthorization()
                }
            
            Text(msg)
                .onTapGesture {
                    self.msg = "OK"
                    self.readHeartRateData()
                }
            Text(msg_max)
            Text(msg_min)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
