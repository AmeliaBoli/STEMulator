import UIKit

public struct Question {
    public let questionText: String
    public let generalResponse: String
    public var possibleAnswers: [Answer] = []

    public init(from dictionary: [String: Any]) {
        questionText = dictionary["Question"] as? String ?? ""
        generalResponse = dictionary["GeneralResponse"] as? String ?? ""

        if let answers = dictionary["PossibleAnswers"] as? [[String: Any]] {
            for answer in answers {
                possibleAnswers.append(Answer(from: answer))
            }
        }
    }

    public mutating func shufflePossibleAnswers() {
        var randomNumberBound = possibleAnswers.count

        for _ in 0..<possibleAnswers.count {
            let randomNumber = arc4random_uniform(UInt32(randomNumberBound))
            let answerToShuffle = possibleAnswers.remove(at: Int(randomNumber))
            possibleAnswers.append(answerToShuffle)
            randomNumberBound -= 1
        }
    }
}

public struct Answer {
    public let answerText: String
    public let specificResponse: String
    public let resultingChange: Float

    init(from dictionary: [String: Any]) {
        answerText = dictionary["Answer"] as? String ?? ""
        specificResponse = dictionary["SpecificResponse"] as? String ?? ""
        resultingChange = dictionary["Change"] as? Float ?? 0
    }
}

public class LayerState {
    public let layer: CAShapeLayer
    public let position: CGPoint
    public let wasNotInterested: Bool

    public init(layer: CAShapeLayer, position: CGPoint, wasNotInterested: Bool) {
        self.layer = layer
        self.position = position
        self.wasNotInterested = wasNotInterested
    }
}
