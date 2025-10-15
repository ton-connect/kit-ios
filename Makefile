# Build and copy JS bridge
js:
	@if [ -z "$(WALLETKIT_PATH)" ]; then \
		echo "Building with default walletkit folder..."; \
		bash Scripts/build-walletkit.sh; \
	else \
		echo "Building with custom path: $(WALLETKIT_PATH)"; \
		bash Scripts/build-walletkit.sh "$(WALLETKIT_PATH)"; \
	fi