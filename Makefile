$(eval $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS)):;@:)

%:
	npm run $@ -- $(filter-out $@,$(MAKECMDGOALS))
