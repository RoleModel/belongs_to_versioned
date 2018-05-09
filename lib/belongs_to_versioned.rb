module LaserLemon
  module BelongsToVersioned
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        class << self
          alias_method :belongs_to_without_versioned, :belongs_to
          alias_method :belongs_to, :belongs_to_with_versioned
        end
      end
    end

    module ClassMethods
      def belongs_to_versioned(target, scope = nil, **options)
        revert_to = (scope.is_a?(Hash) ? scope : options).delete(:revert_to)
        revert_to = revert_to || target.to_s.foreign_key.gsub(/_id$/, '_version')

        result = belongs_to target, scope, options

        define_method "#{target}_with_belongs_to_versioned" do
          parent = send("#{target}_without_belongs_to_versioned")
          target_version = case revert_to
            when String then read_attribute(revert_to) rescue nil
            when Symbol then send(revert_to) rescue nil
            end
          parent.revert_to(target_version) if target_version && parent.respond_to?(:revert_to)
          parent
        end

        alias_method "#{target}_without_belongs_to_versioned", target
        alias_method target, "#{target}_with_belongs_to_versioned"

        define_method "#{target}_with_belongs_to_versioned=" do |parent|
          write_attribute(revert_to, (parent.respond_to?(:version) ? parent.version : nil)) if revert_to.is_a?(String)
          send("#{target}_without_belongs_to_versioned=", parent)
        end

        alias_method "#{target}_without_belongs_to_versioned=", "#{target}="
        alias_method "#{target}=", "#{target}_with_belongs_to_versioned="

        result
      end

      def belongs_to_with_versioned(target, scope = nil, **options)
        versioned = (scope.is_a?(Hash) ? scope : options).delete(:versioned)
        scope = nil if scope && scope.empty?
        if versioned
          belongs_to_versioned(target, scope, options)
        else
          if scope && scope.is_a?(Hash)
            options = scope.dup
            scope = nil
          end
          belongs_to_without_versioned(target, scope, options)
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, LaserLemon::BelongsToVersioned)
