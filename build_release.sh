#!/bin/bash
xcodebuild clean build -project AMM.xcodeproj -target AMM
xcodebuild test -project AMM.xcodeproj -scheme AMM

