### apache2 webserver with Let's Encrypt on Ubuntu
## test commit ##
Hello world
[Let's Encrypt](https://github.com/letsencrypt/letsencrypt) is a service generating HTTPS certificates for you and installing them in your apache2 webserver.

### Use with own Dockerfile  
Start with creating a Dockerfile  
`FROM whiledo/letsencrypt-apache-ubuntu`  
`... deploy your app, or do other stuff`  
`CMD ["apache2ctl", "-D", "FOREGROUND"]`  

build it with  
`docker build -t myname/myapp .`  
(Be sure to be in the directory of your Dockerfile)

run with  
`docker run -d --name myappcontainer -p 80:80 -p 443:443 myname/myapp`  

### Just run without new Dockerfile  
if you don't want to create a Dockerfile, you can just run  
`docker run -d --name myappcontainer -p 80:80 -p 443:443 whiledo/letsencrypt-apache-ubuntu`

### Install the https certificate  
It is important to expose port 80, because the Let's Encrypt Server will try to find yourwebsite.org:80  

Now log in to the running container  
`docker exec -it myappcontainer /bin/bash`  

And install the https certificate  
`/data/letsencrypt/letsencrypt-auto --apache --email your@email.org --agree-tos -d yourwebsite.org`  

### I don't want to run on ports 80 and 443  
Let's Encrypt wants you to make ports 80 and 443 available when running the automatic installer.  
If you don't want to expose ports 80 and 443, you could generate the certificates and install them in the apache server manually.  
Look in the [Let's Encrypt Repository](https://github.com/letsencrypt/letsencrypt) for more information.
It is a command starting with `/letsencrypt-auto certonly --standalone ...`.  


When you want to run the automatic installer, you can use a trick.  
Let's say you want 9980 to be your HTTP port and 9981 to be your HTTPS port.  

We'll use the [docker-forward](https://hub.docker.com/r/njohnson/docker-forward/) image provided by njohnson to forward TCP traffic. The images is based on socat.  

We create a container forwarding TCP traffic from port 80 to 9980  
`docker run -d --name forward80 -p 80:80 --env PORT_LOCAL=80 --env ADDRESS_REMOTE=yourwebsite.org --env PORT_REMOTE=9980 njohnson/docker-forward`  

and a container forwarding TCP traffic from port 443 to 9981
`docker run -d --name forward443 -p 443:443 --env PORT_LOCAL=443 --env ADDRESS_REMOTE=yourwebsite.org --env PORT_REMOTE=9981 njohnson/docker-forward`  

Now go on with the steps at "Install the https certificate".  

After finishing stop the forward-containers  
`docker stop forward80 && docker rm forward80 && docker stop forward443 && docker rm forward443`  
### generate certs  

``` /data/letsencrypt/letsencrypt-auto --apache --email admin@qubeship.io --domains api-admin.qubeship.io,api-registry.qubeship.io,api.qubeship.io,app.qubeship.io,builder.qubeship.io,consul.qubeship.io,gateway.qubeship.io,jenkins.qubeship.io,listener.qubeship.io,platform.qubeship.io,qubeship.com,qubeship.io,sg.qubeship.io,try.qubeship.io,vault.qubeship.io,www.qubeship.com,www.qubeship.io,northerntrust.listener.qubeship.io,northerntrust.receiver.qubeship.io,northerntrust.app.qubeship.io,northerntrust.builder.qubeship.io,northerntrust.api-registry.qubeship.io,ca.listener.qubeship.io,ca.receiver.qubeship.io,ca.app.qubeship.io,ca.builder.qubeship.io,ca.api-registry.qubeship.io
```

### Push / Read Certs
We use the Vault as the secret storage.
* to write certs:  
``for file in `ls`; do vault write secret/resources/qubeship/certs/$file value=@${file} ; done``
* to read certs:  
```
export VAULT_TOKEN = vault master token
export VAULT_ADDRESS=internal vault service address
cd /etc/letsencrypt/keys
for key in `vault list secret/resources/qubeship/certs | grep -v Keys | grep -v \-`; do vault read -field=value secret/resources/qubeship/certs/$key > $key; done
```

### occasional problems
flushing dns cache : https://developers.google.com/speed/public-dns/cache  
apache settings on mods-enabled/mpm_event.conf
        ServerLimit          200
        StartServers                     3
        MinSpareThreads          75
        MaxSpareThreads          250
        MaxClients               5000
        ThreadLimit                      64
        ThreadsPerChild          25
        MaxRequestWorkers         5000
        MaxConnectionsPerChild   5000
