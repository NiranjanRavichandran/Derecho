//
//  DoleRequestHandler.swift
//  Derecho
//
//  Created by Niranjan Ravichandran on 8/10/17.
//  Copyright © 2017 Aviato. All rights reserved.
//

import Intents

class DoleRequestHandler: NSObject, INRequestRideIntentHandling {
    
    
    func handle(requestRide intent: INRequestRideIntent,
                completion: @escaping (INRequestRideIntentResponse) -> Void) {
        let response = INRequestRideIntentResponse(
            code: .failureRequiringAppLaunchNoServiceInArea,
            userActivity: .none)
        completion(response)
    }
}

