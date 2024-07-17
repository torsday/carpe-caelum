.PHONY: all lint lint-fix type-check test test-doc

lint:
	bundle exec rubocop -A
	steep check

test:
	bundle exec rspec spec

test-doc:
	bundle exec rspec spec --format documentation
