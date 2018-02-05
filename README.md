# Pods Updater

![ScreenShot: App Main Screen](https://raw.githubusercontent.com/kizitonwose/PodsUpdater/master/Assets/screenshot_1.png)

### Why this app?

I believe it should be up to the developer to determine the exact versions of dependencies used in their projects. 

When adding Pods to the Podfile, most developers use the optimistic operator `pod 'RxSwift', '~> 4.1.1'` or even leave out the version information entirely `pod 'RxSwift'`. This is because no one wants to go through the hell of finding new versions of their dependencies and updating manually. This also means the Dependency manager([CocoaPods](https://github.com/CocoaPods/CocoaPods)) will have to decide which version to install in your project. Granted, with the optimistic operator, CocoaPods would probably never install a version of the Pod with breaking changes as long as the framework's developer continues using semantic versioning. But then, you wouldn't even get to know about the breaking release at all.

Presently, the only way to check for updates in your Podfile is by running `pod outdated` in your project directory. This lists only the newest versions of your pods and you'd still have to copy the version numbers of Pods you wish to update into your Podfile. The problem with this is, say you're on version 3.x.x of a Pod, then one month later, there's been some newer 3.x.x and 4.x.x releases of the Pod. You check for updates using the command and it shows you version 4.x.x(the latest version), skipping other 3.x.x releases. If you are not ready to deal with breaking changes in your project at that time, you would still miss out on other newer 3.x.x releases just because you weren't informed about them.


This app helps you easily find all newer(or older) versions of your Pods and lets you update your Podfile with the desired version, hence giving the power of dependency management back to the developer.

## Usage

### Find releases for Pods in your Podfile

The app requires that your Podfile follows a specific pattern when declaring Pods `pod 'PodName', 'ExactVersion'` example: `pod 'RxSwift', '4.1.1'`

If this is already the case for your Podfile, click **Select Podfile** and choose the **Find Versions** option to proceed with finding releases for the Pods declared in your Podfile. You can choose to show only newer or all versions of your installed pods.

### Make your podfile compatible with the app

If you are using any of the magic operators(~>, >, >=, <, <=) or don't even have the version information declared at all, the app can help you find the exact installed versions of your Pods using the Podfile.lock file in your project. You can then save the newly generated Podfile. 

![ScreenShot: Make Podfile Compatible](https://raw.githubusercontent.com/kizitonwose/PodsUpdater/master/Assets/screenshot_2.png)

To perform this action, click **Select Podfile** and choose the **Make Compatible** option.

## Installation

Download the app from the [releases](https://github.com/kizitonwose/PodsUpdater/releases) page.

**OR**

Clone the repository to your computer, build and run the Project in Xcode.

## License

Available under the MIT license.