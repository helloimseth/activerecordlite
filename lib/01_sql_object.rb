require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  def self.columns
    columns = DBConnection.execute2(<<-SQL)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
    SQL

    columns[0].map(&:to_sym)
  end

  def self.finalize!
    columns.each do |column|

      define_method("#{column}=") do |arg|
        attributes[column] = arg
      end

      define_method(column) { attributes[column] }
    end
  end

  def self.table_name=(table_name)
    self.instance_variable_set(:@table_name, table_name)
  end

  def self.table_name
    @table_name ||= self.inspect.tableize
  end

  def self.all
    raw_data_array = DBConnection.execute(<<-SQL)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
    SQL

    parse_all(raw_data_array)
  end

  def self.parse_all(results)
    [].tap do |parsed|
      results.each do |value_hash|
        new_object = self.new
        value_hash.each do |column, value|
          new_object.send("#{column}=", value)
        end
        parsed << new_object
      end
    end
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
      WHERE
        id = ?
    SQL

    parse_all(result).first
  end

  def initialize(params = {})
    params.each do |column, value|
      if !self.class.columns.include?(column)
        raise Exception.new "unknown attribute \'#{column}\'"
      end

      send("#{column}=", value)
    end
  end

  def attributes
    @attributes ||= Hash.new
  end

  def attribute_values
    self.class.columns.map { |column| send(column) }
  end

  def insert
     col_names = self.class.columns.join(", ")
     qmarks = (["?"] * self.class.columns.count).join(", ")

     DBConnection.execute(<<-SQL, attribute_values)
      INSERT INTO
        #{self.class.table_name}(#{col_names})
      VALUES
        (#{qmarks})
     SQL



     send(:id=, DBConnection.last_insert_row_id)
  end

  def update
    cols = self.class.columns.map {|attr_name| "#{attr_name} = ?"}.join(", ")
    attrs = attribute_values
    attrs << send(:id)

    DBConnection.execute(<<-SQL, attrs)
      UPDATE
        #{self.class.table_name}
      SET
        #{cols}
      WHERE
        id = ?
    SQL
  end

  def save
    send(:id).nil? ? insert : update
  end
end
