import UIKit
import PlaygroundSupport

struct Question {
    let questionText: String
    let generalResponse: String
    var possibleAnswers: [Answer] = []

    init(from dictionary: [String: Any]) {
        questionText = dictionary["Question"] as? String ?? ""
        generalResponse = dictionary["GeneralResponse"] as? String ?? ""

        if let answers = dictionary["PossibleAnswers"] as? [[String: Any]] {
            for answer in answers {
                possibleAnswers.append(Answer(from: answer))
            }
        }
    }
}

struct Answer {
    let answerText: String
    let specificResponse: String
    let resultingChange: Float

    init(from dictionary: [String: Any]) {
        answerText = dictionary["Answer"] as? String ?? ""
        specificResponse = dictionary["SpecificResponse"] as? String ?? ""
        resultingChange = dictionary["Change"] as? Float ?? 0
    }
}

class GameViewController: UIViewController {

    var questionLabel: UILabel!
    var yesButton: UIButton!
    var noButton: UIButton!
    var answerLabel: UILabel!
    var nextQuestionButton: UIButton!
    var pawnHoldingView: UIView!
    var middleLineView: UIView!

    var notInterestedPersonViews = [CAShapeLayer]()
    var interestedPersonViews = [CAShapeLayer]()

    var questionLabelShowingLeadingConstraint: NSLayoutConstraint!
    var questionLabelShowingTrailingConstraint: NSLayoutConstraint!
    var questionLabelHiddenLeadingConstraint: NSLayoutConstraint!
    var questionLabelHiddenTrailingConstraint: NSLayoutConstraint!
    var questionLabelWidthConstraint: NSLayoutConstraint!
    var answerLabelShowingLeadingConstraint: NSLayoutConstraint!
    var answerLabelShowingTrailingConstraint: NSLayoutConstraint!
    var answerLabelHiddenLeadingConstraint: NSLayoutConstraint!
    var answerLabelHiddenTrailingConstraint: NSLayoutConstraint!

    var showQuestionConstraints = [NSLayoutConstraint]()
    var showAnswerConstraints = [NSLayoutConstraint]()

    let marginSpacing: CGFloat = 40
    let personSize = CGSize(width: 30, height: 30)

    var currentQuestion = 0

    let startingNumberOfInterestedPeople = 20
    let startingNumberOfNotInterestedPeople = 20

    let pawnScaling: CGFloat = 0.125

    let brighterGreen = UIColor(red:0, green:0.78, blue:0, alpha:1) // #00C700
    let dullerGreen = UIColor(red:0.647, green:0.804, blue:0.645, alpha:1)  // #A5CDA4

    var questions = [Question]()

    var questionText: String {
        return "Question \(currentQuestion + 1)"
    }

    var answerText: String {
         return "Answer \(currentQuestion + 1)"
    }

    override func viewDidLoad() {

        view.backgroundColor = .white

        questionLabel = UILabel()
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.text = questionText
        questionLabel.textAlignment = .center
        

        yesButton = UIButton(type: .system)
        yesButton.translatesAutoresizingMaskIntoConstraints = false
        yesButton.setTitle("Yes", for: .normal)
        yesButton.addTarget(self, action: #selector(yesPressed), for: .touchUpInside)

        noButton = UIButton(type: .system)
        noButton.translatesAutoresizingMaskIntoConstraints = false
        noButton.setTitle("No", for: .normal)
        noButton.addTarget(self, action: #selector(noPressed), for: .touchUpInside)

        answerLabel = UILabel()
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        answerLabel.text = answerText
        answerLabel.numberOfLines = 0
        answerLabel.lineBreakMode = .byWordWrapping
        answerLabel.textAlignment = .center
        answerLabel.sizeToFit()

        nextQuestionButton = UIButton(type: .system)
        nextQuestionButton.translatesAutoresizingMaskIntoConstraints = false
        nextQuestionButton.setTitle("Next Question", for: .normal)
        nextQuestionButton.addTarget(self, action: #selector(presentNextQuestion), for: .touchUpInside)
        nextQuestionButton.alpha = 0
        nextQuestionButton.isHidden = true

        pawnHoldingView = UIView()
        pawnHoldingView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(questionLabel)
        view.addSubview(yesButton)
        view.addSubview(noButton)
        view.addSubview(answerLabel)
        view.addSubview(nextQuestionButton)
        view.addSubview(pawnHoldingView)

        let margins = view.layoutMarginsGuide

        questionLabelShowingLeadingConstraint = questionLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: marginSpacing)
        questionLabelShowingTrailingConstraint = margins.trailingAnchor.constraint(equalTo: questionLabel.trailingAnchor, constant: marginSpacing)
        questionLabelHiddenLeadingConstraint = questionLabel.leadingAnchor.constraint(equalTo: view.trailingAnchor)
        questionLabelHiddenTrailingConstraint = questionLabel.trailingAnchor.constraint(equalTo: view.leadingAnchor)

        questionLabelShowingLeadingConstraint.isActive = true
        questionLabelShowingTrailingConstraint.isActive = true

        questionLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: marginSpacing).isActive = true


        margins.bottomAnchor.constraint(equalTo: yesButton.bottomAnchor, constant: marginSpacing).isActive = true
        yesButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: marginSpacing).isActive = true

        yesButton.firstBaselineAnchor.constraint(equalTo: noButton.firstBaselineAnchor).isActive = true
        margins.trailingAnchor.constraint(equalTo: noButton.trailingAnchor, constant: marginSpacing).isActive = true

        answerLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: marginSpacing).isActive = true

