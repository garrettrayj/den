#!/usr/bin/env python3

import json



symbols_file = open('SF Symbols List.json')
restricted_file = open('SF Symbols Restricted.json')

symbols = json.load(symbols_file)
restricted = json.load(restricted_file)
restricted = [s['symbolName'] for s in restricted]
good_symbols = []

blacklist = [
	'fill',
	'circle',
	'square',
	'arrow',
	'airpod',
	'homepod',
	'plus',
	'minus',
	'xmark',
	'backward',
	'forward',
	'text',
	'chevron',
	'bold',
	'slash',
	'sidebar',
	'badge',
	'battery',
	'hand',
	'rectangle',
	'tablecells',
	'underline',
	'speaker',
	'pip',
	'crop',
	'eyedropper',
	'decrease',
	'increase',
	'uiwindow',
	'bubble',
	'die',
	'joystick',
	'camera.metering',
	'app',
	'line',
	'list',
	'location',
	'lock',
	'capsule',
	'aqi',
	'exclamationmark',
	'italic',
	'clear',
	'repeat',
	'keyboard.macwindow',
	'ipodtouch',
	'oval',
	'poweroff',
	'poweron',
	'rotate',
	'left',
	'1.magnifyingglass'
	
]

for symbol in symbols:
	if symbol in restricted:
		continue
	
	
	if [word for word in blacklist if (word in symbol)]:
		continue	
	
	good_symbols.append('"' + symbol + '"')
	

good_symbols.insert(0, '"person.and.arrow.left.and.arrow.right"')

good_symbols.sort()

good_symbols.insert(0, '"square.grid.2x2"')

print(', '.join(good_symbols))
	

	