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

    func poll(_ augmentedState : ActivityState, _ naturalState : ActivityState) {
        if !isRecording {
            return
        }
        
        let currentTime = Date()
        let timeDiff : Double = 100 / 1000;
        
        if abs(currentTime.distance(to: lastPoll)) < timeDiff {
            return
        }
        
        lastPoll = currentTime
        
        stateHistory.append(TimedState(currentTime, augmentedState, naturalState))
        //stateHistory.history.append(thing)
    }

    func upload() {
        let url = URL(string: "https://b190e8cd.ngrok.io/record")!
        
        var request : URLRequest = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Accept")
        
        guard let data = JSONDataExporter.encodeJSON(from: StateHistory(history: stateHistory)) else {
            return
        }
        
        request.httpBody = data.data(using: .utf8)
        
        /*
        
        for some reason the output does not contain a valid ZLIB header ?!?
         
        var dataBuffer = Array(data.utf8)
        
        let compBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
        let compressedSize = compression_encode_buffer(compBuffer, data.count, &dataBuffer, data.count, nil, COMPRESSION_ZLIB)
        
        if compressedSize == 0 {
            fatalError("Encoding failed.")
        }
        
        request.httpBody = NSData(bytesNoCopy: compBuffer, length: compressedSize) as Data
        
        print("uploading:")
        print(data.count)
         */
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
        
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
            print("completed the thing ?? ?? ")
        }
        
        task.resume()
    }

}
