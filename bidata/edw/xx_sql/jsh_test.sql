
create table `jsh_test` (
  `id` int(11) default null comment 'id',
  `name` varchar(20) DEFAULT NULL COMMENT '名字'
) engine=innodb default charset=utf8;

insert into test.jsh_test values(11,'张三');
