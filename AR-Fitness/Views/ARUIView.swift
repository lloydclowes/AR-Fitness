import SwiftUI
import RealityKit
import ARKit
import Combine

struct ARUIView : View {
    
    var exercise: Exercise
    
    init(_ exe: Exercise) {
        exercise = exe
    }
    
    var body: some View {
           return ARViewControllerContainer(exercise: exercise)
                .edgesIgnoringSafeArea(.bottom)
            .navigationBarTitle(exercise.name)
        .navigationBarItems(trailing:
            NavigationLink(destination: ExerciseInstructionsView(exercise: exercise)) {
                Text(
                "Instructions")
            }
        )
    }
}

struct ARViewControllerContainer: UIViewControllerRepresentable {
    let characterAnchor = AnchorEntity()
    var character: BodyTrackedEntity?
    var exercise: Exercise
    
    func makeCoordinator() -> Coordinator {}
    
    func makeUIViewController(context: Context) -> UIViewController {
        switch self.exercise.name {
        case "Lateral Raises":
            return RepCountController(exercise: exercise, liveFeedback: false, countFirstRep: true)
        case "Lateral Raise + Hold":
            return HoldingController(exercise: exercise, liveFeedback: true)
        case "Squat + Hold":
            return HoldingController(exercise: exercise, liveFeedback: true)
        case "Squats":
            return RepCountController(exercise: exercise, liveFeedback: false)
        case "Jumping Jacks":
            return RepCountController(exercise: exercise, liveFeedback: false)
        case "Lunges":
            return RepCountController(exercise: exercise, liveFeedback: false)
        default:
            print("ERROR: No view controller found for the given exercise")
            return RepCountController(exercise: exercise, liveFeedback: false)
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    
    static var previews: some View {
        ARUIView(exerciseData[0])
    }
}
#endif
