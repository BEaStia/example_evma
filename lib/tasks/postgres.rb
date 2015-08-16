namespace :db do

  #При каждом заходе в postgres будет записываться инфа о вошедшем юзере
  desc "create tables"
  task :create_table do
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
      node inet)')
  end

  desc "drop table"
  task :drop_table do
    DB.query("drop table entries")
  end
end