**lcget** is a wrapper (written in [Tcl/expect](https://en.wikipedia.org/wiki/Expect)) for letsencrypt which automates the task of completing challenges for remote server/domains from a local machine. It relieves you of the pain of running multiple commands in multiple terminals. Most of the time, a single command in a single terminal will be enough to get the certificate from Let's Encrypt. It doesn't require sudo access on remote host if the document root is in /home directory i.e for shared hosting.

#Mechanism:
**lcget** is a [expect](https://en.wikipedia.org/wiki/Expect) script which runs the letsencrypt command and monitor its' output. When the challenge appears on the output of `letsencrypt` command, the script parses necessary information about the challenge and tries to complete the challenge itself.

To complete the http challenge, **lcget** requires ssh access to remote host i.e it runs ssh commands to the remote host to meet the necessary requirements for the acme challenge.


#Dependencies:
The script depends on the following tools/scripts:

1. **letsencrypt:** The letsencrypt tool itself.
2. **expect:** You may need to install this first if not installed.
2. **ssh:** It is installed by default in most Unix based system.
3. **jssh:** It is a wrapper to automate ssh login and/or running ssh commands.

**To install jssh, download the [jssh script](https://github.com/neurobin/jssh) and put it in a bin directory which is in the PATH environment variable (e.g */usr/bin*)**. The **lcget** script uses `jssh` command to execute it.

#Install:

First you will need to give execution permission to the script. An octal `755` permission is recommended but not required.

* You can run the script with full path or with `./lcget` by `cd`ing into the directory where it resides.
* You can just copy the script into a standard bin directory (e.g */usr/bin*).
* Or you can run the *install.sh* script which tries to install it in *~/bin* along with **jssh**.

##Installing examples:

*Installing in /usr/bin* :

```
chmod 755 path/to/lcget
sudo cp path/to/lcget /usr/bin
```
*Installing in ~/bin* :
```
chmod 755 path/to/lcget
cp path/to/lcget $HOME/bin
#Now add $HOME/bin to PATH environment variable if not added already
var=$HOME/bin
if ! echo $PATH | grep -q  ":$var\([/:]\|$\)"; then echo "export PATH=\$PATH:$var" >> ~/.bashrc && . ~/.bashrc ;fi
```
##Note:
**If the script isn't recognized as an executable by the system**, then you may try the `lcget-sh` script provided from within the directory where lcget resides. Furthermore, you can change the path of `lcget` to the actual path in the `lcget-sh` script and install `lcget-sh` instead of `lcget`. In these cases you will be using `lcget-sh` as the **lcget** command.

#Usage:

```
lcget [native or letsencrypt options]
```
**native options:** These are the options parsed and recognized by lcget. These are:

* **--launcher-path :** Launcher path. You can define the letsencrypt launcher path with this option.
* **--help :** This is a mixed option. It will print both **lcget** and **letsencrypt** help.
* **--version:** This is a mixed option. It will print version info for both **lcget** and **letsencrypt**.

**letsencrypt options:** These are the options recognized by letsencrypt. These options are same as the options supported by the letsencrypt launcher.


#How to:
We will need to prepare a **jssh** config file for each of the domains we want to get Let's Encrypt ssl certificate for. We will do this just once, after that we will be running the `lcget` command only.

##Create jssh config file:

The config file must follow the naming convention: **domain.conf** e.g *example.com.conf* for example.com, *www.example.com.conf* for www.example.com etc...

To create a **jssh config file** run `jssh -c` in a terminal and fill out necessary information. For example:

```
:~$ jssh -c

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

    config file saved as: /home/user/.neurobin/jssh/example.com.conf
    You will call jssh for this configuration like this:
    jssh example.com other_ssh_options_or_args
    'jssh example.com' is the native jssh part. All other arguments
    will be forwarded to ssh command. Any jssh native option
    must be passed before example.com.
    You can edit the config file to make further changes.
    

```
This will create a config file for *example.com*. 

**You must give the document root of your domain as the working directory.**

As *www.example.com* generally points to *example.com* and thus we don't need to create a separate file for it. A symbolic link will be enough. Go to the config file directory and create a link named *www.example.com.conf* targeting to the file we just created.

You will need to create **jssh config file** for each of your domains. 

For sub-domains you can just create *subdomain.rootdomain.conf* file with the same credentials as rootdomain except the working directory; working directory must be the document root of the subdomain/domain. In this case ssh will login with the credentials of root domain.

**Note:** 

* The config file stores username, port, domain name/IP and working directory (generally document root).

##Run lcget and get the certificate:
Now all we have to do is to run the `lcget` command with appropriate options. The following is an example which uses a letsencrypt configuration file (All outputs are shown):

```sh
~$ lcget certonly -c ~/.letsencrypt/neurobin.org.ini
Updating letsencrypt and virtual environment dependencies......
Requesting root privileges to run with virtualenv: sudo /home/user/.local/share/letsencrypt/bin/letsencrypt --text certonly -c /home/user/.letsencrypt/neurobin.org.ini
[sudo] password for user: 
Make sure your web server displays the following content at
http://neurobin.org/.well-known/acme-challenge/LF9LYxWVhs_UtmmXbUqjNIClIVwglXzD8qCR5y9q-Vw before continuing:

LF9LYxWVhs_UtmmXbUqjNIClIVwglXzD8qCR5y9q-Vw.G8uRfTIvsKsDuxiyJQ6leIcuXwIc8svyBrWQGSQ1CFA

If you don't have HTTP server configured, you can run the following
command on the target server (as root):

mkdir -p /tmp/letsencrypt/public_html/.well-known/acme-challenge
cd /tmp/letsencrypt/public_html
printf "%s" LF9LYxWVhs_UtmmXbUqjNIClIVwglXzD8qCR5y9q-Vw.G8uRfTIvsKsDuxiyJQ6leIcuXwIc8svyBrWQGSQ1CFA > .well-known/acme-challenge/LF9LYxWVhs_UtmmXbUqjNIClIVwglXzD8qCR5y9q-Vw
# run only once per server:
$(command -v python2 || command -v python2.7 || command -v python2.6) -c \
"import BaseHTTPServer, SimpleHTTPServer; \
s = BaseHTTPServer.HTTPServer(('', 80), SimpleHTTPServer.SimpleHTTPRequestHandler); \
s.serve_forever()" 
Press ENTER to continue

Protocol: http://
Domain: neurobin.org
Dir: .well-known/acme-challenge/LF9LYxWVhs_UtmmXbUqjNIClIVwglXzD8qCR5y9q-Vw
Content: LF9LYxWVhs_UtmmXbUqjNIClIVwglXzD8qCR5y9q-Vw.G8uRfTIvsKsDuxiyJQ6leIcuXwIc8svyBrWQGSQ1CFA

Completing challenge...
Created dir: .well-known/acme-challenge/LF9LYxWVhs_UtmmXbUqjNIClIVwglXzD8qCR5y9q-Vw
cd to dir: .well-known/acme-challenge/LF9LYxWVhs_UtmmXbUqjNIClIVwglXzD8qCR5y9q-Vw
Created index.html
Challenge completed on:/home/neurcpiw/public_html/.well-known/acme-challenge

Completed challenge for neurobin.org  

Make sure your web server displays the following content at
http://www.neurobin.org/.well-known/acme-challenge/08k373zvf_3qSWMTKEjbE1QgORfm0zVqw6mJVo3u22s before continuing:

08k373zvf_3qSWMTKEjbE1QgORfm0zVqw6mJVo3u22s.G8uRfTIvsKsDuxiyJQ6leIcuXwIc8svyBrWQGSQ1CFA

If you don't have HTTP server configured, you can run the following
command on the target server (as root):

mkdir -p /tmp/letsencrypt/public_html/.well-known/acme-challenge
cd /tmp/letsencrypt/public_html
printf "%s" 08k373zvf_3qSWMTKEjbE1QgORfm0zVqw6mJVo3u22s.G8uRfTIvsKsDuxiyJQ6leIcuXwIc8svyBrWQGSQ1CFA > .well-known/acme-challenge/08k373zvf_3qSWMTKEjbE1QgORfm0zVqw6mJVo3u22s
# run only once per server:
$(command -v python2 || command -v python2.7 || command -v python2.6) -c \
"import BaseHTTPServer, SimpleHTTPServer; \
s = BaseHTTPServer.HTTPServer(('', 80), SimpleHTTPServer.SimpleHTTPRequestHandler); \
s.serve_forever()" 
Press ENTER to continue

Protocol: http://
Domain: www.neurobin.org
Dir: .well-known/acme-challenge/08k373zvf_3qSWMTKEjbE1QgORfm0zVqw6mJVo3u22s
Content: 08k373zvf_3qSWMTKEjbE1QgORfm0zVqw6mJVo3u22s.G8uRfTIvsKsDuxiyJQ6leIcuXwIc8svyBrWQGSQ1CFA

Completing challenge...
Created dir: .well-known/acme-challenge/08k373zvf_3qSWMTKEjbE1QgORfm0zVqw6mJVo3u22s
cd to dir: .well-known/acme-challenge/08k373zvf_3qSWMTKEjbE1QgORfm0zVqw6mJVo3u22s
Created index.html
Challenge completed on:/home/neurcpiw/public_html/.well-known/acme-challenge

Completed challenge for www.neurobin.org  

Make sure your web server displays the following content at
http://forums.neurobin.org/.well-known/acme-challenge/j5eGd516jVvkO6XaXSQvGzopUM38ahBU7-4OnrG0zXY before continuing:

j5eGd516jVvkO6XaXSQvGzopUM38ahBU7-4OnrG0zXY.G8uRfTIvsKsDuxiyJQ6leIcuXwIc8svyBrWQGSQ1CFA

If you don't have HTTP server configured, you can run the following
command on the target server (as root):

mkdir -p /tmp/letsencrypt/public_html/.well-known/acme-challenge
cd /tmp/letsencrypt/public_html
printf "%s" j5eGd516jVvkO6XaXSQvGzopUM38ahBU7-4OnrG0zXY.G8uRfTIvsKsDuxiyJQ6leIcuXwIc8svyBrWQGSQ1CFA > .well-known/acme-challenge/j5eGd516jVvkO6XaXSQvGzopUM38ahBU7-4OnrG0zXY
# run only once per server:
$(command -v python2 || command -v python2.7 || command -v python2.6) -c \
"import BaseHTTPServer, SimpleHTTPServer; \
s = BaseHTTPServer.HTTPServer(('', 80), SimpleHTTPServer.SimpleHTTPRequestHandler); \
s.serve_forever()" 
Press ENTER to continue

Protocol: http://
Domain: forums.neurobin.org
Dir: .well-known/acme-challenge/j5eGd516jVvkO6XaXSQvGzopUM38ahBU7-4OnrG0zXY
Content: j5eGd516jVvkO6XaXSQvGzopUM38ahBU7-4OnrG0zXY.G8uRfTIvsKsDuxiyJQ6leIcuXwIc8svyBrWQGSQ1CFA

Completing challenge...
Created dir: .well-known/acme-challenge/j5eGd516jVvkO6XaXSQvGzopUM38ahBU7-4OnrG0zXY
cd to dir: .well-known/acme-challenge/j5eGd516jVvkO6XaXSQvGzopUM38ahBU7-4OnrG0zXY
Created index.html
Challenge completed on:/home/neurcpiw/forums/.well-known/acme-challenge

Completed challenge for forums.neurobin.org  

Make sure your web server displays the following content at
http://www.forums.neurobin.org/.well-known/acme-challenge/6DouCqmu-Qx4e_GCJcCI6ao7t3GfFv_sDycpWxjlaek before continuing:

6DouCqmu-Qx4e_GCJcCI6ao7t3GfFv_sDycpWxjlaek.G8uRfTIvsKsDuxiyJQ6leIcuXwIc8svyBrWQGSQ1CFA

If you don't have HTTP server configured, you can run the following
command on the target server (as root):

mkdir -p /tmp/letsencrypt/public_html/.well-known/acme-challenge
cd /tmp/letsencrypt/public_html
printf "%s" 6DouCqmu-Qx4e_GCJcCI6ao7t3GfFv_sDycpWxjlaek.G8uRfTIvsKsDuxiyJQ6leIcuXwIc8svyBrWQGSQ1CFA > .well-known/acme-challenge/6DouCqmu-Qx4e_GCJcCI6ao7t3GfFv_sDycpWxjlaek
# run only once per server:
$(command -v python2 || command -v python2.7 || command -v python2.6) -c \
"import BaseHTTPServer, SimpleHTTPServer; \
s = BaseHTTPServer.HTTPServer(('', 80), SimpleHTTPServer.SimpleHTTPRequestHandler); \
s.serve_forever()" 
Press ENTER to continue

Protocol: http://
Domain: www.forums.neurobin.org
Dir: .well-known/acme-challenge/6DouCqmu-Qx4e_GCJcCI6ao7t3GfFv_sDycpWxjlaek
Content: 6DouCqmu-Qx4e_GCJcCI6ao7t3GfFv_sDycpWxjlaek.G8uRfTIvsKsDuxiyJQ6leIcuXwIc8svyBrWQGSQ1CFA

Completing challenge...
Created dir: .well-known/acme-challenge/6DouCqmu-Qx4e_GCJcCI6ao7t3GfFv_sDycpWxjlaek
cd to dir: .well-known/acme-challenge/6DouCqmu-Qx4e_GCJcCI6ao7t3GfFv_sDycpWxjlaek
Created index.html
Challenge completed on:/home/neurcpiw/forums/.well-known/acme-challenge

Completed challenge for www.forums.neurobin.org  

Make sure your web server displays the following content at
http://wiki.neurobin.org/.well-known/acme-challenge/MIRHddhxd5QyLBEElSWXiM7aEs1pQ4bwVI1ybOItuNI before continuing:

MIRHddhxd5QyLBEElSWXiM7aEs1pQ4bwVI1ybOItuNI.G8uRfTIvsKsDuxiyJQ6leIcuXwIc8svyBrWQGSQ1CFA

If you don't have HTTP server configured, you can run the following
command on the target server (as root):

mkdir -p /tmp/letsencrypt/public_html/.well-known/acme-challenge
cd /tmp/letsencrypt/public_html
printf "%s" MIRHddhxd5QyLBEElSWXiM7aEs1pQ4bwVI1ybOItuNI.G8uRfTIvsKsDuxiyJQ6leIcuXwIc8svyBrWQGSQ1CFA > .well-known/acme-challenge/MIRHddhxd5QyLBEElSWXiM7aEs1pQ4bwVI1ybOItuNI
# run only once per server:
$(command -v python2 || command -v python2.7 || command -v python2.6) -c \
"import BaseHTTPServer, SimpleHTTPServer; \
s = BaseHTTPServer.HTTPServer(('', 80), SimpleHTTPServer.SimpleHTTPRequestHandler); \
s.serve_forever()" 
Press ENTER to continue

Protocol: http://
Domain: wiki.neurobin.org
Dir: .well-known/acme-challenge/MIRHddhxd5QyLBEElSWXiM7aEs1pQ4bwVI1ybOItuNI
Content: MIRHddhxd5QyLBEElSWXiM7aEs1pQ4bwVI1ybOItuNI.G8uRfTIvsKsDuxiyJQ6leIcuXwIc8svyBrWQGSQ1CFA

Completing challenge...
Created dir: .well-known/acme-challenge/MIRHddhxd5QyLBEElSWXiM7aEs1pQ4bwVI1ybOItuNI
cd to dir: .well-known/acme-challenge/MIRHddhxd5QyLBEElSWXiM7aEs1pQ4bwVI1ybOItuNI
Created index.html
Challenge completed on:/home/neurcpiw/wiki/.well-known/acme-challenge

Completed challenge for wiki.neurobin.org  

Make sure your web server displays the following content at
http://www.wiki.neurobin.org/.well-known/acme-challenge/rs94EfewbK5sGUfcOfeUmJnbI7-Um1iWVva8f0fQ2JQ before continuing:

rs94EfewbK5sGUfcOfeUmJnbI7-Um1iWVva8f0fQ2JQ.G8uRfTIvsKsDuxiyJQ6leIcuXwIc8svyBrWQGSQ1CFA

If you don't have HTTP server configured, you can run the following
command on the target server (as root):

mkdir -p /tmp/letsencrypt/public_html/.well-known/acme-challenge
cd /tmp/letsencrypt/public_html
printf "%s" rs94EfewbK5sGUfcOfeUmJnbI7-Um1iWVva8f0fQ2JQ.G8uRfTIvsKsDuxiyJQ6leIcuXwIc8svyBrWQGSQ1CFA > .well-known/acme-challenge/rs94EfewbK5sGUfcOfeUmJnbI7-Um1iWVva8f0fQ2JQ
# run only once per server:
$(command -v python2 || command -v python2.7 || command -v python2.6) -c \
"import BaseHTTPServer, SimpleHTTPServer; \
s = BaseHTTPServer.HTTPServer(('', 80), SimpleHTTPServer.SimpleHTTPRequestHandler); \
s.serve_forever()" 
Press ENTER to continue

Protocol: http://
Domain: www.wiki.neurobin.org
Dir: .well-known/acme-challenge/rs94EfewbK5sGUfcOfeUmJnbI7-Um1iWVva8f0fQ2JQ
Content: rs94EfewbK5sGUfcOfeUmJnbI7-Um1iWVva8f0fQ2JQ.G8uRfTIvsKsDuxiyJQ6leIcuXwIc8svyBrWQGSQ1CFA

Completing challenge...
Created dir: .well-known/acme-challenge/rs94EfewbK5sGUfcOfeUmJnbI7-Um1iWVva8f0fQ2JQ
cd to dir: .well-known/acme-challenge/rs94EfewbK5sGUfcOfeUmJnbI7-Um1iWVva8f0fQ2JQ
Created index.html
Challenge completed on:/home/neurcpiw/wiki/.well-known/acme-challenge

Completed challenge for www.wiki.neurobin.org  


IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at
   /etc/letsencrypt/live/neurobin.org/fullchain.pem. Your cert will
   expire on 2016-04-15. To obtain a new version of the certificate in
   the future, simply run Let's Encrypt again.
 - If you like Let's Encrypt, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le


```
The *neurobin.org.ini* file:

```sh
# This is an example of the kind of things you can do in a configuration file.
# All flags used by the client can be configured here. Run Lets Encrypt with
# --help to learn more about the available options.
config-dir = /etc/letsencrypt
work-dir = /var/lib/letsencrypt
logs-dir = /var/log/letsencrypt
# Use a 4096 bit RSA key instead of 2048
rsa-key-size = 4096

# Uncomment and update to register with the specified e-mail address
email = admin@neurobin.org

# Uncomment and update to generate certificates for the specified domains.
#Add subdomains or domains however you like. My recommendation is to put the root domain at beginning.
domains = neurobin.org, www.neurobin.org, forums.neurobin.org, www.forums.neurobin.org, wiki.neurobin.org, www.wiki.neurobin.org


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

#Caveats:

Only the required codes for completing http challenge in manual mode is included for now.

#Further development:
You can add other options and make **all** the things in letsencrypt automated with a little bit of knowledge about Tcl/expect. So if you feel you can do the development and extend its' capability please fork the repository and add changes and do a pull request. I will greatly appreciate that.

