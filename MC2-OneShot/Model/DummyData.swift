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
        stepList: [Step(mediaList: [Media(fileData: "photo1.jpg", captureDate: Date()), Media(fileData: "photo2.jpg", captureDate: Date())])],
        isLive: true,
        isShutdown: false,
        memberList: [Member(profileImage: "member1.jpg"), Member(profileImage: "member2.jpg")],
        comment: "Looking forward to it!"
    ),
    Party(
        title: "Office Party",
        startDate: Date(),
        notiCycle: 3,
        stepList: [Step(mediaList: [Media(fileData: "photo3.jpg", captureDate: Date()), Media(fileData: "photo4.jpg", captureDate: Date())])],
        isLive: false,
        isShutdown: true,
        memberList: [Member(profileImage: "member3.jpg"), Member(profileImage: "member4.jpg")],
        comment: nil
    ),
    Party(
        title: "New Year Celebration",
        startDate: Date(),
        notiCycle: 10,
        stepList: [Step(mediaList: [Media(fileData: "photo5.jpg", captureDate: Date()), Media(fileData: "photo6.jpg", captureDate: Date())])],
        isLive: true,
        isShutdown: false,
        memberList: [Member(profileImage: "member5.jpg"), Member(profileImage: "member6.jpg")],
        comment: "Happy New Year!"
    ),
    Party(
        title: "Summer BBQ",
        startDate: Date(),
        notiCycle: 14,
        stepList: [Step(mediaList: [Media(fileData: "photo7.jpg", captureDate: Date()), Media(fileData: "photo8.jpg", captureDate: Date())])],
        isLive: true,
        isShutdown: false,
        memberList: [Member(profileImage: "member7.jpg"), Member(profileImage: "member8.jpg")],
        comment: "Can't wait for the BBQ!"
    ),
    Party(
        title: "Halloween Party",
        startDate: Date(),
        notiCycle: 5,
        stepList: [Step(mediaList: [Media(fileData: "photo9.jpg", captureDate: Date()), Media(fileData: "photo10.jpg", captureDate: Date())])],
        isLive: true,
        isShutdown: false,
        memberList: [Member(profileImage: "member9.jpg"), Member(profileImage: "member10.jpg")],
        comment: "Spooky!"
    ),
    Party(
        title: "Christmas Party",
        startDate: Date(),
        notiCycle: 25,
        stepList: [Step(mediaList: [Media(fileData: "photo11.jpg", captureDate: Date()), Media(fileData: "photo12.jpg", captureDate: Date())])],
        isLive: false,
        isShutdown: true,
        memberList: [Member(profileImage: "member11.jpg"), Member(profileImage: "member12.jpg")],
        comment: "Merry Christmas!"
    ),
    Party(
        title: "Graduation Party",
        startDate: Date(),
        notiCycle: 12,
        stepList: [Step(mediaList: [Media(fileData: "photo13.jpg", captureDate: Date()), Media(fileData: "photo14.jpg", captureDate: Date())])],
        isLive: true,
        isShutdown: false,
        memberList: [Member(profileImage: "member13.jpg"), Member(profileImage: "member14.jpg")],
        comment: "Congratulations to all graduates!"
    ),
    Party(
        title: "Anniversary Party",
        startDate: Date(),
        notiCycle: 30,
        stepList: [Step(mediaList: [Media(fileData: "photo15.jpg", captureDate: Date()), Media(fileData: "photo16.jpg", captureDate: Date())])],
        isLive: true,
        isShutdown: false,
        memberList: [Member(profileImage: "member15.jpg"), Member(profileImage: "member16.jpg")],
        comment: "Happy Anniversary!"
    ),
    Party(
        title: "Farewell Party",
        startDate: Date(),
        notiCycle: 8,
        stepList: [Step(mediaList: [Media(fileData: "photo17.jpg", captureDate: Date()), Media(fileData: "photo18.jpg", captureDate: Date())])],
        isLive: false,
        isShutdown: true,
        memberList: [Member(profileImage: "member17.jpg"), Member(profileImage: "member18.jpg")],
        comment: "Goodbye and good luck!"
    ),
    Party(
        title: "Welcome Party",
        startDate: Date(),
        notiCycle: 6,
        stepList: [Step(mediaList: [Media(fileData: "photo19.jpg", captureDate: Date()), Media(fileData: "photo20.jpg", captureDate: Date())])],
        isLive: true,
        isShutdown: false,
        memberList: [Member(profileImage: "member19.jpg"), Member(profileImage: "member20.jpg")],
        comment: "Welcome to the team!"
    )
]
