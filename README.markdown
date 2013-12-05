mongoid_many_or_many_to_many_setter
===================================
在Mongoid里，解决在_id主键存在情况下，通过另外一个uuid键来做多对多，一对多关系的兼容。

具体原因请见 doc/mongoid.markdown#多对多用uuid关联，对方保存的*_ids是uuid，而自己保存的*_ids是_id。

TODO
-----------------------------------
可是如果一开始把_id直接改写为uuid就无此问题
