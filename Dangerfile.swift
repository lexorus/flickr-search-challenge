import Danger
import Foundation

let danger = Danger()

let modifiedFiles = danger.git.modifiedFiles + danger.git.createdFiles
let modifiedSwiftFiles = modifiedFiles.filter { $0.hasSuffix(".swift") }

// Check if PR is still in progress
if danger.github.pullRequest.title.contains("WIP") {
    warn("PR is classed as Work in Progress")
}

// Check if no code was updated without tests
let testsUpdated = danger.git.modifiedFiles.contains { $0.hasSuffix("Tests.swift") }
if !modifiedSwiftFiles.isEmpty && !testsUpdated {
    warn("Swift files were changed, but the tests remained unmodified. Consider updating or adding to the tests to match the code changes.")
}

// Check PR title
let prTitle = danger.github.pullRequest.title
if let firstCharacter = prTitle.first, firstCharacter.isLowercase {
    warn("PR title should start with an uppercase letter.")
}

let prTitleMaxLength = 65
if prTitle.count > prTitleMaxLength {
    fail("PR title is too long. It should be less then \(prTitleMaxLength).")
}
