# * Here you must define your `Factory` class.
# * Each instance of Factory could be stored into variable. The name of this variable is the name of created Class
# * Arguments of creatable Factory instance are fields/attributes of created class
# * The ability to add some methods to this class must be provided while creating a Factory
# * We must have an ability to get/set the value of attribute like [0], ['attribute_name'], [:attribute_name]
#
# * Instance of creatable Factory class should correctly respond to main methods of Struct
# - each
# - each_pair
# - dig
# - size/length
# - members
# - select
# - to_a
# - values_at
# - ==, eql?

class Factory
  class << self
    def new(*arguments, &block)
      const_set(arguments.shift.capitalize, create_class(*arguments, &block)) if arguments.first.is_a? String
      create_class(*arguments, &block)
    end

    def create_class(*arguments, &block)
      Class.new do
        attr_accessor(*arguments)
        class_eval(&block) if block_given?

        define_method :initialize do |*parameters|
          raise ArgumentError, "Wrong arguments quantity!" if arguments.size != parameters.size

          arguments.zip(parameters).each { |inst_var, value| instance_variable_set("@#{inst_var}", value) }
        end

        define_method :== do |instance|
          self.class == instance.class && self.values == instance.values
        end

        define_method :[] do |parameter|
          return instance_variable_get("@#{parameter}") if (parameter.is_a? String) || (parameter.is_a? Symbol)
          return instance_variable_get(instance_variables[parameter]) if parameter.is_a? Integer
        end

        define_method :[]= do |parameter, value|
          return instance_variable_set("@#{parameter}", value) if (parameter.is_a? String) || (parameter.is_a? Symbol)
          return instance_variable_set(instance_variables[parameter], value) if parameter.is_a? Integer
        end

        define_method :dig do |*parameters|
          to_h.dig(*parameters)
        end

        define_method :each do |&action|
          to_a.each(&action)
        end

        define_method :each_pair do |&action|
          to_h.each_pair(&action)
        end

        define_method :length do
          instance_variables.count
        end

        define_method :members do
          to_h.keys
        end

        define_method :values_at do |*selectors|
          selectors.map { |selector| values[selector] }
        end

        define_method :select do |&action|
          to_a.select(&action)
        end

        define_method :values do
          instance_variables.map { |inst_var| instance_variable_get(inst_var) }
        end

        define_method :to_h do
          Hash[
            instance_variables.map do |inst_var|
              key = inst_var.to_s.delete('@').to_sym
              value = instance_variable_get(inst_var)
              [key, value]
            end
          ]
        end

        define_method :to_a do
          to_h.values
        end

        alias_method :size, :length
        alias_method :eql?, :==
      end
    end
  end
end

Customer = Factory.new(:name, :age, :gender)
customer = Customer.new('andrei', 18, 'male')
