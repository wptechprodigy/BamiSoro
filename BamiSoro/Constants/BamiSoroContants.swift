//
//  BamiSoroContants.swift
//  BamiSoro
//
//  Created by waheedCodes on 07/11/2020.
//

import UIKit

enum LoginConstant {
    static let isLoggedIn = "isLoggedIn"
    static let loginTitle = "Log In"
}

enum LogoutActionSheetConstant {
    static let title = ""
    static let message = ""
}

enum LogoutOptionConstant {
    static let yesLogout = "Log out"
    static let noCancel = "Cancel"
}

enum RegisterConstant {
    static let register = "Register"
    static let createAccount = "Create Account"
}

enum ImageAssetsConstant {
    static let logo = "Logo"
}

enum PlaceholderConstant {
    static let firstName = "First Name"
    static let lastName = "Last Name"
    static let email = "Email Address..."
    static let password = "Password..."
    static let profilePlaceHolder = "person.circle"
}

enum ErrorMessageConstant {
    static let loginRegistrationErrorTitle = "Whoops"
    static let loginErrorMessage = "Please fill all fields to login."
    static let registerErrorMessage = "Please fill all fields to create an account."
    static let dismissError = "Dismiss"
    static let createUserError = "Error creating users!"
    static let loginUserErrorMessage = "Failed to log in user with email:"
    static let userAlreadyExistsErrorMessage = "User with the provided email address already exists."
}

enum SelectProfilePictureConstant {
    static let title = "Profile Picture"
    static let profilePictureOptionMessage = "How would you like to add a profile picture?"
    static let cancel = "Cancel"
    static let choosePhoto = "Choose photo from device"
    static let takePhoto = "Take photo"
}

enum FBGraphPath {
    static let graphPath = "me"
}

enum ConversationsConstant {
    static let noConverstations = "No Conversations!"
}

enum SearchBarConstant {
    static let placeHolder = "Search..."
    static let cancelSearch = "Cancel"
    static let noSearchResult = "Contact not found!"
}

enum UserDefaultConstant {
    static let email = "email"
}

enum ProfilePictureConstant {
    static let profilePictureSuffix = "_profile_picture.png"
}
