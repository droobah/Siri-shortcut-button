/*
See LICENSE folder for this sample’s licensing information.

Abstract:
`PlayMediaIntentHandler` determines if specific `INPlayMediaIntent` instances can be used to play content,
 and routes the intent to the main app to start playback if appropiate.
*/

import Intents
import AudioCastKit

public class PlayMediaIntentHandler: INExtension, INPlayMediaIntentHandling {
    
    public func confirm(intent: INPlayMediaIntent, completion: @escaping (INPlayMediaIntentResponse) -> Void) {
        /*
         This sample demonstrates how a user may want to use a suggested shortcut to play a specific show they subscribed
         to, or a specific playlist of episodes from multiple shows. If no container item is provided, don't
         attempt to play the podcast episode.
         */
        guard let container = intent.mediaContainer,
            let playRequest = PlayRequest(intent: intent)
        else {
            completion(INPlayMediaIntentResponse(code: .failure, userActivity: nil))
            return
        }
        
        guard container.type == .podcastShow || container.type == .podcastPlaylist
        else {
            completion(INPlayMediaIntentResponse(code: .failureUnknownMediaType, userActivity: nil))
            return
        }
        
        if let itemsToPlay = AudioPlaybackManager.shared.resolveItems(for: playRequest), let firstItem = itemsToPlay.first {
            /*
             The structure of the intent matches what the app knows how to handle, so tell the system that
             this intent is ready for handling. Provide "now playing" information about the media that is
             about to play.
             */
            let response = INPlayMediaIntentResponse(code: .ready, userActivity: nil)
            response.nowPlayingInfo = AudioPlaybackManager.nowPlayingInfo(for: firstItem.episode, in: firstItem.container, forShortcut: true)
            completion(response)
        } else {
            /*
             This sample is based around a feed of podcasts that updates as new episodes are made available.
             Apps should verify that they have content to play and respond with `failureNoUnplayedContent` if there is nothing to play.
             */
            let response = INPlayMediaIntentResponse(code: .failureNoUnplayedContent, userActivity: nil)
            completion(response)
        }
    }
    
    /// - Tag: handle_extension
    public func handle(intent: INPlayMediaIntent, completion: @escaping (INPlayMediaIntentResponse) -> Void) {
        /*
         Media playback should start in the main app because the app extension's life span is short.

         For audio content, respond with the `.handleInApp` response code to have the system launch
         the main app in the background and call `application(_:, handle:, completionHandler:)` on
         the `UIApplicationDelegate`. This is the app's opportunity to play the audio in the background
         without the user needing to use the app directly.

         For video content, respond with the `.continueInApp` response code. This launches the main
         app in the foreground, and calls the `UIApplicationDelegate` method
         `application(_, continue:, restorationHandler:)`.
        */
        let response = INPlayMediaIntentResponse(code: .handleInApp, userActivity: nil)
        completion(response)
    }
}
