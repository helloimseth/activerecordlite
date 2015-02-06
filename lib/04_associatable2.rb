require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)

      human = assoc_options[through_name]
      # p through_options

      human_class = human.model_class

      define_method(name) do
        house = human_class.assoc_options[source_name]

        owner_id = human.foreign_key
        human_id = human.primary_key

        # human_inst = Human.find(self.send(owner_id))

        human_house_id = house.foreign_key
        house_class = house.model_class
        house_id = house.primary_key

        #self is cat instance

        self.send(through_name).send(source_name)

        # house_class.where(house_id => human_house_id,
        #                   human_id => self.send(owner_id))
      end

  end
end
