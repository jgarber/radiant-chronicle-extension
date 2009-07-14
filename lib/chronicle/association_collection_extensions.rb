module Chronicle
  module AssociationCollectionExtensions
    def self.included(base)
      base.class_eval do
        alias_method_chain :find, :draft_versioning
      end
    end
    
    # Extended because children_find_options_with_draft_versioning is injecting an extra option
    # that must be removed and acted upon if present.
    def find_with_draft_versioning(*args)
      current = args[1].delete(:current) if args[1]
      result = find_without_draft_versioning(*args)
      if result && current
        result.map {|versionable| versionable.current }
      else
        result
      end
    end
  end
end