require "carrierwave/nobrainer/version"

module CarrierWave
  module NoBrainer
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

      class_eval <<-RUBY, __FILE__, __LINE__+1
      def #{column}=(new_file)
        attribute_may_change(:#{column})
        super
      end
      RUBY
    end
  end
end
