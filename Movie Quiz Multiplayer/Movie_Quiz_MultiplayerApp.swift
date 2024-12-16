import GoogleSignIn


@main

struct Movie_QuizApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().onOpenURL { url in
                //Handle Google Oauth URL
                GIDSignIn.sharedInstance.handle(url)
            }
            .statusBar(hidden: true)
        }
    }
}
