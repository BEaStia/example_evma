namespace :redis do
  namespace :windows do
    desc "install redis on windows"
    task :install do
      %x(bin/redis-server.exe --service-install #{File.join("config", "redis.conf")})
    end

    desc "uninstall redis from windows"
    task :uninstall do
      %x(bin/redis-server.exe --service-uninstall)
    end

    desc "start redis in windows"
    task :start do
      %x(bin/redis-server --service-start)
    end

    desc "start redis in windows"
    task :stop do
      %x(bin/redis-server --service-stop)
    end
  end

  desc "install redis on linux"
  task :install_linux do
    %x(wget http://download.redis.io/redis-stable.tar.gz)
    %x(tar xvzf redis-stable.tar.gz)
    %x(cd redis-stable)
    %x(make)
    %x(cd utils)
    %x(sh install-server.sh)
  end
end

