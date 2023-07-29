screenshots:
	Scripts/Screenshots.sh

test-data:
	rm -rf /tmp/TestData/en.xcappdata/AppData
	mkdir -p /tmp/TestData/en.xcappdata/AppData
	cp -r $(shell xcrun simctl get_app_container "iPad Air (5th generation)" net.devsci.den data)/ /tmp/TestData/en.xcappdata/AppData/
	
	rm -rf ./TestData/en.xcappdata/AppData
	mkdir -p ./TestData/en.xcappdata/AppData/Library/Application\ Support/Den
	
	cp -a /tmp/TestData/en.xcappdata/AppData/Library/Application\ Support/Den/ \
		./TestData/en.xcappdata/AppData/Library/Application\ Support/Den/

acknowledgements:
	license-plist

.PHONY: *
