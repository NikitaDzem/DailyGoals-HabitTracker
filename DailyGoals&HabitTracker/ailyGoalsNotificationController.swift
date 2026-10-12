import Foundation
import SwiftUI
import UIKit
import UserNotifications

final class ailyGoalsNotificationController: UIViewController {
    private let ailyGoalsAdditionalLabel = UILabel()
    private let ailyGoalsBackground = UIImageView(image: UIImage(named: "ailyGoalsBgForNotificationsPortrait"))
    private let ailyGoalsMainLabel = UILabel()

    private let ailyGoalsSkip = UIButton(type: .system)
    private let ailyGoalsAccept = UIButton(type: .system)

    private var ailyGoalsPortraitConstraints: [NSLayoutConstraint] = []
    private var ailyGoalsWidthSkipConstraints: NSLayoutConstraint!
    private var ailyGoalsLandscapeConstraints: [NSLayoutConstraint] = []
    private var ailyGoalsWidthAcceptConstraints: NSLayoutConstraint!

    private let ailyGoalsFirstCallKey = "ailyGoalsFirstCall"
    private let ailyGoalsNotificationFallbackKey = "ailyGoalsNotificationPermissionFallback"

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        ailyGoalsApplyCorrectLayout()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ailyGoalsSettings()
        ailyGoalsAccept.translatesAutoresizingMaskIntoConstraints = false
        ailyGoalsSkip.translatesAutoresizingMaskIntoConstraints = false
    }

    private func ailyGoalsApplyCorrectLayout() {
        let ailyGoalsIsLandscape = view.bounds.width > view.bounds.height

        if ailyGoalsIsLandscape {
            ailyGoalsBackground.image = UIImage(named: "ailyGoalsBgForNotificationsLandscape")
            ailyGoalsMainLabel.font = UIFont(name: "Inter-Bold", size: 22)

            NSLayoutConstraint.deactivate(ailyGoalsPortraitConstraints)

            if ailyGoalsLandscapeConstraints.isEmpty {
                ailyGoalsSetLandscape()
            }

            ailyGoalsMainLabel.textAlignment = .left
            NSLayoutConstraint.activate(ailyGoalsLandscapeConstraints)
            ailyGoalsGetDevice()
        } else {
            ailyGoalsBackground.image = UIImage(named: "ailyGoalsBgForNotificationsPortrait")
            ailyGoalsMainLabel.font = UIFont(name: "Inter-Bold", size: 21)
            ailyGoalsAdditionalLabel.font = UIFont(name: "Inter-Italic", size: 15)

            NSLayoutConstraint.deactivate(ailyGoalsLandscapeConstraints)
            ailyGoalsMainLabel.textAlignment = .center
            NSLayoutConstraint.activate(ailyGoalsPortraitConstraints)
        }
    }

    private func ailyGoalsAddSubviews() {
        view.addSubview(ailyGoalsBackground)
        view.addSubview(ailyGoalsMainLabel)
        view.addSubview(ailyGoalsAdditionalLabel)
        view.addSubview(ailyGoalsAccept)
        view.addSubview(ailyGoalsSkip)

        ailyGoalsBackground.translatesAutoresizingMaskIntoConstraints = false
        ailyGoalsMainLabel.translatesAutoresizingMaskIntoConstraints = false
        ailyGoalsAdditionalLabel.translatesAutoresizingMaskIntoConstraints = false
        ailyGoalsAccept.translatesAutoresizingMaskIntoConstraints = false

        ailyGoalsAdditionalLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        ailyGoalsAdditionalLabel.numberOfLines = 0
        ailyGoalsAdditionalLabel.adjustsFontSizeToFitWidth = true
        ailyGoalsAdditionalLabel.minimumScaleFactor = 0.5
        ailyGoalsAdditionalLabel.textAlignment = .center
        ailyGoalsAdditionalLabel.font = UIFont(name: "Inter-Italic", size: 15)

        ailyGoalsSkip.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(0.5)
        ailyGoalsSkip.setTitle("SKIP", for: .normal)
        ailyGoalsSkip.layer.cornerRadius = 20
        ailyGoalsSkip.titleLabel?.font = UIFont(name: "Inter-Bold", size: 19)
        ailyGoalsSkip.backgroundColor = .white.withAlphaComponent(0.3)

        ailyGoalsMainLabel.textAlignment = .center
        ailyGoalsMainLabel.textColor = .white
        ailyGoalsMainLabel.adjustsFontSizeToFitWidth = true
        ailyGoalsMainLabel.font = UIFont(name: "Inter-Bold", size: 21)
        ailyGoalsMainLabel.numberOfLines = 2

        ailyGoalsAccept.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        ailyGoalsAccept.layer.cornerRadius = 9
        if let ailyGoalsAcceptImage = UIImage(named: "ailyGoalsAcceptSugary") {
            ailyGoalsAccept.setBackgroundImage(ailyGoalsAcceptImage, for: .normal)
        }

        ailyGoalsMainLabel.text = "ALLOW NOTIFICATIONS ABOUT BONUSES AND PROMOS".uppercased()
        ailyGoalsAdditionalLabel.text = "Stay tuned with best offers from our casino".uppercased()
        ailyGoalsBackground.contentMode = .scaleAspectFill
    }

    private func ailyGoalsSettings() {
        ailyGoalsAppDelegate.ailyGoalsOrientation = .all
        ailyGoalsAddSubviews()
        ailyGoalsSetConstraints()
        ailyGoalsSetTargets()
    }

    private func ailyGoalsSetConstraints() {
        ailyGoalsBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        ailyGoalsBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        ailyGoalsBackground.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        ailyGoalsBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        ailyGoalsSetPortrait()
    }

    private func ailyGoalsSetLandscape() {
        ailyGoalsWidthAcceptConstraints = ailyGoalsAccept.widthAnchor.constraint(equalToConstant: 350)
        ailyGoalsWidthSkipConstraints = ailyGoalsSkip.widthAnchor.constraint(equalToConstant: 340)
        ailyGoalsMainLabel.textAlignment = .left
        ailyGoalsLandscapeConstraints = [
            ailyGoalsAdditionalLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            ailyGoalsAdditionalLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -55),

            ailyGoalsMainLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            ailyGoalsMainLabel.widthAnchor.constraint(equalToConstant: 300),
            ailyGoalsMainLabel.bottomAnchor.constraint(equalTo: ailyGoalsAdditionalLabel.topAnchor, constant: -15),

            ailyGoalsAccept.heightAnchor.constraint(equalToConstant: 53),
            ailyGoalsAccept.bottomAnchor.constraint(equalTo: ailyGoalsSkip.topAnchor, constant: -15),
            ailyGoalsAccept.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            ailyGoalsWidthAcceptConstraints,

            ailyGoalsSkip.centerXAnchor.constraint(equalTo: ailyGoalsAccept.centerXAnchor),
            ailyGoalsSkip.heightAnchor.constraint(equalToConstant: 40),
            ailyGoalsWidthSkipConstraints,
            ailyGoalsSkip.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -35)
        ]
        NSLayoutConstraint.activate(ailyGoalsLandscapeConstraints)
    }

    private func ailyGoalsSetPortrait() {
        ailyGoalsPortraitConstraints = [
            ailyGoalsMainLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ailyGoalsMainLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            ailyGoalsMainLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),

            ailyGoalsAdditionalLabel.topAnchor.constraint(equalTo: ailyGoalsMainLabel.bottomAnchor, constant: 10),
            ailyGoalsAdditionalLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            ailyGoalsAdditionalLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            ailyGoalsAdditionalLabel.bottomAnchor.constraint(equalTo: ailyGoalsAccept.topAnchor, constant: -25),

            ailyGoalsAccept.heightAnchor.constraint(equalToConstant: 53),
            ailyGoalsAccept.bottomAnchor.constraint(equalTo: ailyGoalsSkip.topAnchor, constant: -15),
            ailyGoalsAccept.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            ailyGoalsAccept.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            ailyGoalsSkip.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            ailyGoalsSkip.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            ailyGoalsSkip.heightAnchor.constraint(equalToConstant: 45),
            ailyGoalsSkip.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -45)
        ]

        NSLayoutConstraint.activate(ailyGoalsPortraitConstraints)
    }

    private func ailyGoalsSetTargets() {
        ailyGoalsAccept.addTarget(self, action: #selector(ailyGoalsAcceptAction), for: .touchUpInside)
        ailyGoalsSkip.addTarget(self, action: #selector(ailyGoalsSkipAction), for: .touchUpInside)
    }

    @objc
    private func ailyGoalsSkipAction() {

    }

    @objc
    private func ailyGoalsAcceptAction() {

    }

    private func ailyGoalsPresentMainFlow() {
        let ailyGoalsVault = ailyGoalsAppViewModel()
        let ailyGoalsRoot = ailyGoalsMainTabView(ailyGoalsViewModel: ailyGoalsVault)
        let ailyGoalsController = UIHostingController(rootView: ailyGoalsRoot)
        ailyGoalsController.modalPresentationStyle = .fullScreen
        present(ailyGoalsController, animated: true)
    }

    private func ailyGoalsGetDevice() {
        let ailyGoalsScreenWidth = UIScreen.main.bounds.width

        if ailyGoalsScreenWidth == 667.0 {
            ailyGoalsWidthAcceptConstraints.constant = 280
            ailyGoalsWidthSkipConstraints.constant = 260
            ailyGoalsAdditionalLabel.font = UIFont(name: "Inter-Italic", size: 12)
        } else if ailyGoalsScreenWidth == 896.0 {
            ailyGoalsAdditionalLabel.font = UIFont(name: "Inter-Italic", size: 15)
        }
    }
}

struct ailyGoalsNotificationView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ailyGoalsNotificationController {
        ailyGoalsNotificationController()
    }

    func updateUIViewController(_ ailyGoalsUIViewController: ailyGoalsNotificationController, context: Context) {}
}

#Preview {
    ailyGoalsNotificationView()
        .ignoresSafeArea()
}
