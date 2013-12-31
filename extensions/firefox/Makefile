.PHONY: test clean xpi

cfx := tools/addon-sdk/bin/cfx

xpi: tools
	$(cfx) xpi --pkgdir src

tools: tools/addon-sdk

tools/addon-sdk:
	mkdir -p tools
	curl -OL https://ftp.mozilla.org/pub/mozilla.org/labs/jetpack/jetpack-sdk-latest.tar.gz 
	tar -xf jetpack-sdk-latest.tar.gz
	mv addon-sdk-1.14 tools/addon-sdk
	rm -f jetpack-sdk-latest.tar.gz

test: tools
	$(cfx) run --pkgdir src

clean:
	rm *.xpi
