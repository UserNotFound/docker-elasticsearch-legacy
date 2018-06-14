#!/usr/bin/env bats

@test "It should install Elasticsearch 6.2.4" {
  run elasticsearch-wrapper --version
  [[ "$output" =~ "Version: 6.2.4"  ]]
}

@test "It should have the repository-s3 plugin installed" {
  /elasticsearch/bin/elasticsearch-plugin list | grep -q "repository-s3"
}
