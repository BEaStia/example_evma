namespace :db do

  #При каждом заходе в postgres будет записываться инфа о вошедшем юзере
  desc "create tables"
  task :create_tables do
    DB.query('create table entries (
      id serial PRIMARY KEY,
      sid varchar(50),
      browser varchar(50),
      browser_version varchar(50),
      mobile boolean,
      bot boolean,
      os varchar(50),
      platform varchar(50),
      country varchar(5),
      ip inet,
      node inet,
      first_visit timestamp,
      last_visit timestamp)')

    DB.query("create table errors(
        id serial PRIMARY KEY,
        sid varchar(50),
        ip inet,
        old_node inet,
        new_node inet
      )")
  end

  desc "drop tables"
  task :drop_tables do
    DB.query("drop table entries")
    DB.query("drop table errors")
  end
end