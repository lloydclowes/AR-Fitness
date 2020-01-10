import AVFoundation

protocol Speaker {    
    func speak(text : String)
    func speak(text : String, completion : @escaping () -> Void)

    func speakRandomReward(completion: @escaping () -> Void)
    func speakRandomTooFast(completion: @escaping () -> Void)
    
    func speakWithRandomCompletionPrefix(text: String, completion: @escaping () -> Void)
    func speakWithRandomPositivePrefix(text : String, completion: @escaping () -> Void)
    func speakWithRandomNeutralPrefix(text : String, completion: @escaping () -> Void)
    func speakWithRandomNegativePrefix(text: String, completion: @escaping () -> Void)
    
    func speakRandomImprovement(completion: @escaping () -> Void)
    func speakRandomRecovery(completion: @escaping () -> Void)
}

