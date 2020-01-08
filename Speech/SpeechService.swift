import AVFoundation

enum VoiceType: String {
    case undefined
    case female = "en-GB-Wavenet-A"
    case male = "en-GB-Wavenet-B"
}

let ttsAPIUrl = "https://texttospeech.googleapis.com/v1beta1/text:synthesize"
let APIKey = "AIzaSyDYl9FJoFbjV2d7661n67Orek6kPxGmslo"

class SpeechService: NSObject, AVAudioPlayerDelegate {

    static let shared = SpeechService()
    
    static let rewards = ["Good job!", "Well done!", "Keep up the good work!", "Perfect!", "You're rocking it!", "Keep it up!"]
    static let completions = ["Good job!", "Well done!", "Perfect"]
    static let positives = ["Good", "Nice", "Great"]
    static let neutrals = ["Okay", "Alright"]
    static let improvements = ["Much Better!", "That's more like it!"]
    static let failures = ["Unlucky, you failed.", "Sorry, you failed.", "Bad luck, you failed.", "Not quite."]
    static let recoveries = ["Good recovery.", "Well recovered.", "That's better."]
    static let tooFastStatements = ["Move a bit slower", "Not so fast", "You're moving too fast", "Slow down a bit"]
    
    var isSpeechEnabled : Bool {
        get { return speechEnabled }
    }
    
    var isBusy : Bool {
        get { return self.busy }
    }
    
    private var speechEnabled : Bool
    
    private(set) var busy: Bool = false
    
    private var player: AVAudioPlayer?
    private var completionHandler: (() -> Void)?
    
    init(speechEnabled : Bool = true) {
        self.speechEnabled = speechEnabled
    }
    
    func enableSpeech() {
        speechEnabled = true
    }
    
    func disableSpeech() {
        speechEnabled = false
    }
    
    func speak(text: String) {
        speak(text: text) {}
    }
    
    func speakRandomReward(completion: @escaping () -> Void) {
        speak(text: SpeechService.rewards.randomElement()!, completion: completion)
    }
    
    func speakRandomTooFast(completion: @escaping () -> Void) {
        speak(text: SpeechService.tooFastStatements.randomElement()!, completion: completion)
    }
    
    func speakWithRandomCompletionPrefix(text: String, completion: @escaping () -> Void) {
        speak(text: SpeechService.completions.randomElement()! + ", " + text, completion: completion)
    }
    
    func speakWithRandomPositivePrefix(text : String, completion: @escaping () -> Void) {
        speak(text: SpeechService.positives.randomElement()! + ", " + text, completion: completion)
    }
    
    func speakWithRandomNeutralPrefix(text : String, completion: @escaping () -> Void) {
        speak(text: SpeechService.neutrals.randomElement()! + ", " + text, completion: completion)
    }
    
    func speakWithRandomNegativePrefix(text: String, completion: @escaping () -> Void) {
        speak(text: SpeechService.failures.randomElement()! + ", " + text, completion: completion)
    }
    
    func speakRandomImprovement(completion: @escaping () -> Void) {
        speak(text: SpeechService.improvements.randomElement()!, completion: completion)
    }
    
    func speakRandomRecovery(completion: @escaping () -> Void) {
        speak(text: SpeechService.recoveries.randomElement()!, completion: completion)
    }
    
    func speak(text: String, voiceType: VoiceType = .female, completion: @escaping () -> Void) {
        if text == "" {
            completion()
            return
        }
        
        if !self.speechEnabled {
            completion()
            return
        }
        
        if self.busy {
            cutOffSpeech()
        }
        
        print("Speaking: '\(text)'")
        
        self.busy = true
        
        DispatchQueue.global(qos: .background).async {
            let postData = self.buildPostData(text: text, voiceType: voiceType)
            let headers = ["X-Goog-Api-Key": APIKey, "Content-Type": "application/json; charset=utf-8"]
            let response = self.makePOSTRequest(url: ttsAPIUrl, postData: postData, headers: headers)

            // Get the `audioContent` (as a base64 encoded string) from the response.
            guard let audioContent = response["audioContent"] as? String else {
                print("Invalid response: \(response)")
                self.busy = false
                DispatchQueue.main.async {
                    completion()
                }
                return
            }
            
            // Decode the base64 string into a Data object
            guard let audioData = Data(base64Encoded: audioContent) else {
                self.busy = false
                DispatchQueue.main.async {
                    completion()
                }
                return
            }
            
            DispatchQueue.main.async {
                self.completionHandler = completion
                self.player = try! AVAudioPlayer(data: audioData)
                self.player?.delegate = self
                self.player!.play()
            }
        }
    }
    
    // Returns false if nothing is currently being said; true if the speech was cut off
    @discardableResult
    func cutOffSpeech() -> Bool {
        print("cut")
        if !self.busy {
            return false
        }
        self.player?.stop()
        if let completion = completionHandler {
            completion()
        }
        return true
    }
    
    private func buildPostData(text: String, voiceType: VoiceType) -> Data {
        
        var voiceParams: [String: Any] = [
            "languageCode": "en-GB"
        ]
        
        if voiceType != .undefined {
            voiceParams["name"] = voiceType.rawValue
        }
        
        let params: [String: Any] = [
            "input": [
                "text": text
            ],
            "voice": voiceParams,
            "audioConfig": [
                "pitch": -1.2,
                "speakingRate": 1,
                "volumeGainDb": 10.0,
                "audioEncoding": "LINEAR16"
            ]
        ]

        // Convert the Dictionary to Data
        let data = try! JSONSerialization.data(withJSONObject: params)
        return data
    }
    
    // Just a function that makes a POST request.
    private func makePOSTRequest(url: String, postData: Data, headers: [String: String] = [:]) -> [String: AnyObject] {
        var dict: [String: AnyObject] = [:]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = postData

        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        // Using semaphore to make request synchronous
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                dict = json
            }
            
            semaphore.signal()
        }
        
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return dict
    }
    
    // Implement AVAudioPlayerDelegate "did finish" callback to cleanup and notify listener of completion.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player?.delegate = nil
        self.player = nil
        self.busy = false
        
        self.completionHandler!()
        self.completionHandler = nil
    }
}
