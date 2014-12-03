---
title: Oracle 11g XE on RHEL7
date: December 3, 2014
tags: database
description: Install oracle 11g xe on RHEL7 and do experiment on it
---

The prerequisite is i assume you already got a RHEL7 installed with GNOME3

## Install oracle database

it needs swap volume at least specify space
``` bash
unzip oracle-xe-11.2.0-1.0.x86_64.rpm.zip
cd Disk1
sudo rpm -ivh oracle-xe-11.2.0-1.0.x86_64.rpm
```

## Install sqlplus
``` bash
sudo rpm -ivh oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm
sudo rpm -ivh oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm
```

If you got the error below, you need to add library path manually:
sqlplus64: error while loading shared libraries: libsqlplus.so: cannot open shared object file: No such file or directory
``` bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/oracle/12.1/client64/lib/
```

## Install sqldeveloper (Optional)
Install jdk
``` bash
sudo rpm -ivh jdk-7u72-linux-x64.rpm
sudo rpm -ivh sqldeveloper-4.0.3.16.84-1.noarch.rpm
```

Update JDK_HOME to SetJavaHome in:
~/.sqldeveloper/4.0.0/product.conf

Add the command below to /usr/local/bin/sqldeveloper:
unset GNOME_DESKTOP_SESSION_ID

## Login to APEX (Optional)

http://localhost:8080/apex/apex_admin

if you forgot the admin password, you can change it follow the [steps][apex]

## How to restart database
``` bash
/etc/init.d/oracle-xe restart
```

## Do experiment for Joel Spolsky's "The Law of Leaky Abstractions"
``` sql
-- create new tablespace
create tablespace DATA
  datafile '/u01/app/oracle/oradata/XE/data.dbf'
  size 1024m
  autoextend on
  next 10m maxsize 10240m
  extent management local;

-- create new user
create user wshi
  identified by "redhat"
  default tablespace "DATA"
  temporary tablespace "TEMP"
  profile DEFAULT;

-- grant enough permissions
GRANT "CONNECT" TO wshi;
GRANT "DBA" TO wshi;
GRANT "RESOURCE" TO wshi;

-- create three tables
create table table_a (id NUMBER(10), value VARCHAR2(10));
create table table_b (id NUMBER(10), value VARCHAR2(10));
create table table_c (id NUMBER(10), value VARCHAR2(10));

-- insert 5000 records to each table
declare
  v_id       number(10);
  strSql     varchar2(1000);
begin
  for i in 1 .. 5000 loop
    strSql := 'insert into table_a(id, value) values (' || i || ', ''' || abs(mod(dbms_random.random,100)) || ''')';
    execute immediate strSql;
    strSql := 'insert into table_b(id, value) values (' || i || ', ''' || abs(mod(dbms_random.random,100)) || ''')';
    execute immediate strSql;
    strSql := 'insert into table_c(id, value) values (' || i || ', ''' || abs(mod(dbms_random.random,100)) || ''')';
    execute immediate strSql;
  end loop;
end;
/

commit;

-- enble executioin plan after sql executed
SET AUTOTRACE ON EXPLAIN STATUS;

-- compare the differents between the following two SQL
select count(*) from table_a a, table_b b, table_c c where a.id = b.id and b.id = c.id;
select count(*) from table_a a, table_b b, table_c c where a.id = b.id and b.id = c.id and c.id = a.id;

```

Here are the execution plans, and we could find the join method and the join
condition is quite different, also we need to consider the table analysis and
the env(record amount, memory etc) would affect the result, but generally the
second SQL runs dramatically faster than the first one.

```
  COUNT(*)
----------
      5000

Plan hash value: 2792619341

----------------------------------------------------------------------------------
| Id  | Operation              | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------
|   0 | SELECT STATEMENT       |         |     1 |    39 |   688   (1)| 00:00:09 |
|   1 |  SORT AGGREGATE        |         |     1 |    39 |            |          |
|*  2 |   HASH JOIN            |         |     1 |    39 |   688   (1)| 00:00:09 |
|   3 |    MERGE JOIN CARTESIAN|         |     1 |    26 |   686   (1)| 00:00:09 |
|   4 |     TABLE ACCESS FULL  | TABLE_A |     1 |    13 |   684   (1)| 00:00:09 |
|   5 |     BUFFER SORT        |         |     1 |    13 |     2   (0)| 00:00:01 |
|   6 |      TABLE ACCESS FULL | TABLE_C |     1 |    13 |     2   (0)| 00:00:01 |
|   7 |    TABLE ACCESS FULL   | TABLE_B |     1 |    13 |     2   (0)| 00:00:01 |
----------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("A"."ID"="B"."ID" AND "B"."ID"="C"."ID")

  COUNT(*)
----------
      5000

Plan hash value: 4050381587

--------------------------------------------------------------------------------
| Id  | Operation            | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |         |     1 |    39 |   689   (1)| 00:00:09 |
|   1 |  SORT AGGREGATE      |         |     1 |    39 |            |          |
|*  2 |   HASH JOIN          |         |     1 |    39 |   689   (1)| 00:00:09 |
|*  3 |    HASH JOIN         |         |     1 |    26 |   686   (1)| 00:00:09 |
|   4 |     TABLE ACCESS FULL| TABLE_A |     1 |    13 |   684   (1)| 00:00:09 |
|   5 |     TABLE ACCESS FULL| TABLE_B |     1 |    13 |     2   (0)| 00:00:01 |
|   6 |    TABLE ACCESS FULL | TABLE_C |     1 |    13 |     2   (0)| 00:00:01 |
--------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("B"."ID"="C"."ID" AND "C"."ID"="A"."ID")
   3 - access("A"."ID"="B"."ID")

```

## Conclusion

Philosophically speaking, SQL (as an abstraction) was meant to hide all aspects
of implementation. It was meant to be declarative (a SQL server can itself use
sql query optimization techniques to rephrase the query to make them more
efficient). But in the real world it is not so - often the database queries
have to be rewritten by humans to make them more efficient.


[apex]: http://www.oracle.com/webfolder/technetwork/tutorials/obe/db/11g/r2/prod/install/apexinst/apexinst_prod.htm
