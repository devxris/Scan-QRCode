# Scan-QRCode
AVFoundation: Quick Response code (based on video capturing)  
1. QRCode scanner  
2. Barcode scanner
3. Using URL Schemes to launch system or 3rd party apps after retrieving info from scanner 
4. Host app need to register LSApplicationQueiesSchemes array in infor.plist  
	<key>LSApplicationQueriesSchemes</key>  
	<array>  
		<string>textreader</string>  
		<string>fb</string>  
		<string>whatsapp</string>  
	</array>  
5. Client App need to register URL Types in info.plist  
	<key>CFBundleURLTypes</key>  
	<array>  
		<dict>  
			<key>CFBundleURLName</key>  
			<string>SpecificDomainIdentifier</string>  
			<key>CFBundleURLSchemes</key>  
			<array>  
				<string>ClientAppProductName</string>  
			</array>  
		</dict>  
	</array>  

