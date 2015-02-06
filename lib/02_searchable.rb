require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_params = params.keys.map {|col| "#{col} = :#{col}" }.join(" AND ")

    result = DBConnection.execute(<<-SQL, params)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
      WHERE
        #{where_params}
    SQL

    parse_all(result)
  end
end

class SQLObject
  extend Searchable
end
