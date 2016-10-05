import UIKit
import CoreMotion

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var newGoalField: UITextField!
    
    @IBOutlet weak var hitGoalLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var yesterdayLabel: UILabel!
    @IBOutlet weak var todayLabel: UILabel!
    //MARK: class variables
    let activityManager = CMMotionActivityManager()
    let motionQueue = OperationQueue()
    let goalToolbarSelect: UIToolbar = UIToolbar()
    let pedometer = CMPedometer()
    let motion = CMMotionManager()
    
    lazy var yesterdaySteps: Float = {return 0.0}()
    lazy var todaySteps: Float = {return 0.0}()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateYesterdaySteps()
        self.startActivityMonitoring()
        self.startPedometerMonitoring()
        
        if UserDefaults.standard.object(forKey: "stepGoal") == nil {
            UserDefaults.standard.set(100, forKey: "stepGoal")
            goalLabel.text = "Step Goal: \(100)"
        } else {
            let number = UserDefaults.standard.integer(forKey: "stepGoal")
            goalLabel.text = "Step Goal: \(number)"
        }
        
        self.newGoalField.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        goalToolbarSelect.barStyle = UIBarStyle.black
        goalToolbarSelect.tintColor = UIColor.white
        goalToolbarSelect.items=[
            UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.dismissKeyboard)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Set", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.returnSetGoal))
        ]
        goalToolbarSelect.sizeToFit()
        self.newGoalField.inputAccessoryView = goalToolbarSelect
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func returnSetGoal() {
        setGoal(self)
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.newGoalField {
            setGoal(self)
            self.view.endEditing(true)
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func setGoal(_ sender: AnyObject) {
        let goal = self.newGoalField.text!
        let goalNumber = Int(goal)
        UserDefaults.standard.set(goalNumber!, forKey: "stepGoal")
        goalLabel.text = "Step Goal: \(goalNumber!)"
        self.checkHitGoal(goal: goalNumber!)
        
    }
    
    // MARK: Activity Functions
    func startActivityMonitoring(){
        if CMMotionActivityManager.isActivityAvailable(){
            self.activityManager.startActivityUpdates(to: motionQueue, withHandler: self.handleActivity)
        }
        
    }
    
    func handleActivity(activity:CMMotionActivity?)->Void{
        // unwrap the activity and disp
        if let unwrappedActivity = activity {
            var activityString = "Status: "
            switch true{
            case unwrappedActivity.walking:
                activityString.append("Walking")
            case unwrappedActivity.cycling:
                activityString.append("Cycling")
            case unwrappedActivity.running:
                activityString.append("Running")
            case unwrappedActivity.automotive:
                activityString.append("Driving")
            case (unwrappedActivity.stationary && !(unwrappedActivity.automotive)):
                activityString.append("Stationary")
            default:
                activityString.append("Unknown")
            }
            DispatchQueue.main.async(){
                self.statusLabel.text = activityString
            }
        }
    }
    
    func startPedometerMonitoring(){
        if CMPedometer.isStepCountingAvailable(){
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            pedometer.startUpdates(from: today, withHandler: self.handlePedometer)
        }
    }
    
    func checkHitGoal(goal:Int){
        self.hitGoalLabel.text = "Hit Goal: " + (goal <= Int(self.todaySteps) ? "Yes" : "No")
    }
    func handlePedometer(pedData:CMPedometerData?, error:Error?){
        if let steps = pedData?.numberOfSteps {
            self.todaySteps = steps.floatValue
            DispatchQueue.main.async(){
                self.todayLabel.text = "\(self.todaySteps)"
                let goal = UserDefaults.standard.integer(forKey: "stepGoal")
                print("\(self.todaySteps) - \(Float(goal))")
                self.checkHitGoal(goal: goal)
                
            }
            
        }
    }
    
    func handleYesterdayPedometer(pedData:CMPedometerData?, error:Error?){
        if let steps = pedData?.numberOfSteps {
            self.yesterdaySteps = steps.floatValue
        }
        DispatchQueue.main.async(){
            self.yesterdayLabel.text = "\(self.yesterdaySteps)"
        }
    }
    
    func updateYesterdaySteps(){
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: Date()))
        let today = calendar.startOfDay(for: Date())
        self.pedometer.queryPedometerData(from: yesterday!, to: today, withHandler: self.handleYesterdayPedometer)
    }
    
    
}

