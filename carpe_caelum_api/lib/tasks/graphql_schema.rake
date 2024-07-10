namespace :graphql do
  desc "Dump GraphQL schema"
  task dump_schema: :environment do
    schema = CarpeCaelumApiSchema.to_definition
    File.write(Rails.root.join("schema.graphql"), schema)
    puts "GraphQL schema dumped to schema.graphql"
  end
end
