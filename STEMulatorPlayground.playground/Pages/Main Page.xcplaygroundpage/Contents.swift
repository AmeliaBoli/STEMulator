import UIKit
import PlaygroundSupport

class GameViewController: UIViewController {

    var questionNumberLabel: UILabel!
    var questionLabel: UILabel!
    var choice1Button: UIButton!
    var choice2Button: UIButton!
    var choice3Button: UIButton!

    var chooseAgainButton: UIButton!
    var nextQuestionButton: UIButton!

    var pawnHoldingView: UIView!
    var middleLineView: UIView!

    var startingStackView: UIStackView!
    var mainStackView: UIStackView!
    var answerStackView: UIStackView!

    var notInterestedPersonViews = [CAShapeLayer]()
    var interestedPersonViews = [CAShapeLayer]()

    let marginSpacing: CGFloat = 40
    let pawnViewMargins: CGFloat = 5
    let personSize = CGSize(width: 55, height: 110)
    let pawnsPerWidth: CGFloat = 5
    let pawnsPerHeight: CGFloat = 6

    let startingNumberOfInterestedPeople = 20
    let startingNumberOfNotInterestedPeople = 20

    var numberOfPeople: Int {
        return startingNumberOfInterestedPeople + startingNumberOfNotInterestedPeople
    }

    var percentChange: Double {
        return Double(interestedPersonViews.count)/Double(startingNumberOfInterestedPeople) - 1
    }

    let pawnScaling: CGFloat = 0.125

    let brighterGreen = UIColor(red:0, green:0.78, blue:0, alpha:1) // #00C700
    let dullerGreen = UIColor(red:0.647, green:0.804, blue:0.645, alpha:1)  // #A5CDA4

    var questions = [Question]()
    var currentQuestionIndex = 0
    var previousState = [LayerState]()

    var isReadyForPlayAgain = false

