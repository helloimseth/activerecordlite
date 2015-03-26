require_relative '02_searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    "#{class_name.to_s.underscore}s"
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    default = {class_name: "#{name.to_s}".camelcase,
               foreign_key: "#{name.to_s.underscore}_id".to_sym,
               primary_key: :id}
    options = default.merge(options)

    @name = name
    @class_name = options[:class_name]
    @foreign_key = options[:foreign_key]
    @primary_key = options[:primary_key]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    default = {class_name: "#{name.to_s.singularize.camelcase}",
               foreign_key: "#{self_class_name
                               .singularize
                               .to_s.underscore}_id".to_sym,
               primary_key: :id}

    options = default.merge(options)

    @name = name
    @class_name = options[:class_name]
    @foreign_key = options[:foreign_key]
    @primary_key = options[:primary_key]
  end
end

module Associatable
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options

    define_method(name) do
      foreign_key = options.send(:foreign_key)
      class_name = options.model_class
      class_name.where(id: self.send(foreign_key)).first
    end
  end

  def has_many(name, options = {})

    options = HasManyOptions.new(name, self.table_name, options)

    define_method(name) do
      foreign_key = options.send(:foreign_key)

      class_name = options.model_class
      primary_key = self.send(:id)

      results = class_name.where(foreign_key => primary_key)
    end
  end

  def assoc_options
    @assoc_options ||= Hash.new {|h, k| h[k] = []}
  end
end

class SQLObject
  extend Associatable
end
