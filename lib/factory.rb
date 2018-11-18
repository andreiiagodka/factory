# frozen_string_literal: true

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
          raise ArgumentError, 'Wrong arguments quantity!' if arguments.size != parameters.size

          arguments.zip(parameters).each { |inst_var, value| instance_variable_set("@#{inst_var}", value) }
        end

        define_method :== do |instance|
          self.class == instance.class && values == instance.values
        end

        define_method :[] do |parameter|
          return instance_variable_get(instance_variables[parameter]) if parameter.is_a? Integer

          instance_variable_get("@#{parameter}")
        end

        define_method :[]= do |parameter, value|
          return instance_variable_set(instance_variables[parameter], value) if parameter.is_a? Integer

          instance_variable_set("@#{parameter}", value)
        end

        define_method :dig do |*parameters|
          digged = to_h
          loop do
            digged = digged[parameters.shift]
            return digged if digged.nil? || parameters.empty?
          end
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
          Hash[arguments.zip(values)]
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