        answerLabelHiddenLeadingConstraint = answerLabel.leadingAnchor.constraint(equalTo: view.trailingAnchor)
        answerLabelHiddenLeadingConstraint.isActive = true

        answerLabelShowingLeadingConstraint = answerLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: marginSpacing)
        answerLabelShowingTrailingConstraint = margins.trailingAnchor.constraint(equalTo: answerLabel.trailingAnchor, constant: marginSpacing)
        answerLabelHiddenTrailingConstraint = answerLabel.trailingAnchor.constraint(equalTo: view.leadingAnchor)

        nextQuestionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        margins.bottomAnchor.constraint(equalTo: nextQuestionButton.bottomAnchor, constant: marginSpacing).isActive = true

        pawnHoldingView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: marginSpacing).isActive = true
        margins.trailingAnchor.constraint(equalTo: pawnHoldingView.trailingAnchor, constant: marginSpacing).isActive = true
        pawnHoldingView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: marginSpacing).isActive = true
        yesButton.topAnchor.constraint(equalTo: pawnHoldingView.bottomAnchor, constant: marginSpacing).isActive = true

        middleLineView = UIView()
        middleLineView.translatesAutoresizingMaskIntoConstraints = false
        middleLineView.backgroundColor = .lightGray

        pawnHoldingView.addSubview(middleLineView)

        middleLineView.topAnchor.constraint(equalTo: pawnHoldingView.topAnchor).isActive = true
        pawnHoldingView.bottomAnchor.constraint(equalTo: middleLineView.bottomAnchor).isActive = true
        middleLineView.centerXAnchor.constraint(equalTo: pawnHoldingView.centerXAnchor).isActive = true
        middleLineView.widthAnchor.constraint(equalToConstant: 2).isActive = true

        if let filePath = Bundle.main.path(forResource: "Questions.plist", ofType: nil),
            let questionsArray = NSArray(contentsOfFile: filePath) {
            for question in questionsArray {
                if let question = question as? [String: Any] {
                    self.questions.append(Question(from: question))
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for _ in 0...startingNumberOfInterestedPeople {
            let person = makePersonLayer(filledWith: brighterGreen)
            pawnHoldingView.layer.addSublayer(person)

            let randomX = pickRandomX(forPersonSized: person.frame.size, withInterest: true)
            let randomY = pickRandomY(forPersonSized: person.frame.size)
            person.frame.origin = CGPoint(x: randomX, y: randomY)

            interestedPersonViews.append(person)
        }

        for _ in 0...startingNumberOfNotInterestedPeople {

            let person = makePersonLayer(filledWith: dullerGreen)

            pawnHoldingView.layer.addSublayer(person)
            let randomX = pickRandomX(forPersonSized: person.frame.size, withInterest: false)
            let randomY = pickRandomY(forPersonSized: person.frame.size)
            person.frame.origin = CGPoint(x: randomX, y: randomY)

            notInterestedPersonViews.append(person)
        }

        questionLabel.widthAnchor.constraint(equalToConstant: questionLabel.frame.width).isActive = true
        answerLabel.widthAnchor.constraint(equalToConstant: questionLabel.frame.width).isActive = true
    }

    let spacing: CGFloat = 5
    func pickRandomX(forPersonSized size: CGSize, withInterest: Bool) -> CGFloat {

        let halfView = pawnHoldingView.frame.width / 2
        let adjustHalfForWidth = halfView - size.width
        let maxX = adjustHalfForWidth - (2 * spacing)
        let randomX = arc4random_uniform(UInt32(maxX))
        var offsetRandomX = CGFloat(randomX) + spacing

        if withInterest {
            offsetRandomX += halfView
        }

        return offsetRandomX
    }

    func pickRandomY(forPersonSized size: CGSize) -> CGFloat {
        let viewHeight = pawnHoldingView.frame.height
        let adjustedForPawnHeight = viewHeight - size.height
        let maxY = adjustedForPawnHeight - (2 * spacing)
        let randomY = arc4random_uniform(UInt32(maxY))
        let offsetRandomY = CGFloat(randomY) + spacing

        return offsetRandomY
    }

    func yesPressed() {
        presentAnswer(forSupport: true)
    }

    func noPressed() {
        presentAnswer(forSupport: false)
    }

    func presentAnswer(forSupport supports: Bool) {
        self.answerLabel.text = self.answerText

        self.answerLabelShowingTrailingConstraint.isActive = false
        self.answerLabelHiddenTrailingConstraint.isActive = false
        self.answerLabelHiddenLeadingConstraint.isActive = true
        self.view.layoutIfNeeded()

        self.questionLabelShowingLeadingConstraint.isActive = true
        self.questionLabelShowingLeadingConstraint.isActive = false
        self.questionLabelHiddenTrailingConstraint.isActive = true
        self.answerLabelShowingLeadingConstraint.isActive = true

        self.moveViews(forSupport: supports)

        UIView.animate(withDuration: 1.1, animations: {
            self.yesButton.alpha = 0
            self.noButton.alpha = 0

            self.view.layoutIfNeeded()
        }, completion: { success in
            self.yesButton.isHidden = true
            self.noButton.isHidden = true



            UIView.animate(withDuration: 1.1, animations: {
                self.view.layoutIfNeeded()

                self.nextQuestionButton.isHidden = false
                self.nextQuestionButton.alpha = 1

            })
        })
    }

    func moveViews(forSupport: Bool) {
        var numberOfViewsToMove = 5
        let numberOfJumps: CGFloat = 3

        if forSupport {
            if !notInterestedPersonViews.isEmpty {
                if notInterestedPersonViews.count < numberOfViewsToMove {
                    numberOfViewsToMove = notInterestedPersonViews.count - 1
                }

                for _ in 0..<numberOfViewsToMove {
                    let personToMove = notInterestedPersonViews.removeFirst()

                    let startingPoint = personToMove.frame.origin
                    let destinationX = pickRandomX(forPersonSized: personToMove.bounds.size, withInterest: true) + (personToMove.bounds.size.width / 2)

                    let jumpWidth = (destinationX - startingPoint.x) / numberOfJumps
                    let jumpHeightAdjustmentRatio: CGFloat = 0.3
                    let jumpHeightAdjustment = jumpWidth * jumpHeightAdjustmentRatio
                    let controlPointYRatio: CGFloat = 0.4
                    let controlPointY: CGFloat = -(jumpWidth * controlPointYRatio)

                    let path = UIBezierPath()
                    path.move(to: startingPoint)

                    var lastPoint = startingPoint
                    var currentPoint = startingPoint

                    for _ in 1...Int(numberOfJumps) {
                        currentPoint.x += jumpWidth
                        path.addCurve(to: currentPoint, controlPoint1: CGPoint(x: lastPoint.x + jumpHeightAdjustment, y: lastPoint.y + controlPointY), controlPoint2: CGPoint(x: currentPoint.x - jumpHeightAdjustment, y: currentPoint.y + controlPointY))
                        lastPoint = currentPoint
                    }

                    let anim = CAKeyframeAnimation(keyPath: "position")
                    anim.path = path.cgPath
                    anim.duration = 1.1

                    personToMove.position = CGPoint(x: destinationX, y: startingPoint.y)
                    personToMove.add(anim, forKey: "animate position along path")

                    let colorsAnimation = CABasicAnimation(keyPath: "fillColor")
                    colorsAnimation.fromValue = personToMove.fillColor
                    colorsAnimation.duration = 1.1

                    personToMove.fillColor = brighterGreen.cgColor
                    personToMove.add(colorsAnimation, forKey: "fillColor")

                    self.interestedPersonViews.append(personToMove)
                }
            }
        } else {
            if !interestedPersonViews.isEmpty {
                if interestedPersonViews.count < numberOfViewsToMove {
                    numberOfViewsToMove = interestedPersonViews.count - 1
                }

                for _ in 0..<numberOfViewsToMove {
                    let personToMove = interestedPersonViews.removeFirst()

                    let startingPoint = personToMove.frame.origin
                    let destinationX = pickRandomX(forPersonSized: personToMove.bounds.size, withInterest: false) + (personToMove.bounds.size.width / 2)

                    let rotation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
                    rotation.values = [0, -0.5, -0.5, 0]
                    rotation.duration = 1.8
                    rotation.keyTimes = [0, 0.33, 0.9, 1]

                    personToMove.add(rotation, forKey: "rotation")

                    let movement = CABasicAnimation(keyPath: "position")
                    movement.fromValue = personToMove.frame.origin
                    movement.duration = 1.5
                    personToMove.position = CGPoint(x: destinationX, y: startingPoint.y)
                    personToMove.add(movement, forKey: "movement")

                    let colorsAnimation = CABasicAnimation(keyPath: "fillColor")
                    colorsAnimation.fromValue = personToMove.fillColor
                    colorsAnimation.duration = 1.5

                    personToMove.fillColor = dullerGreen.cgColor
                    personToMove.add(colorsAnimation, forKey: "fillColor")
                }
            }
        }
    }


    func presentNextQuestion() {
        currentQuestion += 1
        self.questionLabel.text = self.questionText

        questionLabelShowingTrailingConstraint.isActive = false
        questionLabelHiddenTrailingConstraint.isActive = false
        questionLabelHiddenLeadingConstraint.isActive = true
        self.view.layoutIfNeeded()

        self.answerLabelShowingLeadingConstraint.isActive = true
        self.answerLabelShowingLeadingConstraint.isActive = false
        self.answerLabelHiddenTrailingConstraint.isActive = true
        self.questionLabelShowingLeadingConstraint.isActive = true

        UIView.animate(withDuration: 2, animations: {
            self.view.layoutIfNeeded()

        }, completion: { success in
            self.nextQuestionButton.isHidden = true

            UIView.animate(withDuration: 0.7, animations: {
                self.yesButton.isHidden = false
                self.noButton.isHidden = false
                self.yesButton.alpha = 1
                self.noButton.alpha = 1
            })
        })
    }

    func makePersonLayer(filledWith fillColor: UIColor) -> CAShapeLayer {

        let rootLayer = CAShapeLayer() // Generated by Svgsus

            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0.962, y: 109.018))
            path.addLine(to: CGPoint(x: 0.962, y: 50.089))
            path.addCurve(to: CGPoint(x: 10.575, y: 40.268), controlPoint1: CGPoint(x: 0.962, y: 44.688), controlPoint2: CGPoint(x: 5.287999999999999, y: 40.268))
            path.addLine(to: CGPoint(x: 12.981, y: 40.268))
            path.addCurve(to: CGPoint(x: 3.846, y: 22.589000000000002), controlPoint1: CGPoint(x: 7.692, y: 36.339), controlPoint2: CGPoint(x: 3.846, y: 29.955))
            path.addCurve(to: CGPoint(x: 25, y: 0.982), controlPoint1: CGPoint(x: 3.846, y: 10.804), controlPoint2: CGPoint(x: 13.462, y: 0.982))
            path.addCurve(to: CGPoint(x: 46.153999999999996, y: 22.589), controlPoint1: CGPoint(x: 36.538, y: 0.982), controlPoint2: CGPoint(x: 46.153999999999996, y: 10.803999999999998))
            path.addCurve(to: CGPoint(x: 37.019, y: 40.268), controlPoint1: CGPoint(x: 46.153999999999996, y: 29.955), controlPoint2: CGPoint(x: 42.30799999999999, y: 36.339))
            path.addLine(to: CGPoint(x: 39.425, y: 40.268))
            path.addCurve(to: CGPoint(x: 49.038, y: 50.089), controlPoint1: CGPoint(x: 44.711999999999996, y: 40.268), controlPoint2: CGPoint(x: 49.038, y: 44.688))
            path.addLine(to: CGPoint(x: 49.038, y: 109.018))
            path.addLine(to: CGPoint(x: 0.962, y: 109.018))
            path.close()
        rootLayer.path = path.cgPath

        rootLayer.fillColor = fillColor.cgColor
        rootLayer.strokeColor = UIColor.black.cgColor
        rootLayer.lineWidth = 2

        let xRatio = pawnScaling * pawnHoldingView.frame.width / 55
        let yRatio = pawnScaling * pawnHoldingView.frame.height / 110
        rootLayer.transform = CATransform3DMakeScale(xRatio, yRatio, 1)
        rootLayer.bounds = CGRect(origin: .zero, size: CGSize(width: 55, height: 110))
        return rootLayer
    }
}

PlaygroundPage.current.liveView = GameViewController()

