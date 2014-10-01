# A makefile to help encrypt posts with a password
# From https://gist.github.com/ambrosechua/e88bf467b3a0f2f14ff5

SHELL := /bin/zsh

DIRECTORY = "_posts"
EXT_ENC = ".aes.b64"
EXT_FILE = ".md"
ENCRYPTION = "aes-128-cbc"

all: usage

usage:
	@echo "Usage: "
	@echo "	make encrypt - checks and encrypts all '$(EXT_FILE)' files in '$(DIRECTORY)'"
	@echo "	make decrypt - decrypts all '$(EXT_ENC)' files in '$(DIRECTORY)'"

encrypt:
	if [ -z "`find $(DIRECTORY) -type f -regex ".*$(EXT_FILE)"`" ]; then;\
		echo "Nothing to encrypt. ";\
		exit 1;\
	fi;\
	echo -n "Enter password: ";\
	read -s pass;\
	echo;\
	echo -n "Enter password again: ";\
	read -s pass2;\
	echo;\
	if [ $$pass != $$pass2 ]; then;\
		echo "Not matching passwords. ";\
		exit 1;\
	fi;\
	for f in `find $(DIRECTORY) -type f -regex ".*$(EXT_ENC)"`; do;\
		export fn=$$(echo $$f | cut -d "." -f 1);\
		echo "$$f -> $$fn$(EXT_FILE)";\
		openssl base64 -d -in $$f -out $$fn.aes;\
		openssl $(ENCRYPTION) -d -salt -in $$fn.aes -out $$fn$(EXT_FILE) -k $$pass;\
		if [ $$? -ne 0 ]; then;\
			echo "Error: Unable to decrypt with supplied password. ";\
			rm $$fn.aes;\
			rm $$fn$(EXT_FILE);\
			exit 1;\
		else;\
			rm $$fn.aes;\
			rm $$f;\
		fi;\
	done;\
	for f in `find $(DIRECTORY) -type f -regex ".*$(EXT_FILE)"`; do;\
		export fn=$$(echo $$f | cut -d "." -f 1);\
		echo "$$f -> $$fn$(EXT_ENC)";\
		openssl $(ENCRYPTION) -salt -in $$f -out $$fn.aes -k $$pass;\
		openssl base64 -in $$fn.aes -out $$fn$(EXT_ENC);\
		rm $$fn.aes;\
		rm $$f;\
	done;\
	if [ -e _site ]; then;\
		rm -r _site;\
	fi;

decrypt:
	if [ -z "`find $(DIRECTORY) -type f -regex ".*$(EXT_ENC)"`" ]; then;\
		echo "Nothing to decrypt. ";\
		exit 1;\
	fi;\
	echo -n "Enter password: ";\
	read -s pass;\
	echo;\
	for f in `find $(DIRECTORY) -type f -regex ".*$(EXT_ENC)"`; do;\
		export fn=$$(echo $$f | cut -d "." -f 1);\
		echo "$$f -> $$fn$(EXT_FILE)";\
		openssl base64 -d -in $$f -out $$fn.aes;\
		openssl $(ENCRYPTION) -d -salt -in $$fn.aes -out $$fn$(EXT_FILE) -k $$pass;\
		if [ $$? -ne 0 ]; then;\
			echo "Error: Unable to aes-128 decrypt with supplied password. ";\
			rm $$fn.aes;\
			rm $$fn$(EXT_FILE);\
			exit 1;\
		else;\
			rm $$fn.aes;\
			rm $$f;\
		fi;\
	done;

server:
	@make serve
serve:
	@jekyll serve
