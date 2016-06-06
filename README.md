**lcget** is a wrapper (written in [Tcl/expect](https://en.wikipedia.org/wiki/Expect)) for letsencrypt which automates the task of completing challenges for remote server/domains from a local machine. It relieves you of the pain of running multiple commands in multiple terminals. Most of the time, a single command in a single terminal will be enough to get the certificate from Let's Encrypt. It doesn't require sudo access on remote host if the document root is in /home directory i.e for shared hosting.

#Mechanism:
**lcget** is an [expect](https://en.wikipedia.org/wiki/Expect) script which runs the letsencrypt command and monitor its' output. When the challenge appears on the output of `letsencrypt` command, the script parses necessary information about the challenge and tries to complete the challenge itself.

To complete the http challenge in manual mode, **lcget** requires ssh access to the remote host i.e it runs ssh commands to the remote host to meet the necessary requirements for the acme challenge.

Currently, only the **http challenge in manual mode** is supported.


#Dependencies:
The script depends on the following tools/scripts:

1. **letsencrypt (certbot):** The letsencrypt tool itself.
2. **expect:** You may need to install this first if not installed.
2. **ssh:** It is installed by default in most Unix based system.
3. **jssh:** It is a wrapper to automate ssh login and/or running ssh commands.

**To install jssh, download the [jssh script](https://github.com/neurobin/jssh) and put it in a bin directory which is in the PATH environment variable (e.g */usr/bin*)**. The **lcget** script uses `jssh` command to execute it by default. You can run **jssh** from any arbitrary path too; in that case, use the the **lcget** option `-jp` to provide the jssh path. For example:
```sh
lcget certonly --manual -d example.com -m mymail@example.com -jp /path/to/jssh
```

#Install:

First you will need to give execution permission to the script. An octal `755` permission is recommended.

* You can run the script with full path or with `./lcget` by `cd`ing into the directory where it resides.
* You can just copy the script into a standard bin directory (e.g */usr/bin*).
* Or you can run the *install.sh* script which tries to install it in *~/bin* along with **jssh**.

##Installing examples:

*Installing in /usr/bin* :

```sh
chmod 755 path/to/lcget
sudo cp path/to/lcget /usr/bin
```
*Installing in ~/bin* :
```sh
chmod 755 path/to/lcget
cp path/to/lcget $HOME/bin
#Now add $HOME/bin to PATH environment variable if not added already
var=$HOME/bin
if ! echo $PATH | grep -q  ":$var\([/:]\|$\)"; then echo "export PATH=\$PATH:$var" >> ~/.bashrc && . ~/.bashrc ;fi
```
##Note:
**If the script isn't recognized as an executable by the system**, then you may try the `lcget-sh` script provided. Furthermore, you can change the path of `lcget` to the actual path inside the `lcget-sh` script:
```sh
#!/bin/sh
expect /actual/path/to/lcget ${1+"$@"}
```
and install `lcget-sh` instead of `lcget`. In this case, you will be using `lcget-sh` as the **lcget** command.

**Or** you can try fixing the shebang line (`#!/usr/bin/expect --`) to the correct one for an expect script if it is supported (don't forget the `--` part though).

#Usage:

```
lcget [native or letsencrypt options]
```
**native options:** These are the options parsed and recognized by lcget. These are:

* **--launcher-path, -lp :** Launcher path. You can define the letsencrypt launcher path with this option.
* **-jssh-path, -jp :** Arbitrary **jssh** path. If given **jssh** will be run with the full path specified.
* **--help, -h :** This is a mixed option. It will print both **lcget** and **letsencrypt** help.
* **--version:** This is a mixed option. It will print version info for both **lcget** and **letsencrypt**.

**letsencrypt options:** These are the options recognized by letsencrypt. These options are same as the options supported by the letsencrypt launcher.


#How to:
We will need to prepare a **jssh** config file for each of the domains we want to get Let's Encrypt ssl certificate for. We will do this just once, after that we will be running the `lcget` command only.

##Create jssh config file:

The config file must follow the naming convention: **domain.conf** e.g *example.com.conf* for example.com, *www.example.com.conf* for www.example.com etc...

To create a **jssh config file** run `jssh -aw -c` in a terminal and fill out necessary information. For example:

```
~$ jssh -aw -c

    Give an easy and memorable name to your config file, something like example.com.
    Later you will call jssh with this name to login to remote.
    
Enter config file name (without .conf): 
example.com
Overwrite (y/n)?: 
y
Enter domain/IP: 
example.com
Enter port number: 
22
Enter username: 
neurobin

    If a working directory is specified, jssh -cdw example.com
    will run cd WorkDir just after logging in.
    
Enter working directory: 
$HOME/public_html

    Saved as: /home/user/.neurobin/jssh/example.com.conf
    You will call jssh for this configuration like this:
    jssh example.com other_ssh_options_or_args
    'jssh example.com' is the native jssh part. All other arguments
    will be forwarded to ssh command. Any jssh native option
    must be passed before example.com.
    You can edit the config file to make further changes.
    

    Additional: /home/user/.neurobin/jssh/www.example.com.conf
```
This will create a config file for *example.com* and also for `www.example.com` with the same configuration ( because of the `-aw` flag passed with jssh). 

**You must give the document root of your domain as the working directory.**

As *www.example.com* generally points to *example.com* i.e the config for both of them are same, we could create a symbolic link named `www.example.com.conf` too instead of actual file.

You will need to create **jssh config file** for each of your domains. 

For sub-domains you can just create *subdomain.rootdomain.conf* file with the same credentials as rootdomain except the working directory; working directory must be the document root of the subdomain/domain. In this case ssh will login with the credentials of root domain.

**Note:** 

* The config file stores username, port, domain name/IP and working directory (in this case document root).

##Run lcget and get the certificate:
Now all we have to do is to run the `lcget` command with appropriate options. The following is an example which uses a letsencrypt configuration file (All outputs are shown):

```sh
~$ lcget certonly -c neurobin.conf
Requesting root privileges to run certbot...
  /home/user/.local/share/letsencrypt/bin/letsencrypt --text certonly -c neurobin.conf
[sudo] password for user: 
Make sure your web server displays the following content at
http://challenge.neurobin.org/.well-known/acme-challenge/s3xMuDO7WwjTUX6pbAq8hj1Ixpf4V-Rin9FBmdHDV14 before continuing:

s3xMuDO7WwjTUX6pbAq8hj1Ixpf4V-Rin9FBmdHDV14.fl_1v9fRIhdgCXPAMg0ohwMfX66pkSQ_eTJjm2tejZc

If you don't have HTTP server configured, you can run the following
command on the target server (as root):

mkdir -p /tmp/certbot/public_html/.well-known/acme-challenge
cd /tmp/certbot/public_html
printf "%s" s3xMuDO7WwjTUX6pbAq8hj1Ixpf4V-Rin9FBmdHDV14.fl_1v9fRIhdgCXPAMg0ohwMfX66pkSQ_eTJjm2tejZc > .well-known/acme-challenge/s3xMuDO7WwjTUX6pbAq8hj1Ixpf4V-Rin9FBmdHDV14
# run only once per server:
$(command -v python2 || command -v python2.7 || command -v python2.6) -c \
"import BaseHTTPServer, SimpleHTTPServer; \
s = BaseHTTPServer.HTTPServer(('', 80), SimpleHTTPServer.SimpleHTTPRequestHandler); \
s.serve_forever()" 
Press ENTER to continue

Protocol: http://
Domain: challenge.neurobin.org
File: .well-known/acme-challenge/s3xMuDO7WwjTUX6pbAq8hj1Ixpf4V-Rin9FBmdHDV14
Content: s3xMuDO7WwjTUX6pbAq8hj1Ixpf4V-Rin9FBmdHDV14.fl_1v9fRIhdgCXPAMg0ohwMfX66pkSQ_eTJjm2tejZc

Trying to complete challenge for challenge.neurobin.org

Completing challenge...
Created dir : .well-known/acme-challenge
Created file: .well-known/acme-challenge/s3xMuDO7WwjTUX6pbAq8hj1Ixpf4V-Rin9FBmdHDV14

Done for challenge.neurobin.org

Make sure your web server displays the following content at
http://www.challenge.neurobin.org/.well-known/acme-challenge/DKCumvxBheZMe_cfxA83uhIA7OrTu9RZBdxxaMEbAJ8 before continuing:

DKCumvxBheZMe_cfxA83uhIA7OrTu9RZBdxxaMEbAJ8.fl_1v9fRIhdgCXPAMg0ohwMfX66pkSQ_eTJjm2tejZc

If you don't have HTTP server configured, you can run the following
command on the target server (as root):

mkdir -p /tmp/certbot/public_html/.well-known/acme-challenge
cd /tmp/certbot/public_html
printf "%s" DKCumvxBheZMe_cfxA83uhIA7OrTu9RZBdxxaMEbAJ8.fl_1v9fRIhdgCXPAMg0ohwMfX66pkSQ_eTJjm2tejZc > .well-known/acme-challenge/DKCumvxBheZMe_cfxA83uhIA7OrTu9RZBdxxaMEbAJ8
# run only once per server:
$(command -v python2 || command -v python2.7 || command -v python2.6) -c \
"import BaseHTTPServer, SimpleHTTPServer; \
s = BaseHTTPServer.HTTPServer(('', 80), SimpleHTTPServer.SimpleHTTPRequestHandler); \
s.serve_forever()" 
Press ENTER to continue

Protocol: http://
Domain: www.challenge.neurobin.org
File: .well-known/acme-challenge/DKCumvxBheZMe_cfxA83uhIA7OrTu9RZBdxxaMEbAJ8
Content: DKCumvxBheZMe_cfxA83uhIA7OrTu9RZBdxxaMEbAJ8.fl_1v9fRIhdgCXPAMg0ohwMfX66pkSQ_eTJjm2tejZc

Trying to complete challenge for www.challenge.neurobin.org

Completing challenge...
Created dir : .well-known/acme-challenge
Created file: .well-known/acme-challenge/DKCumvxBheZMe_cfxA83uhIA7OrTu9RZBdxxaMEbAJ8

Done for www.challenge.neurobin.org


IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at
   /etc/letsencrypt/live/challenge.neurobin.org/fullchain.pem. Your
   cert will expire on 2016-09-04. To obtain a new or tweaked version
   of this certificate in the future, simply run letsencrypt again. To
   non-interactively renew *all* of your certificates, run
   "letsencrypt renew"
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le


```
The *neurobin.conf* file:

```sh
# This is an example of the kind of things you can do in a configuration file.
# All flags used by the client can be configured here. Run Lets Encrypt with
# --help to learn more about the available options.
config-dir = /etc/letsencrypt
work-dir = /home/user/.letsencrypt
logs-dir = /home/user/.letsencrypt
# Use a 4096 bit RSA key instead of 2048
rsa-key-size = 4096

# Uncomment and update to register with the specified e-mail address
email = admin@neurobin.org

# Uncomment and update to generate certificates for the specified domains.
#Add subdomains or domains however you like. My recommendation is to put the root domain at beginning.
domains = challenge.neurobin.org, www.challenge.neurobin.org


# Uncomment to use a text interface instead of ncurses
# Do not change this
# The expect script works with text interface.
text = True

# Uncomment to use the standalone authenticator on port 443
# authenticator = standalone
# standalone-supported-challenges = tls-sni-01

# Uncomment to use the webroot authenticator. Replace webroot-path with the
# path to the public_html / webroot folder being served by your web server.
# authenticator = webroot
# webroot-path = /usr/share/nginx/html

authenticator = manual
manual-public-ip-logging-ok


renew-by-default

#Testing; comment the following block out when you are done testing and want to get the real thing.
server = https://acme-staging.api.letsencrypt.org/directory
debug
break-my-certs

#Testing opts end here

```

**Notes:**

1. The above gets a test certificate. If you edit  and use the above configuration file make sure to comment out the testing block for getting a valid certificate.
2. In the above example, I didn't have to do anything at all other than running the **lcget** command. Not even giving ssh password as my ssh login uses (private and public) key pairs for authentication.


#Caveats:

Only the required codes for completing http challenge in manual mode is included for now, though this can be extended to support other modes and challenges too.

#Further development:
You can add other options and make **all** the things in letsencrypt automated by a little haggle with Tcl/expect. So, if you feel you can do the development and extend its' capability please fork the repository and add changes and do a pull request. I will greatly appreciate that.

