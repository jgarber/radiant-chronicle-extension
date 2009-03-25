module Chronicle::VersionExtensions
  # Return an instance of the versioned ActiveRecord model with the attribute
  # values and page parts of this version.  Initializes it just like #find so 
  # you can compare objects.
  def instance
    attributes = YAML::load( self.yaml )
    associations = (attributes.keys - versionable.class.column_names).map {|k| [k,attributes[k]] }

    obj = versionable.class.send(:instantiate, attributes)
    associations.each do |var_name,var_value|
      obj.__send__( "#{var_name}=", var_value )
    end
    obj
  end
  
end