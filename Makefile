screenshots:
	Screenshots/screenshots.sh

test-data:
	rm -rf "./TestData/en.xcappdata"
	cp -r $(shell xcrun simctl get_app_container "iPad Pro (12.9-inch) (4th generation)" net.devsci.den data) ./TestData/en-tmp.xcappdata
	mkdir -p "./TestData/en.xcappdata/Library/Application Support/Den"
	cp -r "./TestData/en-tmp.xcappdata/Library/Application Support/Den/" "./TestData/en.xcappdata/Library/Application Support/Den/"
	rm -rf "./TestData/en.xcappdata/Library/Application Support/Den/.Den_SUPPORT"
	rm -rf ./TestData/en-tmp.xcappdata

.PHONY: screenshots
