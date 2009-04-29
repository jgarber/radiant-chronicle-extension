# http://github.com/tim/activerecord-diff/

module ActiveRecord
  module Diff

    module ClassMethods
      def diff(*attrs)
        write_inheritable_attribute(:diff_attrs, attrs)
      end

      def diff_attrs
        attrs = read_inheritable_attribute(:diff_attrs)

        if attrs.nil?
          content_columns.map { |column| column.name }
        elsif attrs.length == 1 && Hash === attrs.first
          columns = content_columns.map { |column| column.name.to_sym }

          columns + (attrs.first[:include] || []) - (attrs.first[:exclude] || [])
        else
          attrs
        end
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end

    def diff?(record = nil)
      not diff(record).empty?
    end

    def diff(other_record = nil)
      if other_record.nil?
        old_record, new_record = self.class.find(id), self
      else
        old_record, new_record = self, other_record
      end

      if new_record.is_a?(Hash)
        diff_each(new_record) do |(attr_name, hash_value)|
          [attr_name, old_record.send(attr_name), hash_value]
        end
      else
        diff_each(self.class.diff_attrs) do |attr_name|
          [attr_name, old_record.send(attr_name), new_record.send(attr_name)]
        end
      end
    end

    def diff_each(enum)
      enum.inject({}) do |diff_hash, attr_name|
        attr_name, old_value, new_value = *yield(attr_name)

        unless old_value === new_value
          diff_hash[attr_name.to_sym] = [old_value, new_value]
        end

        diff_hash
      end
    end

  end
end