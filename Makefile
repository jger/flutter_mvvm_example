FLUTTER_VERSION := $(shell jq -r '.flutterSdkVersion' app/.fvm/fvm_config.json)
DOCKER_IMAGE    := flutter-goldens:$(FLUTTER_VERSION)
APP_DIR         := $(CURDIR)/app

.PHONY: goldens-build goldens-ensure-image goldens-update goldens-test

## Build the Linux/Ubuntu Flutter Docker image (matches CI)
goldens-build:
	docker build \
		--build-arg FLUTTER_VERSION=$(FLUTTER_VERSION) \
		-t $(DOCKER_IMAGE) \
		docker/goldens

## Build image only if missing (avoids pull from non-existent registry)
goldens-ensure-image:
	@docker image inspect $(DOCKER_IMAGE) >/dev/null 2>&1 || $(MAKE) goldens-build

## Regenerate golden PNGs on Linux (same as CI) and write them into app/test/goldens/
goldens-update: goldens-ensure-image
	docker run --rm \
		-v $(APP_DIR):/app \
		$(DOCKER_IMAGE) \
		sh -c "flutter pub get && \
		       dart run build_runner build --delete-conflicting-outputs && \
		       flutter test --update-goldens --tags golden"

## Run golden tests inside Linux container (compare only, no update)
goldens-test: goldens-ensure-image
	docker run --rm \
		-v $(APP_DIR):/app \
		$(DOCKER_IMAGE) \
		sh -c "flutter pub get && \
		       dart run build_runner build --delete-conflicting-outputs && \
		       flutter test --tags golden"
