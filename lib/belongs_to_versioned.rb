module LaserLemon
  module BelongsToVersioned
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        class << self
          alias_method_chain :belongs_to, :versioned
        end
      end
    end
    
    module ClassMethods
      def belongs_to_versioned(association_id, options = {})
        revert_to = options.delete(:revert_to) || association_id.to_s.foreign_key.gsub(/_id$/, '_version')
        
        belongs_to association_id, options
        
        define_method "#{association_id}_with_belongs_to_versioned" do
          parent = send("#{association_id}_without_belongs_to_versioned")
          target_version = case revert_to
            when String: read_attribute(revert_to) rescue nil
            when Symbol: send(revert_to) rescue nil
            end
          parent.revert_to(target_version) if target_version && parent.respond_to?(:revert_to)
          parent
        end
        
        alias_method_chain association_id, :belongs_to_versioned
        
        define_method "#{association_id}_with_belongs_to_versioned=" do |parent|
          write_attribute(revert_to, (parent.respond_to?(:version) ? parent.version : nil)) if revert_to.is_a?(String)
          send("#{association_id}_without_belongs_to_versioned=", parent)
        end
        
        alias_method_chain "#{association_id}=", :belongs_to_versioned
      end
      
      def belongs_to_with_versioned(a, o = {})
        o.delete(:versioned) ? belongs_to_versioned(a, o) : belongs_to_without_versioned(a, o)
      end
    end
  end
end

ActiveRecord::Base.send(:include, LaserLemon::BelongsToVersioned)
