class JoinCollection

  VERSION = "0.0.2"

  attr_reader :source_objects
  attr_accessor :join_type, :singular_target, :plural_target

  def initialize(collection)
    @source_objects = collection
  end

  def join_to(target, target_class, options)
    self.join_type = :join_to
    fk, pk, delegate_if, delegate_fields = extract_options(target, options)

    source_fks     = source_objects.map(&fk).compact
    target_objects = target_class.where(pk.in => source_fks).to_a

    mapper = target_objects.group_by(&pk)
    mapper.default = []
    join_data(mapper, fk, delegate_if, delegate_fields)
  end

  def join_one(target, target_class, options)
    self.join_type = :join_one
    join_many(target, target_class, options)
  end

  def join_many(target, target_class, options)
    self.join_type = :join_many unless self.join_type == :join_one
    fk, pk, delegate_if, delegate_fields = extract_options(target, options)

    source_pks     = source_objects.map(&pk).compact
    target_objects = target_class.where(fk.in => source_pks).to_a

    mapper = target_objects.group_by(&fk)
    mapper.default = []
    join_data(mapper, pk, delegate_if, delegate_fields)
  end

  private

  def extract_options(target, options)
    self.singular_target = target.to_s.singularize.to_sym
    self.plural_target   = target.to_s.pluralize.to_sym

    relation = options[:relation]
    delegation = options[:delegation]
    raise ArgumentError.new('Relation hash not found in options') unless relation.is_a?(Hash)
    raise ArgumentError.new('Delegation hash not found in options') unless delegation.is_a?(Hash)

    fk = relation.keys.first
    pk = relation.values.first

    if_block = delegation[:if] || lambda { |x| true }
    fields = delegation[:fields] || []

    return fk, pk, if_block, fields
  end

  def join_data(mapper, key, delegate_if, delegate_fields)
    join_type       = self.join_type
    singular_target = self.singular_target
    plural_target   = self.plural_target

    source_objects.each do |doc|
      target_objects = mapper[doc[key]]
      target_object  = (target_objects.find &delegate_if) || target_objects.first

      delegate_fields.each do |field|
        case field
        when singular_target
          doc[singular_target] = target_object unless join_type == :join_many
        when plural_target
          doc[plural_target] = target_objects if join_type == :join_many
        else
          doc["#{singular_target}_#{field}"] = target_object.try(field)
        end
      end
    end
  end
end
