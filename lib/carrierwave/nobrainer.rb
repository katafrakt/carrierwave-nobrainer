require "carrierwave/nobrainer/version"

module CarrierWave
  module NoBrainer

    def self.included(base)
      base.send(:extend, ClassMethods)
    end

    module ClassMethods
      include CarrierWave::Mount

      def mount_uploader(column, uploader, options={}, &block)
        super

        alias_method :read_uploader, :_read_attribute
        alias_method :write_uploader, :_write_attribute

        after_save :"store_#{column}!"
        before_save :"write_#{column}_identifier"
        after_destroy :"remove_#{column}!", :on => :destroy
        after_update :"mark_remove_#{column}_false", :on => :update
        before_update :"store_previous_model_for_#{column}"
        after_save :"remove_previously_stored_#{column}"

        define_method(:"#{column}=") do |file|
          attribute_may_change(column.to_sym)
          super(file)
        end
      end
    end
  end
end
