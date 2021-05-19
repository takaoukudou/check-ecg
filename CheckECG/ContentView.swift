import SwiftUI
import HealthKit
import UIKit

struct ContentView: View {
    
    @State private var msg = "データ取得"
    @State private var msg_max = "MaxValue"
    @State private var msg_min = "MinValue"
    @State private var stepTitle = "歩数"
    @State private var heartRateTitle = "心拍数"
    @State private var oxigenSaturationTitle = "血中酸素濃度"
    @State private var step = "-"
    @State private var heartRate = "-"
    @State private var oxigenSaturation = "-"
    @State private var showingAlert = false
    
    
    
    let myHealthStore = HKHealthStore()
    
    private func getDate() -> String{
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .none
        f.locale = Locale(identifier: "ja_JP")
        let now = Date()
        return f.string(from: now)
    }
    
    // Healthデータの取得
    private func readHeartRateData() {
        //歩数
        let typeOfStepCount = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        //心拍数
        let typeOfHeartRate = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        //血中酸素濃度
        let typeOfOxigenSaturation = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.oxygenSaturation)
        
        let calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        
        let now = Date()
        
        let startDate = calendar.startOfDay(for: now)
        
        let endDate = calendar.date(byAdding: Calendar.Component.day, value: 1, to: startDate)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let statsOptions: HKStatisticsOptions = [HKStatisticsOptions.discreteMax, HKStatisticsOptions.discreteMin]
        
        queryHeartData(type: typeOfHeartRate!, predicate: predicate, options: statsOptions)
        queryStepData(type: typeOfStepCount!, predicate: predicate)
        queryOxigenData(type: typeOfOxigenSaturation!, predicate: predicate, options: statsOptions)
    }
    
    private func queryHeartData(type:HKQuantityType,predicate:NSPredicate, options:HKStatisticsOptions){
        let staticsQuery = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: options) { (query, result, error) in
            if let e = error {
                print("Error:\(e.localizedDescription)")
                return
            }
            
            guard let max = result?.maximumQuantity()?.doubleValue(for: HKUnit(from: "count/min"))
            else {
                print("max is not found")
                self.heartRate = "-"
                return
            }
            guard let mim = result?.minimumQuantity()?.doubleValue(for: HKUnit(from: "count/min"))
            else {
                print("mini is not found")
                return
            }
            
            DispatchQueue.main.async {
                self.heartRate = "\(mim)~\(max)"
            }
        }
        
        self.myHealthStore.execute(staticsQuery)
    }
    
    private func queryOxigenData(type:HKQuantityType,predicate:NSPredicate, options:HKStatisticsOptions){
        let staticsQuery = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: options) { (query, result, error) in
            if let e = error {
                print("Error:\(e.localizedDescription)")
                return
            }
            
            guard let max = result?.maximumQuantity()
            else {
                print("max is not found")
                self.oxigenSaturation =  "-"
                return
            }
            guard let mim = result?.minimumQuantity()
            else {
                print("mini is not found")
                return
            }
            
            DispatchQueue.main.async {
                self.oxigenSaturation = "\(mim)~\(max)"
            }
        }
        
        self.myHealthStore.execute(staticsQuery)
    }
    
    private func queryStepData(type:HKQuantityType,predicate:NSPredicate){
        let statsOptions: HKStatisticsOptions = [HKStatisticsOptions.cumulativeSum]
        
        let staticsQuery = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: statsOptions) { (query, result, error) in
            if let e = error {
                print("Error step:\(e.localizedDescription)")
                return
            }
            
            guard let count = result?.sumQuantity()
            else {
                print("count is not found")
                self.step = "-"
                return
            }
            
            if count.doubleValue(for: HKUnit.init(from: "count")) <= 1000{
                print("運動不足ですね")
                showingAlert = true
            }
            
            DispatchQueue.main.async {
                self.step = "\(count)"
            }
        }
        
        self.myHealthStore.execute(staticsQuery)
    }
    
    private func setData(){
        print("Call setData")
        // 1. データのタイプを指定
        let distanceType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        
        // 2. データを記録した日時
        let now = Date()

        let time = Calendar.current.dateComponents([.hour, .minute], from: now)
        print(time)
        let randomInt = Int.random(in:0..<59)

        let startDate = Calendar.current.date(bySettingHour: time.hour!, minute: time.minute!, second: randomInt, of: Date())!
        let endDate = Calendar.current.date(bySettingHour: time.hour!+1, minute: 0, second: 0, of: Date())!
        
        // 3. 値
        // HKQuantityは、値と単位を持っています。
        let randomDouble = Double.random(in: 40..<150)
        let distanceQuantity = HKQuantity(unit:HKUnit(from: "count/min"), doubleValue: randomDouble)
        
        // 4. 上記の要素を一つのデータとしてまとめる
        let sample = HKQuantitySample(
            type: distanceType,
            quantity: distanceQuantity,
            start: startDate,
            end: endDate
        )
        
        
        // 5. データを保存
        myHealthStore.save(sample) { success, error in
            if success {
                print("save success")
            } else {
                print("save failed")
                print(error)
            }
        }
    }
    
    var body: some View {
        ZStack{
            Color.clear
                .edgesIgnoringSafeArea(.all)
            VStack{
                Text("\(getDate())")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom,10)
                
                ZStack{
                    Color(red: 242/255, green: 242/255, blue: 242/255, opacity: 1)
                        .frame(width: 300, height: 120)
                        .cornerRadius(20)
                    VStack{
                        Text(stepTitle)
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            .fontWeight(.bold)
                        
                        Text(step)
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            .multilineTextAlignment(.leading)
                            .padding(.top, 5.0)
                    }
                }
                .padding(.top,0)
                
                ZStack{
                    Color(red: 242/255, green: 242/255, blue: 242/255, opacity: 1)
                        .frame(width: 300, height: 120)
                        .cornerRadius(20)
                    VStack{
                        Text(heartRateTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        Text(heartRate)
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            .multilineTextAlignment(.leading)
                            .padding(.top, 5.0)
                    }
                }
                .padding(.top,30)
                
                ZStack{
                    Color(red: 242/255, green: 242/255, blue: 242/255, opacity: 1)
                        .frame(width: 300, height: 120)
                        .cornerRadius(20)
                    
                    VStack{
                        Text(oxigenSaturationTitle)
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                        Text(oxigenSaturation)
                            .multilineTextAlignment(.leading)
                            .padding(.top, 5.0)
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    }
                }
                .padding(.top,30)
                
                Spacer()
                    .frame(width: 0.0, height: 30.0)
                HStack{
                    Button(action: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/{}/*@END_MENU_TOKEN@*/) {
                        Text(msg)
                            .font(.largeTitle)
                            .fontWeight(.regular)
                            .padding(.all)
                            .frame(width: 300.0, height: 80.0)
                            .onTapGesture {
                                self.readHeartRateData()
                            }
                    }
                    .alert(isPresented: $showingAlert) {            Alert(title: Text("運動不足です"),
                                                                          message: Text("1日1000歩を目標に歩きましょう"))
                    }
                    .accentColor(Color.white)
                    .background(Color.blue)
                    .cornerRadius(20)
                }
                
                HStack{
                    Button(action: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/{}/*@END_MENU_TOKEN@*/) {
                        Text("データ投入")
                            .font(.largeTitle)
                            .fontWeight(.regular)
                            .padding(.all)
                            .frame(width: 300.0, height: 80.0)
                            .onTapGesture {
                                self.setData()
                            }
                    }
                    .accentColor(Color.white)
                    .background(Color.green)
                    .cornerRadius(20)
                    .padding(.top,30)
                }
            }
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
