require_relative '03_associatable'

module Associatable

  def has_one_through(name, through_name, source_name)

      define_method(name) do
        through_options = self.class.assoc_options[through_name]
        through_class = through_options.model_class

        source_options = through_class.assoc_options[source_name]

        through_table = through_options.table_name
        through_foreign_key = through_class.foreign_key
        through_primary_key = through_class.primary_key

        source_table = source_options.table_name
        source_foreign_key = source_options.foreign_key
        source_primary_key = source_options.primary_key

        source = DBConnection.execute(<<-SQL, self.send(through_foreign_key))
          SELECT
            #{source_table}.*
          FROM
            #{source_table}
          JOIN
            #{through_table}
          ON
            #{source_foreign_key} = #{source_table}.#{source_primary_key}
          WHERE
            #{through_table}.#{through_primary_key} = ?
        SQL

          source_options.model_class.parse_all(source).first
      end

  end
end
