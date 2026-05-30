.PHONY: bootstrap xcodegen setup open clean

XCODEGEN_VERSION := 2.42.0

bootstrap:
	@which xcodegen > /dev/null 2>&1 || brew install xcodegen
	@echo "XcodeGen $$(xcodegen version 2>&1) ✓"

xcodegen: bootstrap
	xcodegen generate
	xcodegen generate --spec Example/project.yml

setup: xcodegen

open: xcodegen
	open Caos.xcodeproj

clean:
	rm -rf Caos.xcodeproj Example/CaosExample.xcodeproj .build
