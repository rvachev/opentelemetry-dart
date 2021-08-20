init:
	git submodule update --init
	pub get
	pub global activate protoc_plugin
	cd lib/src/sdk/trace/exporters && \
		protoc --proto_path opentelemetry-proto \
		--dart_out . \
		opentelemetry-proto/opentelemetry/proto/common/v1/common.proto \
		opentelemetry-proto/opentelemetry/proto/collector/trace/v1/trace_service.proto \
		opentelemetry-proto/opentelemetry/proto/trace/v1/trace.proto \
		opentelemetry-proto/opentelemetry/proto/resource/v1/resource.proto

analyze:
	@dart analyze ./lib
	@dart analyze ./test

format:
	@find ./lib/ -name '*.dart' | xargs dart format --fix
	@find ./test/ -name '*.dart' | xargs dart format --fix

test: format analyze
	@dart test ./test --chain-stack-traces

.PHONY: init analyze test