    override func viewDidLoad() {

        view.backgroundColor = .white

        let welcomeLabel = UILabel()
        welcomeLabel.text = "Welcome to STEMulator!"
        welcomeLabel.textAlignment = .center

        let directionsLabel = UILabel ()
        directionsLabel.text = "At the top of the screen you'll see a question or scenario regarding women and STEM. Select an action at the bottom of the screen to see how it could affect the number of women in STEM."
        directionsLabel.numberOfLines = 0
        directionsLabel.lineBreakMode = .byWordWrapping

        let startButton = UIButton(type: .system)
        startButton.setTitle("Let's Start!", for: .normal)
        startButton.addTarget(self, action: #selector(startGame), for: .touchUpInside)

        startingStackView = UIStackView(arrangedSubviews: [welcomeLabel, directionsLabel, startButton])
        startingStackView.translatesAutoresizingMaskIntoConstraints = false
        startingStackView.axis = .vertical
        startingStackView.spacing = 20
        startingStackView.alignment = .fill
        startingStackView.distribution = .fillEqually

        view.addSubview(startingStackView)

        let margins = view.layoutMarginsGuide

        startingStackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 20).isActive = true
        startingStackView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 20).isActive = true
        startingStackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -20).isActive = true
        startingStackView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -20).isActive = true
    }

    func startGame() {
        setupGame()
    }

    func setupGame() {
        UIView.animate(withDuration: 0.3, animations: {
            self.startingStackView.alpha = 0
        }, completion: { success in
            self.startingStackView.removeFromSuperview()

            self.setupViews()
            self.getQuestions()
            self.setTextForQuestion()

            self.view.setNeedsLayout()
            self.addPeople()

            UIView.animate(withDuration: 0.3) {
                self.mainStackView.alpha = 1
            }
        })
    }

    func setupViews() {
        questionNumberLabel = UILabel()
        questionNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        questionNumberLabel.textAlignment = .center

        questionLabel = UILabel()
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.textAlignment = .left
        questionLabel.numberOfLines = 0
        questionLabel.lineBreakMode = .byWordWrapping

        let notInterestedLabel = UILabel()
        notInterestedLabel.text = "Not Interested"
        notInterestedLabel.textAlignment = .center

        let interestedLabel = UILabel()
        interestedLabel.text = "Interested!"
        interestedLabel.textAlignment = .center

        let pawnLabelStackView = UIStackView(arrangedSubviews: [notInterestedLabel, interestedLabel])
        pawnLabelStackView.axis = .horizontal
        pawnLabelStackView.alignment = .fill
        pawnLabelStackView.distribution = .fillEqually

        pawnHoldingView = UIView()
        pawnHoldingView.translatesAutoresizingMaskIntoConstraints = false

        answerStackView = createAnswerStackView()

        mainStackView = UIStackView(arrangedSubviews: [questionNumberLabel, questionLabel, pawnLabelStackView, pawnHoldingView, answerStackView])
        mainStackView.axis = .vertical
        mainStackView.alignment = .fill
        mainStackView.distribution = .fill
        mainStackView.spacing = 5
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.alpha = 0

        view.insertSubview(mainStackView, at: 0)

        setConstraints()

        setupMiddleLine()
    }

    func createAnswerStackView() -> UIStackView {
        choice1Button = createChoiceButton()
        choice1Button.addTarget(self, action: #selector(showAnswerForChoice1), for: .touchUpInside)

        choice2Button = createChoiceButton()
        choice2Button.addTarget(self, action: #selector(showAnswerForChoice2), for: .touchUpInside)

        choice3Button = createChoiceButton()
        choice3Button.addTarget(self, action: #selector(showAnswerForChoice3), for: .touchUpInside)

        chooseAgainButton = UIButton(type: .system)
        chooseAgainButton.translatesAutoresizingMaskIntoConstraints = false
        chooseAgainButton.setTitle("Choose Again", for: .normal)
        chooseAgainButton.addTarget(self, action: #selector(undoAnswer), for: .touchUpInside)
        chooseAgainButton.isHidden = true

        nextQuestionButton = UIButton(type: .system)
        nextQuestionButton.translatesAutoresizingMaskIntoConstraints = false
        nextQuestionButton.setTitle("Next Question", for: .normal)
        nextQuestionButton.addTarget(self, action: #selector(presentNextQuestion), for: .touchUpInside)
        nextQuestionButton.isHidden = true

        let stackView = UIStackView(arrangedSubviews: [choice1Button, choice2Button, choice3Button, chooseAgainButton, nextQuestionButton])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }

    func createChoiceButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)

        button.setTitleColor(.darkGray, for: .disabled)

        return button
    }

    func setConstraints() {
        let margins = view.layoutMarginsGuide

        mainStackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        mainStackView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 20).isActive = true
        mainStackView.rightAnchor.constraint(equalTo: margins.rightAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -20).isActive = true

        pawnHoldingView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
        questionLabel.heightAnchor.constraint(equalTo: answerStackView.heightAnchor).isActive = true

        questionNumberLabel.heightAnchor.constraint(equalToConstant: 20.5).isActive = true
    }

    func setupMiddleLine() {
        middleLineView = UIView()
        middleLineView.translatesAutoresizingMaskIntoConstraints = false
        middleLineView.backgroundColor = .lightGray

        pawnHoldingView.addSubview(middleLineView)

        middleLineView.topAnchor.constraint(equalTo: pawnHoldingView.topAnchor).isActive = true
        pawnHoldingView.bottomAnchor.constraint(equalTo: middleLineView.bottomAnchor).isActive = true
        middleLineView.centerXAnchor.constraint(equalTo: pawnHoldingView.centerXAnchor).isActive = true
        middleLineView.widthAnchor.constraint(equalToConstant: 2).isActive = true
    }

    func changeQuestionLabel(to text: String) {
        questionLabel.layer.add(createLabelFadeTransition(), forKey: "kCATTransitionFade")
        questionLabel.text = text
    }

    func setTextForQuestion() {
        questionNumberLabel.text = "Question \(currentQuestionIndex + 1)/\(questions.count)"

        let currentQuestion = questions[currentQuestionIndex]

        changeQuestionLabel(to: currentQuestion.questionText)

        let possibleAnswers = currentQuestion.possibleAnswers
        choice1Button.setTitle(possibleAnswers[0].answerText, for: .normal)
        choice2Button.setTitle(possibleAnswers[1].answerText, for: .normal)
        choice3Button.setTitle(possibleAnswers[2].answerText, for: .normal)
    }

    func addPeople() {
        for _ in 0..<startingNumberOfInterestedPeople {
            let person = makePerson(thatIsInterested: true)
            interestedPersonViews.append(person)
        }

        for _ in 0..<startingNumberOfNotInterestedPeople {
            let person = makePerson(thatIsInterested: false)
            notInterestedPersonViews.append(person)
        }
    }

    func makePerson(thatIsInterested isInterested: Bool) -> CAShapeLayer {
        let person = PersonLayer.create(filledWith: isInterested ? brighterGreen : dullerGreen)

        let xRatio = pawnHoldingView.frame.width / (personSize.width * pawnsPerWidth * 2)
        let yRatio = pawnHoldingView.frame.height / (personSize.height * pawnsPerHeight)

        let ratio = xRatio < yRatio ? xRatio : yRatio

        person.transform = CATransform3DMakeScale(ratio, ratio, 1)
        person.bounds.size = personSize
        pawnHoldingView.layer.addSublayer(person)

        let randomX = pickRandomX(forPersonSized: person.frame.size, withInterest: isInterested)
        let randomY = pickRandomY(forPersonSized: person.frame.size)
        person.frame.origin = CGPoint(x: randomX, y: randomY)

        return person
    }

    func getQuestions() {
        if let filePath = Bundle.main.path(forResource: "Questions.plist", ofType: nil),
            let questionsArray = NSArray(contentsOfFile: filePath) {
            for question in questionsArray {
                if let question = question as? [String: Any] {
                    var newQuestion = Question(from: question)
                    newQuestion.shufflePossibleAnswers()
                    self.questions.append(newQuestion)
                }
            }
        }
    }

    func pickRandomX(forPersonSized size: CGSize, withInterest: Bool) -> CGFloat {

        let halfView = pawnHoldingView.frame.width / 2
        let adjustHalfForWidth = halfView - size.width
        let maxX = adjustHalfForWidth - (2 * pawnViewMargins)
        let randomX = arc4random_uniform(UInt32(maxX))
        var offsetRandomX = CGFloat(randomX) + pawnViewMargins

        if withInterest {
            offsetRandomX += halfView
        }

        return offsetRandomX
    }

    func pickRandomY(forPersonSized size: CGSize) -> CGFloat {
        let viewHeight = pawnHoldingView.frame.height
        let adjustedForPawnHeight = viewHeight - size.height
        let maxY = adjustedForPawnHeight - (2 * pawnViewMargins)
        let randomY = arc4random_uniform(UInt32(maxY))
        let offsetRandomY = CGFloat(randomY) + pawnViewMargins

        return offsetRandomY
    }

    func showAnswerForChoice1() {
        presentAnswer(forChoice: 0)

        choice1Button.isEnabled = false

        self.choice2Button.alpha = 0
        self.choice3Button.alpha = 0

        nextQuestionButton.alpha = 1
        chooseAgainButton.alpha = 1

        if gameState() == .completed {
            nextQuestionButton.setTitle("Show Results", for: .normal)
        }

        UIView.animate(withDuration: 0.5) {
            self.choice2Button.isHidden = true
            self.choice3Button.isHidden = true
            self.nextQuestionButton.isHidden = false
            self.chooseAgainButton.isHidden = false
        }
    }

    func showAnswerForChoice2() {
        presentAnswer(forChoice: 1)

        self.choice1Button.alpha = 0
        self.choice3Button.alpha = 0

        nextQuestionButton.alpha = 1
        chooseAgainButton.alpha = 1

        if gameState() == .completed {
            nextQuestionButton.setTitle("Show Results", for: .normal)
        }

        UIView.animate(withDuration: 0.5) {
            self.choice1Button.isHidden = true
            self.choice3Button.isHidden = true
            self.nextQuestionButton.isHidden = false
            self.chooseAgainButton.isHidden = false
        }
    }

    func showAnswerForChoice3() {
        presentAnswer(forChoice: 2)

        self.choice2Button.alpha = 0
        self.choice1Button.alpha = 0

        nextQuestionButton.alpha = 1
        chooseAgainButton.alpha = 1

        if gameState() == .completed {
            nextQuestionButton.setTitle("Show Results", for: .normal)
        }

        UIView.animate(withDuration: 0.5) {
            self.choice2Button.isHidden = true
            self.choice1Button.isHidden = true
            self.nextQuestionButton.isHidden = false
            self.chooseAgainButton.isHidden = false
        }
    }

    func presentAnswer(forChoice choice: Int) {
        let currentQuestion = questions[currentQuestionIndex]
        changeQuestionLabel(to: currentQuestion.possibleAnswers[choice].specificResponse)
        self.moveViews(percentage: currentQuestion.possibleAnswers[choice].resultingChange)
    }

    func createLabelFadeTransition() -> CATransition {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade
        animation.duration = 0.3
        return animation
    }

    func moveViews(percentage: Float) {
        var numberOfViewsToMove = Int(abs(Int32(percentage * Float(numberOfPeople))))

        previousState.removeAll()

        if percentage > 0 {
            if !notInterestedPersonViews.isEmpty {
                if notInterestedPersonViews.count < numberOfViewsToMove {
                    numberOfViewsToMove = notInterestedPersonViews.count
                }

                for _ in 0..<numberOfViewsToMove {

                    moveViewToInterested()
                }
            }
        } else if percentage < 0 {
            if !interestedPersonViews.isEmpty {
                if interestedPersonViews.count < numberOfViewsToMove {
                    numberOfViewsToMove = interestedPersonViews.count
                }


                for _ in 0..<numberOfViewsToMove {
                    moveViewToNotInterested()
                }
            }
        }
    }

    func moveViewToInterested() {
        let numberOfJumps: CGFloat = 3

        let personToMove = notInterestedPersonViews.removeFirst()

        let startingPoint = personToMove.position

        previousState.append(LayerState(layer: personToMove, position: startingPoint, wasNotInterested: true))

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

    func moveViewToNotInterested() {
        let personToMove = interestedPersonViews.removeFirst()

        let startingPoint = personToMove.position

        previousState.append(LayerState(layer: personToMove, position: startingPoint, wasNotInterested: false))

        let destinationX = pickRandomX(forPersonSized: personToMove.bounds.size, withInterest: false) + (personToMove.bounds.size.width / 2)

        let rotation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        rotation.values = [0, -0.5, -0.5, 0]
        rotation.duration = 1.8
        rotation.keyTimes = [0, 0.33, 0.9, 1]

        personToMove.add(rotation, forKey: "rotation")

        let movement = CABasicAnimation(keyPath: "position")
        movement.fromValue = startingPoint
        movement.duration = 1.5
        personToMove.position = CGPoint(x: destinationX, y: startingPoint.y)
        personToMove.add(movement, forKey: "movement")

        let colorsAnimation = CABasicAnimation(keyPath: "fillColor")
        colorsAnimation.fromValue = personToMove.fillColor
        colorsAnimation.duration = 1.5

        personToMove.fillColor = dullerGreen.cgColor
        personToMove.add(colorsAnimation, forKey: "fillColor")

        self.notInterestedPersonViews.append(personToMove)
    }

    func undoAnswer() {
        changeQuestionLabel(to: questions[currentQuestionIndex].questionText)

        showAnswers()
        nextQuestionButton.setTitle("Next Question", for: .normal)

        for state in previousState {
            let person = state.layer
            var color = brighterGreen.cgColor

            if state.wasNotInterested,
                let index = interestedPersonViews.index(of: person) {
                interestedPersonViews.remove(at: index)
                notInterestedPersonViews.append(person)
                color = dullerGreen.cgColor
            } else if let index = notInterestedPersonViews.index(of: person) {
                notInterestedPersonViews.remove(at: index)
                interestedPersonViews.append(person)
            }

            UIView.animate(withDuration: 0.3) {
                person.position = state.position
                person.fillColor = color
            }
        }

        previousState.removeAll()
    }

    func presentNextQuestion() {

        switch gameState() {
        case .playAgain:
            resetGame()
        case .inProgress:
            currentQuestionIndex += 1
            setTextForQuestion()
            showAnswers()
        case .won:
            changeQuestionLabel(to: "Congratulations! You have personally changed the future of tech and equality")
            showPlayAgain()
        case .lost:
            changeQuestionLabel(to: "Error: Something went wrong. Please try again. (You Lost)")
            showPlayAgain()
        case .completed:
            let percentChange = self.percentChange

            let numberFormatter = NumberFormatter()
            numberFormatter.locale = Locale.current
            numberFormatter.numberStyle = .percent
            let percentChangeString = numberFormatter.string(from: NSNumber(floatLiteral: percentChange)) ?? "0%"

            if percentChange < 0 {
                changeQuestionLabel(to: "You might want to try again. You  decreased the number of women in STEM by \(percentChangeString)")
            } else if percentChange == 0 {
                changeQuestionLabel(to: "At the end of the day, no change was made. Try again?")
            } else {
                changeQuestionLabel(to: "You've completed the quest set before you and have increased the number of women in STEM by \(percentChangeString)")
            }
            showPlayAgain()
        }
    }

    func showPlayAgain() {
        self.choice1Button.alpha = 0
        self.choice2Button.alpha = 0
        self.choice3Button.alpha = 0
        chooseAgainButton.alpha = 0

        UIView.animate(withDuration: 0.3) {
            self.choice1Button.isHidden = true
            self.choice2Button.isHidden = true
            self.choice3Button.isHidden = true

            self.nextQuestionButton.setTitle("Play Again?", for: .normal)

            self.chooseAgainButton.isHidden = true
        }

        isReadyForPlayAgain = true
    }

    func gameState() -> GameState {
        if isReadyForPlayAgain {
            return .playAgain
        } else if notInterestedPersonViews.isEmpty {
            return .won
        } else if interestedPersonViews.isEmpty {
            return .lost
        } else if currentQuestionIndex == questions.count - 1 {
            return .completed
        } else {
            return .inProgress
        }
    }

    func showAnswers() {
        choice1Button.isEnabled = true
        choice2Button.isEnabled = true
        choice3Button.isEnabled = true

        nextQuestionButton.alpha = 0
        chooseAgainButton.alpha = 0

        UIView.animate(withDuration: 0.3) {

            self.choice1Button.alpha = 1
            self.choice2Button.alpha = 1
            self.choice3Button.alpha = 1

            self.choice1Button.isHidden = false
            self.choice2Button.isHidden = false
            self.choice3Button.isHidden = false

            self.nextQuestionButton.isHidden = true
            self.chooseAgainButton.isHidden = true
        }
    }

    func resetGame() {
        notInterestedPersonViews.removeAll()
        interestedPersonViews.removeAll()
        questions.removeAll()
        currentQuestionIndex = 0
        previousState.removeAll()
        isReadyForPlayAgain = false

        UIView.animate(withDuration: 0.3, animations: {
            self.mainStackView.alpha = 0
        }, completion: { success in
            self.mainStackView.removeFromSuperview()
            self.setupGame()
        })
    }
}

PlaygroundPage.current.liveView = GameViewController()
