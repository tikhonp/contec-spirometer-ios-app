//
//  Alerts.swift
//  Contec Spirometer
//
//  Created by Tikhon Petrishchev on 29.09.2022.
//  Copyright © 2022 OOO Telepat. All rights reserved.
//

import Foundation
import SwiftUI

struct ErrorInfo: Identifiable {
    var id = UUID()
    let title: String
    let description: String
}

class ErrorAlerts: NSObject {
    static let error = ErrorInfo(
        title: LocalizedStringKey("Ops! Something bad happened!").stringValue(),
        description: LocalizedStringKey("Detailed information about this error has automaticly been recordedand we have been notified.").stringValue())
    static let invalidPeriferal = ErrorInfo(
        title: LocalizedStringKey("Ops! Invalid peripheral found!").stringValue(),
        description: LocalizedStringKey("Detailed information about this error has automaticly been recordedand we have been notified.").stringValue())
    static let serviceNotFound = ErrorInfo(
        title: LocalizedStringKey("Ops! Bluetooth service on peripheral device not found!").stringValue(),
        description: LocalizedStringKey("Detailed information about this error has automaticly been recordedand we have been notified.").stringValue())
    static let deviceIsNotReady = ErrorInfo(
        title: LocalizedStringKey("Device is not ready").stringValue(),
        description: LocalizedStringKey("Try to reload application.").stringValue())
    static let failedToDeleteData = ErrorInfo(
        title: LocalizedStringKey("Failed to delete data from spirometer").stringValue(),
        description: LocalizedStringKey("Try to reload application.").stringValue())
    static let disconnected = ErrorInfo(
        title: LocalizedStringKey("Device disconnected").stringValue(), description: "")
    static let emptyDataToUploadToMedsenger = ErrorInfo(
        title: LocalizedStringKey("No new records").stringValue(),
        description: LocalizedStringKey("All data already fetched with Medsenger.").stringValue())
    static let medsengerTokenIsEmpty = ErrorInfo(
        title: LocalizedStringKey("Authorization in Medsenger is not successful").stringValue(),
        description: LocalizedStringKey("Go to the Medsenger app for authorization").stringValue())
    static let failedToFetchDataError = ErrorInfo(
        title: LocalizedStringKey("Oops! Failed to fetch data" ).stringValue(),
        description: LocalizedStringKey("This can happen if the spirometer has a dead battery. If it's not, maybe it's a random error, try again.").stringValue())
    static let dataSuccessfullyUploadedToMedsenger = ErrorInfo(
        title: LocalizedStringKey("Done!").stringValue(),
        description: LocalizedStringKey("The data successfully uploaded to Medsenger.").stringValue())
    static let failedToConnectToNetwork = ErrorInfo(
        title: LocalizedStringKey("Device offline").stringValue(),
        description: LocalizedStringKey("Turn off Airplane Mode or connect to Wi-Fi.").stringValue())
    static let invalidUserParams = ErrorInfo(
        title: LocalizedStringKey("Invalid user params").stringValue(),
        description: LocalizedStringKey("Make shure that all values aren't equal to zero.").stringValue())
}
