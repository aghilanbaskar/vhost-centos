# VHost-Centos

Bash script to automate the apache virtual host setup and enabling HTTPS for domain  using [Let’s Encrypt](https://letsencrypt.org/) and [CertBot](https://certbot.eff.org/) in centos

This bash script is totally automated the below two tutorials.

[how-to-install-the-apache-web-server-on-centos-7](https://www.digitalocean.com/community/tutorials/how-to-install-the-apache-web-server-on-centos-7)

[how-to-secure-apache-with-let-s-encrypt-on-centos-7](https://www.digitalocean.com/community/tutorials/how-to-secure-apache-with-let-s-encrypt-on-centos-7)


## Installation

```sh
wget https://raw.githubusercontent.com/aghilanbaskar/vhost-centos/main/virtual-host.sh
```

## Usage

Run the bash script
```sh
./virtual-host.sh
```
It will asking for domain name. Enter your domain name. That's it.

**Please make sure you have pointed out your A record in DNS to the VM your are going to run this script.**

## Contributing
Pull requests are welcome.

## License
[MIT](https://raw.githubusercontent.com/aghilanbaskar/vhost-centos/main/LICENSE)
