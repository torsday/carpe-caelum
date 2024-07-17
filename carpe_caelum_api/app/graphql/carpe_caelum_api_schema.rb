# frozen_string_literal: true

# CarpeCaelumApiSchema defines the schema for the Carpe Caelum API.
class CarpeCaelumApiSchema < GraphQL::Schema
  query(Types::QueryType)
  mutation(Types::MutationType)

  use GraphQL::Dataloader

  max_complexity 1000
  max_depth 10
  max_query_string_tokens 5000
  validate_max_errors 100

  def self.resolve_type(_abstract_type, _obj, _ctx)
    raise(GraphQL::RequiredImplementationMissingError)
  end

  def self.id_from_object(object, _type_definition, _query_ctx)
    object.to_gid_param
  end

  def self.object_from_id(global_id, _query_ctx)
    GlobalID.find(global_id)
  end
end
