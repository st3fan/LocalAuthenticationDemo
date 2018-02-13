//
//  ViewController.swift
//  LocalAuthentication
//
//  Created by Stefan Arentz on 2018-02-13.
//  Copyright © 2018 Stefan Arentz. All rights reserved.
//

import UIKit
import LocalAuthentication
import SafariServices

class ViewController: UIViewController {

    @IBOutlet weak var privacySwitch: UISwitch!
    @IBOutlet weak var captionLabel: UILabel!



    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        var error: NSError?
        let context = LAContext() // Note: can not be global, state needs to be updated every time you come back
        if !context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            captionLabel.isHidden = false
            privacySwitch.isEnabled = false
        } else {
            privacySwitch.isOn = UserDefaults.standard.bool(forKey: "PrivacySwitch")
        }
    }

    @IBAction func openBrowser(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "PrivacySwitch") {
            var error: NSError?
            let context = LAContext() // Note: can not be global, state needs to be updated every time you come back
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                // Note: At this point we can also look at context.biometryType, which can be passcode, touchID or faceID. So we can show something specific based on that.
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Tell us who you are", reply: { (success, error) in
                    if success {
                        DispatchQueue.main.async {
                            let vc = SFSafariViewController(url: URL(string: "https://www.mozilla.org")!);
                            self.present(vc, animated: true, completion: nil)
                        }
                    } else {
                        // Note: we do not have to show anything on failure. You put in your wrong code, it is obvious that you will not open the browser.
                    }
                })
            } else {
                // Note: unclear what needs to be shown here
                print("Could not evaluate policy: \(error?.localizedDescription)")
            }

        } else {
            let vc = SFSafariViewController(url: URL(string: "https://www.mozilla.org")!);
            present(vc, animated: true, completion: nil)
        }
    }

    @IBAction func changePrivacySwitch(_ sender: UISwitch) {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Tell us who you are", reply: { (success, error) in
                DispatchQueue.main.async {
                    if success {
                        // Save the change
                        UserDefaults.standard.set(sender.isOn, forKey: "PrivacySwitch")
                        UserDefaults.standard.synchronize()
                    } else {
                        // Undo the change do not save
                        sender.isOn = !sender.isOn
                    }
                }
            })
        } else {
            // Undo the change do not save
            DispatchQueue.main.async {
                sender.isOn = !sender.isOn
            }
        }
    }

}
