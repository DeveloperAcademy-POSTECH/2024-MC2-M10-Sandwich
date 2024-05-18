//
//  DummyData.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/15/24.
//

import Foundation

let dummyPartys: [Party] = [
    Party(
        title: "Birthday Bash",
        startDate: Date(),
        notiCycle: 7,
        stepList: [Step(mediaList: [Media(fileData: Data(), captureDate: Date())])],
        isLive: true,
        isShutdown: false,
        memberList: [Member(profileImageData: Data())],
        comment: "Looking forward to it!"
    ),
    Party(
        title: "Corporate Retreat",
        startDate: Date(),
        notiCycle: 14,
        stepList: [Step(mediaList: [Media(fileData: Data(), captureDate: Date())])],
        isLive: false,
        isShutdown: true,
        memberList: [Member(profileImageData: Data())],
        comment: "Don't forget to bring gifts!"
    ),
    Party(
        title: "Wedding Party",
        startDate: Date(),
        notiCycle: 30,
        stepList: [Step(mediaList: [Media(fileData: Data(), captureDate: Date())])],
        isLive: true,
        isShutdown: false,
        memberList: [Member(profileImageData: Data())],
        comment: "Formal attire required."
    ),
    Party(
        title: "Graduation Celebration",
        startDate: Date(),
        notiCycle: 7,
        stepList: [Step(mediaList: [Media(fileData: Data(), captureDate: Date())])],
        isLive: true,
        isShutdown: false,
        memberList: [Member(profileImageData: Data())],
        comment: "It's going to be epic!"
    ),
    Party(
        title: "New Year's Eve",
        startDate: Date(),
        notiCycle: 1,
        stepList: [Step(mediaList: [Media(fileData: Data(), captureDate: Date())])],
        isLive: true,
        isShutdown: false,
        memberList: [Member(profileImageData: Data())],
        comment: "Remember to RSVP."
    ),
    Party(
        title: "Halloween Party",
        startDate: Date(),
        notiCycle: 3,
        stepList: [Step(mediaList: [Media(fileData: Data(), captureDate: Date())])],
        isLive: false,
        isShutdown: true,
        memberList: [Member(profileImageData: Data())],
        comment: "Potluck style."
    ),
    Party(
        title: "Summer BBQ",
        startDate: Date(),
        notiCycle: 7,
        stepList: [Step(mediaList: [Media(fileData: Data(), captureDate: Date())])],
        isLive: true,
        isShutdown: false,
        memberList: [Member(profileImageData: Data())],
        comment: "See you all there!"
    ),
    Party(
        title: "Christmas Gathering",
        startDate: Date(),
        notiCycle: 15,
        stepList: [Step(mediaList: [Media(fileData: Data(), captureDate: Date())])],
        isLive: true,
        isShutdown: false,
        memberList: [Member(profileImageData: Data())],
        comment: "Let's make it memorable."
    ),
    Party(
        title: "Farewell Party",
        startDate: Date(),
        notiCycle: 20,
        stepList: [Step(mediaList: [Media(fileData: Data(), captureDate: Date())])],
        isLive: true,
        isShutdown: false,
        memberList: [Member(profileImageData: Data())],
        comment: "Bring your own drinks."
    ),
    Party(
        title: "Anniversary Celebration",
        startDate: Date(),
        notiCycle: 10,
        stepList: [Step(mediaList: [Media(fileData: Data(), captureDate: Date())])],
        isLive: true,
        isShutdown: false,
        memberList: [Member(profileImageData: Data())],
        comment: "Dress code: Casual."
    )
]
