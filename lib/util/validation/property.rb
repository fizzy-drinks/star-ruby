module Star
  module Util
    module Validation
      Property = Struct.new(
        :name, :datatype, :required, :default_proc, keyword_init: true
      ) do
        def to_json(*)
          {name:, type: datatype, required:, has_default: !default_proc.nil?}.to_json(*)
        end
      end
    end
  end
end
