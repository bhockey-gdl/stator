module Stator
  module Model

    def stator(options = {}, &block)

      class_attribute :_stators unless respond_to?(:_stators)

      include InstanceMethods   unless self.included_modules.include?(InstanceMethods)
      include TrackerMethods    if options[:track] == true

      self._stators ||= {}
      machine = (self._stators[options[:namespace].to_s] ||= ::Stator::Machine.new(self, options))

      if block_given?
        machine.instance_eval(&block)
        machine.evaluate
      end

      machine
    end

    def _stator(namespace)
      self._stators[namespace.to_s]
    end

    module TrackerMethods

      def self.included(base)
        base.class_eval do
          before_save :_stator_track_transition
        end
      end


      protected


      def _stator_track_transition

        self._stators.each do |namespace, machine|
          machine.integration(self).track_transition
        end

        true
      end

    end

    module InstanceMethods

      def self.included(base)
        base.class_eval do
          validate :_stator_validate_transition
        end
      end

      protected

      def _stator_validate_transition
        self._stators.each do |namespace, machine|
          machine.integration(self).validate_transition
        end
      end

      def _stator(namespace)
        self.class._stator(namespace)
      end

    end
  end
end
