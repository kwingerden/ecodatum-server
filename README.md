# Ecodatum web application server

## Ubuntu 16.04 Installation

1. Add Vapor's APT repo:

```bash
eval "$(curl -sL https://apt.vapor.sh)"
```

2. Install Git, Vapor, Swift and Supervisor

```bash
sudo apt-get install git swift vapor supervisor
```

3. Clone EcoDatum WWW server:

```bash
git clone https://github.com/kwingerden/ecodatum-www-server.git
```

4. Change directory 

```bash
cd ecodatum-www-server
```

5. Build Vapor project 

```bash
vapor build
```

6. Create Supervisor configuration file: `sudo /etc/supervisor/conf.d/ecodatum-www-server.conf` with the following content:

```ini
[program:ecodatum-www-server]
command=vapor run --env=production
directory=/home/ubuntu/ecodatum-www-server/          
autorestart=true
user=ubuntu
stdout_logfile=/var/log/supervisor/%(program_name)-stdout.log
stderr_logfile=/var/log/supervisor/%(program_name)-stderr.log
```

7. Update Supervisor configuration with the following commands:

```bash
sudo supervisorctl reread
sudo supervisorctl add ecodatum-www-server
sudo supervisorctl start ecodatum-www-server
```

8. The server should now be running on `0.0.0.0:8080`. The port and IP can be changed in the `Config/server.json` file.
