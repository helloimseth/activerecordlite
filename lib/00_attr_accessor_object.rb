class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      ivar = "@#{name.to_s}"
      define_method(name) { instance_variable_get(ivar) }

      define_method("#{name}=") { |arg| instance_variable_set(ivar, arg) }
    end
  end
end
