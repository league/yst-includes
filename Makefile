default: test

test:
	yst
	diff -Pur site expected

clean:
	$(RM) -r site/
