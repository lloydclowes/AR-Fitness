import SwiftUI
import RealityKit
import ARKit
import Combine

struct ExerciseInstructionsView: View {
    var exercise : Exercise
    
    var body: some View {
        return ExerciseInstructionControllerContainer(exercise: exercise)
                .edgesIgnoringSafeArea(.bottom)
                .navigationBarTitle("\(exercise.name) guide")
    }
}

struct ExerciseInstructionControllerContainer: UIViewControllerRepresentable {
    var exercise : Exercise
    
    func makeCoordinator() -> Coordinator {}
    
    func makeUIViewController(context: Context) -> UIViewController {
        switch self.exercise.name {
        case "Lateral Raises":
            return RepCountController(exercise: exercise, instructions: true, countFirstRep: true)
        case "Lateral Raise + Hold":
            return HoldingController(exercise: exercise, instructions: true)
        case "Squats":
            return RepCountController(exercise: exercise, instructions: true)
        case "Squat + Hold":
            return HoldingController(exercise: exercise, instructions: true)
        case "Jumping Jacks":
            return RepCountController(exercise: exercise, instructions: true)
        default:
            print("ERROR: No view controller found for the given exercise")
            return RepCountController(exercise: exercise, instructions: true)
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct ExerciseInstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseInstructionsView(
            exercise: Exercise(id: -1,
                                name: "Name",
                                type: .rep,
                                intensity: .low,
                                muscleGroup: .wholeBody,
                                equipment: ["equipment"],
                                className: "",
                                duration: "0:00",
                                startMessage: "",
                                startState: TargetState("START"),
                                states: [TargetState("None")])
        )
    }
}
