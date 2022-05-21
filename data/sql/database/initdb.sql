-- выводим список баз дынных
\l
-- cоздаём базу данных, если еще её нет
create database edtech_hd_back;
-- выводим список пользователей
\du
-- создаём пользователя, если еще нет
\set euser `echo "$USER"`
create user :euser with login password '12345';