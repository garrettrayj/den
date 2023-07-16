screenshots:
	Scripts/Screenshots.sh

test-data:
	rm -rf ./TestData/en.xcappdata/AppData
	mkdir -p ./TestData/en.xcappdata/AppData
	cp -r $(shell xcrun simctl get_app_container "iPad Air (4th generation)" net.devsci.den data)/ ./TestData/en.xcappdata/AppData/
	rm -rf ./TestData/en.xcappdata/AppData/Library/SplashBoard/
	rm -rf ./TestData/en.xcappdata/AppData/Library/Saved Application State/

.PHONY: screenshots
