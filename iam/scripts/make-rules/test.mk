.PHONY: test.api-insecure
test.api-insecure:
	@echo "===========> test.api-insecure"
	@./tests/api.sh insecure::user

.PHONY: test.api-secure
test.api-secure:
	@echo "===========> test.api-secure"
	@./tests/api.sh secure::user

