多对多用uuid关联
================================

```ruby
class User
  has_and_belongs_to_many :classrooms, :primary_key => :uuid
end

class Classroom
  has_and_belongs_to_many :users, :primary_key => :uuid
end

@classroom.users = (@classroom.users + User.find((params[:classroom].delete(:user_ids) || []))).uniq # 这样直接导致Classroom#user_ids用的是_id, 而User#classroom_ids用的是uuid。
```

调试方法:

u2 = User.find(ids)
u2.push(Object)

```text
irb(main):009:0> @classroom.users = u2
NoMethodError: undefined method `id' for Object:Class
	from /usr/local/rvm/gems/ruby-1.9.3-p448@LocalCloud/bundler/gems/mongoid-67022f3f65de/lib/mongoid/relations/targets/enumerable.rb:62:in `<<'
	from /usr/local/rvm/gems/ruby-1.9.3-p448@LocalCloud/bundler/gems/mongoid-67022f3f65de/lib/mongoid/relations/referenced/many_to_many.rb:218:in `append'
	from /usr/local/rvm/gems/ruby-1.9.3-p448@LocalCloud/bundler/gems/mongoid-67022f3f65de/lib/mongoid/relations/referenced/many_to_many.rb:56:in `block in concat'
	from /usr/local/rvm/gems/ruby-1.9.3-p448@LocalCloud/bundler/gems/mongoid-67022f3f65de/lib/mongoid/relations/referenced/many_to_many.rb:54:in `each'
	from /usr/local/rvm/gems/ruby-1.9.3-p448@LocalCloud/bundler/gems/mongoid-67022f3f65de/lib/mongoid/relations/referenced/many_to_many.rb:54:in `concat'
	from /usr/local/rvm/gems/ruby-1.9.3-p448@LocalCloud/bundler/gems/mongoid-67022f3f65de/lib/mongoid/relations/referenced/many_to_many.rb:29:in `<<'
	from /usr/local/rvm/gems/ruby-1.9.3-p448@LocalCloud/bundler/gems/mongoid-67022f3f65de/lib/mongoid/relations/referenced/many_to_many.rb:185:in `substitute'
	from /usr/local/rvm/gems/ruby-1.9.3-p448@LocalCloud/bundler/gems/mongoid-67022f3f65de/lib/mongoid/relations/accessors.rb:265:in `block (2 levels) in setter'
	from /usr/local/rvm/gems/ruby-1.9.3-p448@LocalCloud/bundler/gems/mongoid-67022f3f65de/lib/mongoid/relations/accessors.rb:175:in `without_autobuild'
	from /usr/local/rvm/gems/ruby-1.9.3-p448@LocalCloud/bundler/gems/mongoid-67022f3f65de/lib/mongoid/relations/accessors.rb:263:in `block in setter'
	from (irb):9
	from /usr/local/rvm/gems/ruby-1.9.3-p448@LocalCloud/gems/railties-3.2.14/lib/rails/commands/console.rb:47:in `start'
	from /usr/local/rvm/gems/ruby-1.9.3-p448@LocalCloud/gems/railties-3.2.14/lib/rails/commands/console.rb:8:in `start'
	from /usr/local/rvm/gems/ruby-1.9.3-p448@LocalCloud/gems/railties-3.2.14/lib/rails/commands.rb:41:in `<top (required)>'
	from script/rails:6:in `require'
	from script/rails:6:in `<main>'
irb(main):010:0> 
563b79a33038", classroom_ids: ["15b7e25a-276c-4a5f-8aa6-0247ae2379f8", "94641ad5-f63b-43f4
```


[文件](mongoid/lib/mongoid/relations/referenced/many_to_many.rb) 

```ruby
def concat(documents)
  ids, docs, inserts = {}, [], []
  documents.each do |doc|
    next unless doc
    append(doc)
    if persistable? || _creating?
      ids[doc.id] = true
      save_or_delay(doc, docs, inserts)
    else
      existing = base.send(foreign_key)
      unless existing.include?(doc.id)
        existing.push(doc.id) and unsynced(base, foreign_key) # 这里直接存的是id，即是Mongoid的_id
      end
    end
  end
  if persistable? || _creating?
    base.push_all(foreign_key, ids.keys)
  end
  persist_delayed(docs, inserts)
  self
end
```




其他实例参考

```text
irb(main):034:0> Classroom.all.select {|a| !a.app_ids.blank? }[0].app_ids
=> ["5258bfb419e48c64fa0000a1", "5258bfb419e48c64fa0000a2", "5258bfb419e48c64fa0000a3", "5258bfb419e48c64fa0000a5", "5258bfb419e48c64fa0000a6", "5258bfb419e48cb9c6000047", "32ef6e46-7e63-4257-bc28-7f2206ca2ef5", "677907fb-0ae2-4e4d-8eb0-00c796b8b5ff", "a43d7dc7-0a65-464a-a8a8-68aff704554c", "035f5373-54a6-4d23-a5f7-6dd721f53860", "d20bb347-ea9b-4f51-b78c-6e30e6e7e333", "bd104137-94ab-406e-b6ed-b57cdc22e44e"]
irb(main):035:0> 
```



