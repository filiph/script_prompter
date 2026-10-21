.PHONY: deploy

deploy:
	jaspr clean
	jaspr build --dart-define=BASE_HREF=/prompter/
	rm -rf ~/dev/filiphnet/old/prompter/*
	cp -R build/jaspr/* ~/dev/filiphnet/old/prompter/
	@echo "IMPORTANT: You have to deploy filiph.net manually now."
