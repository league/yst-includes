default: test

test:
	yst
	diff -Pur site expected

correct:
	rsync -av site/ expected

clean:
	$(RM) -r site/
