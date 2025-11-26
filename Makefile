# Build and copy JS bridge
js:
	@RESOLVED_PATH=$$(bash Scripts/resolve-walletkit-path.sh "$(WALLETKIT_PATH)"); \
	echo "Resolved walletkit path: $$RESOLVED_PATH"; \
	bash Scripts/build-walletkit.sh "$$RESOLVED_PATH"

# Generate API models
models:
	@RESOLVED_PATH=$$(bash Scripts/resolve-walletkit-path.sh "$(WALLETKIT_PATH)"); \
	echo "Resolved walletkit path: $$RESOLVED_PATH"; \
	bash Scripts/generate-api/generate-api-models.sh "$$RESOLVED_PATH"