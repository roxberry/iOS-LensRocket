LensRocket for iOS
================

LensRocket is a picture / video sharing application built on top of Windows Azure.

## Requirements
* Xcode - This sample was built with Xcode 5.0.2.
* iOS SDK - Version 7.0 should download with the latest version of Xcode.
* Apple iOS Developer Account - Since this app makes use of push notifications and the camera, it is a requirement that you are able to load the application on to a device in order to test it.  You can acquire an account [here](http://developer.apple.com).
* Windows Azure Account - Needed to create a Mobile Service, Notification Hub, and Storage Account.  [Sign up for a free trial](https://www.windowsazure.com/en-us/pricing/free-trial/).

## Repository Content ##

The iOS-LensRocket repo currently includes the following resources:

 - **source/client** - The iOS client source code.  This encompasses all client side code necessary to run LensRocket on iOS excluding one third party library mentioned below.
 - **source/server** - The Mobile Services scripts which are tied to the endpoints the client application talks to. 

#Setting up your Azure Services
In order to run this application, you'll need to set up several pieces within Windows Azure.  Start by creating the following: a Mobile Service, a Storage account, and a Notification Hub.  You will need the Storage account name / key as well as the Notification Hub name / access signatures later on.

After creating your Mobile Service in the Windows Azure Portal, you'll need to create tables named **AccountData**, **Friends**, **Messages**, **RocketFile**, and **UserPreferences**.  You'll also need to create custom APIs named **AcceptFriendRequest**, **GetRocketForRecipient**, **Login**, **Register**, **RequestFriend**, **SaveUsername**, and **SendRocketToFriends**  You'll also want to enable Script Source Control on the **Dashboard** page.

After creating your Notification Hub, you'll want to set up Apple Push Notification Service (APNS) by following the steps in [this walkthrough](http://www.windowsazure.com/en-us/documentation/articles/mobile-services-ios-get-started-push/).  Note that the steps in the current tutorial are for an older version of Xcode but they should carry forward to the current version.

Return to your Mobile Service and go to the **Configure** tab.  Under the **app settings** area, add the following name-value pairs with the appropriate value from your Storage Account or Notification Hub:
* STORAGE_ACCOUNT_NAME
* STORAGE_ACCOUNT_KEY
* NOTIFICATION_HUB_NAME
* NOTIFICATION_HUB_FULL_ACCESS_SIGNATURE

These values will be used by the scripts you upload later in the instructions.

#Client Application Changes
In order to run the client applicaiton, you'll need to change a few settings in your application.  After opening the project in Xcode, open LensRocket/Misc/**LensRocketConstants.h**.  Use the values from your Mobile Service / Notification Hub to set the following properties: **MOBILE_SERVICE_URL**, **MOBILE_SERVICE_APPLICATION_KEY**, **SENDER_ID**, **NOTIFICATION_HUB_CONNECTION_STRING**, and **NOTIFICATION_HUB_NAME**.

Finally, the LensRocket iOS appliation relies on the [AFNetworking Library](http://afnetworking.com/).  The easiest way to put this library in the client application is to make use of the CocoaPod already set up for it.  In order to do so, you must first have [installed CocoaPods](http://cocoapods.org/).  Once you have that installed, you can open a terminal and navigate to the root directory of the project (the one with the Podfile in it) and enter teh following command: **pod install**.  This should take care of installing the necessary dependency.

#Script Changes
After cloning the Mobile Service script repository locally, you'll want to copy over all files from the **source/server** folder to replace what you cloned locally.  Once that is done, push your repository changes back up to your Mobile Service.

## Contact

For additional questions or feedback, please contact the [team](mailto:chrisner@microsoft.com).
