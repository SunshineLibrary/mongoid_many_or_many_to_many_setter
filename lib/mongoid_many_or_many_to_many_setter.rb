# encoding: UTF-8

require 'mongoid'

module ::Mongoid
  module ManyOrManytomanySetter
    extend ActiveSupport::Concern

    included do
      before_save :many_or_many_to_many_setter
    end

    def many_or_many_to_many_setter
      item = self
      item.class.relations.select do |rel1, meta1|
        # 只有一对多，多对多有此问题
        [Mongoid::Relations::Referenced::ManyToMany, Mongoid::Relations::Referenced::Many].include?(meta1.relation) &&
          # 确保关联key是标准的_ids结尾
          meta1.key.match(/_ids/)
      end.each do |rel1, meta1|
        array1 = item.send(meta1.key)
        next if array1.blank?

        # 只判断第一个即可
        if Utils.is_id? array1[0]
          puts "[ManyOrManytomanySetter][#{meta1.relation}][#{meta1.class_name}] Fix #{item.class} #{item.uuid}"
          # TODO 通过配置主键方式读取 uuid
          # item.write_attribute meta1.key, meta1.class_name.constantize.find(array1).map(&:uuid) # 当时有效，但是之后再Model.find后又变回原样了
          item.send "#{meta1.key}=", meta1.class_name.constantize.find(array1).map(&:uuid)
        end
      end
    end

    module Utils; end
    # 直接这样判断长度的简单的判断就好
    # _id    : '528dba704f14f0bdea000001'.size             => 24
    # uuid   : 'f2c5d023-fe0a-4dae-be0e-7a387c99924f'.size => 36
    def Utils.is_id?   str; str.to_s.size == 24; end
    def Utils.is_uuid? str; str.to_s.size == 36; end

  end
end
