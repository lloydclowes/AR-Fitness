import ARKit
import Compression

class RecordingSession {
    
    var isRecording = false
    var stateHistory = [TimedState]()
    var lastPoll : Date
    
    init() {
        self.lastPoll = Date()
    }
    
    func startRecording() {
        lastPoll = Date();
        stateHistory = []
        isRecording = true
    }

    func stopRecording() {
        isRecording = false
    }

    func poll(_ state : ActivityState) {
        if !isRecording {
            return
        }
        
        let currentTime = Date()
        let timeDiff : Double = 100 / 1000;
        
        if abs(currentTime.distance(to: lastPoll)) < timeDiff {
            return
        }
        
        lastPoll = currentTime
        
        stateHistory.append(TimedState(currentTime, ActivityState(copyOf: state)))
        //stateHistory.history.append(thing)
    }

    func upload() {
        let url = URL(string: "https://6b32ef8b.ngrok.io/record")!
        
        var request : URLRequest = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Accept")
        
        guard let data = JSONDataExporter.encodeJSON(from: TimedStateHistory(history: stateHistory)) else {
            return
        }
        
        request.httpBody = data.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
        
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
            print("uploaded the history")
        }
        
        task.resume()
    }

}
