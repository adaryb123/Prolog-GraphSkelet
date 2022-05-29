OUT := flp21-log

.PHONY: build
build: $(OUT)

$(OUT): db.pl
	swipl -q -g start -o flp21-log -c db.pl


.PHONY: clean
clean:
	rm -f flp21-log
