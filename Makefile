screenshots:
	Screenshots/screenshots.sh

test-data:
	rm -rf "./TestData/en.xcappdata"
	mkdir -p ./TestData/en.xcappdata/AppData
	cp -r $(shell xcrun simctl get_app_container "iPad Air (4th generation)" net.devsci.den data)/ ./TestData/en.xcappdata/AppData/
	
	#mkdir -p "./TestData/en.xcappdata/Library/Application Support/Den"
	#cp -r "./TestData/en-tmp.xcappdata/Library/Application Support/Den/" "./TestData/en.xcappdata/Library/Application Support/Den/"
	#rm -rf "./TestData/en.xcappdata/Library/Application Support/Den/.Den_SUPPORT"

.PHONY: screenshots
