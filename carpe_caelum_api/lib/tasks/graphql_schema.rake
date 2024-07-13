# frozen_string_literal: true

namespace :graphql do
  desc 'Dump GraphQL schema'
  task dump_schema: :environment do
    schema = CarpeCaelumApiSchema.to_definition
    Rails.root.join('schema.graphql').write(schema)
    puts 'GraphQL schema dumped to schema.graphql'
  end
end
