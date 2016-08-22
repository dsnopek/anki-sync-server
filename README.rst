Anki Server
===========

`Anki <http://ankisrs.net>`_ is a powerful Open Source flashcard
application, which helps you quickly and easily memorize facts over
the long term utilizing a spaced repetition algorithm.

Anki's main form is a desktop application (for Windows, Linux and
MacOS) which can sync to a web version (AnkiWeb) and mobile versions
for Android and iOS.

This is a personal Anki Server, which you can sync against instead of
AnkiWeb.

It also includes a RESTful API, so that you could implement your
own AnkiWeb-like site if you wanted.

It was originally developed to support the flashcard functionality on
`Bibliobird <http://en.bibliobird.com>`_, a web application for
language learning.

Installing the easy way!
------------------------

If you have ``easy_install`` or ``pip`` on your system, you can
simply run::

   $ easy_install AnkiServer

Or using ``pip``::

   $ pip install AnkiServer

This will give you the latest released version!

However, if you want to try the latest bleeding edge version OR you
want to help with development, you'll need to install from source.
In that case, follow the instructions in the next two sections.

Setting up a virtualenv
-----------------------

If you want to install your Anki Server in an isolated Python
environment using
`virtualenv <https://pypi.python.org/pypi/virtualenv>`_, please
follow these instructions before going on to the next section. If
not, just skip to the "Installing" section below.

There are many reasons for installing into a virtualenv, rather
than globally on your system:


-  You can keep the Anki Server's dependencies seperate from other
   Python applications.

-  You don't have permission to install globally on your system
   (like on a shared host).

Here are step-by-step instruction for setting up your virtualenv:

1. First, you need to install "virtualenv". If your system has
   ``easy_install`` or ``pip``, this is just a matter of::

     $ easy_install virtualenv

   Or using pip::

     $ pip install virtualenv

   Or you can use your the package manager provided by your OS.

2. Next, create your a Python environment for running AnkiServer::

     $ virtualenv AnkiServer.env

3. (Optional) Enter the virtualenv to save you on typing::

     $ . AnkiServer.env/bin/activate


If you skip step 3, you'll have to type
``AnkiServer.env/bin/python`` instead of ``python`` and
``AnkiServer.env/bin/paster`` instead of ``paster`` in the following
sections.

Also, remember that the environment change in step 3 only lasts as
long as your current terminal session. You'll have to re-enter the
environment if you enter that terminal and come back later.

Installing your Anki Server from source
---------------------------------------

1. Install all the dependencies we need using ``easy_install`` or
   ``pip``::

     $ easy_install webob PasteDeploy PasteScript sqlalchemy simplejson

   Or using pip::

     $ pip install webob PasteDeploy PasteScript sqlalchemy simplejson

   Or you can use your the package manager provided by your OS.

2. Download and install libanki. You can find the latest release of
   Anki here:

   http://code.google.com/p/anki/downloads/list

   Look for a \*.tgz file with a Summary of "Anki Source". At the time
   of this writing that is anki-2.0.11.tgz.

   Download this file and extract.

   Then either:

   a. Run the 'make install', or

   b. Copy the entire directory to /usr/share/anki

3. Make the egg info files (so paster can see our app)::

     $ python setup.py egg_info

Configuring and running your Anki Server
----------------------------------------

1. Copy the example.ini to production.ini in your current directory
   and edit for your needs.

   a. If you installed from source, it'll be at the top-level.

   b. If you installed via 'easy_install' or 'pip', you'll find all
      the example configuration at
      ``python_prefix/lib/python2.X/site-packages/AnkiServer-2.X.X-py2.X.egg/examples``
      (replacing ``python_prefix`` with the root of your Python and
      all the ``X`` with the correct versions). For example, it could
      be::

        /usr/lib/python2.7/site-packages/AnkiServer-2.0.0a6-py2.7.egg/examples/example.ini

3. Create user::

   $ ./ankiserverctl.py adduser <username>

4. Test the server by starting it debug mode::

   $ ./ankiserverctl.py debug
   
   If the output looks good, you can stop the server by pressing Ctrl-C and start it again in normal mode::

   $ ./ankiserverctl.py start

   To stop AnkiServer, run::

   $ ./ankiserverctl.py stop

Point the Anki desktop program at it
------------------------------------

Unfortunately, there isn't currently any user interface in the Anki
destop program to point it at your personal sync server instead of
AnkiWeb, so you'll have to write a short "addon".

Create a file like this in your Anki/addons folder called
"mysyncserver.py"::

  import anki.sync
  anki.sync.SYNC_BASE = 'http://127.0.0.1:27701/'
  anki.sync.SYNC_MEDIA_BASE = 'http://127.0.0.1:27701/msync/'

Be sure to change the SYNC_URL to point at your sync server. The
address ``127.0.0.1`` refers to the local computer.

If you are using TLS, add these lines to the configuration to verify
the certificate against a custom certificate chain::

  # Path to the certificate chain file, relative to the Anki/addons directory
  CERTPATH = 'server.pem'
  
  # Override TLS certificate path
  httpCon_anki = anki.sync.httpCon
  def httpCon_patch():
      import os.path
      conn = httpCon_anki()
  	conn.ca_certs = os.path.join(os.path.dirname(__file__), CERTPATH)
  	return conn
  anki.sync.httpCon = httpCon_patch

The certificate chain must include all intermediate certificates and the
root certificate. For the popular free
`Let's encrypt <https://letsencrypt.org/>`_ CA, a sample certificate chain
can be found
`here <https://gist.github.com/alexander255/a15955932cf9880e77081501feea1345>`_.

Unfortunately ``python-httplib2`` (used by Anki's sync client for issuing HTTP
requests) does not support `SNI <https://en.wikipedia.org/wiki/Server_Name_Indication>`_
for telling the web server during the TLS handshake which certificate to use.
This will result in certificate validation errors if your Anki Server instance
runs behind a web server that serves multiple domains using different
certificates. This has `been fixed <https://github.com/httplib2/httplib2/pull/13>`_
in the ``python-httplib2`` source code and will be part of the upcoming
``0.9.3`` release. In the likely event that you are not using the latest version
yet you will have to install the latest release from source using::

  sudo pip install -e git+https://github.com/httplib2/httplib2.git#egg=httplib2

Alternatively you can try adding these lines, to disable certificate validation
entirely::

  # Override TLS certificate path
  httpCon_anki = anki.sync.httpCon
  def httpCon_patch():
  	conn = httpCon_anki()
  	conn.disable_ssl_certificate_validation = True
  	return conn
  anki.sync.httpCon = httpCon_patch

Restart Anki for your plugin to take effect. Now, everytime you sync,
it will be to your personal sync server rather than AnkiWeb.

However, if you just want to switch temporarily, rather than creating
an addon, you can set the ``SYNC_URL`` environment variable when
running from the command-line (on Linux)::

  export SYNC_URL=http://127.0.0.1:27701/sync/
  ./runanki &

Point the mobile apps at it
---------------------------

As of AnkiDroid 2.6 the sync server can be changed in the settings:

1. Open the *Settings* screen from the menu
2. In the *Advanced* section, tap on *Custom sync server*
3. Check the *Use custom sync server* box
4. Change the *Sync URL* and *Media sync URL* to the values described above
5. The next sync should use the new sync server (if your previous username
   or password does not match AnkiDroid will ask you to log in again)

At the moment, there isn't any way to get the Anki iOS app to point at
your personal sync server. 😕

Running with Supervisor
-----------------------

If you want to run your Anki server persistantly on a Linux (or
other UNIX-y) server, `Supervisor <http://supervisord.org>`_ is a
great tool to monitor and manage it. It will allow you to start it
when your server boots, restart it if it crashes and easily access
it's logs.

1. Install Supervisor on your system. If it's Debian or Ubuntu this
   will work::

     $ sudo apt-get install supervisor

   If you're using a different OS, please try
   `these instructions <http://supervisord.org/installing.html>`_.

2. Copy ``supervisor-anki-server.conf`` to ``/etc/supervisor/conf.d/anki-server.conf``::

     $ sudo cp supervisor-anki-server.conf /etc/supervisor/conf.d/anki-server.conf

3. Modify ``/etc/supervisor/conf.d/anki-server.conf`` to match your
   system and how you setup your Anki Server in the section above.

4. Reload Supervisor's configuration::

     $ sudo supervisorctl reload

5. Check the logs from the Anki Server to make sure everything is
   fine::

     $ sudo supervisorctl tail anki-server

   If it's empty - then everything's fine! Otherwise, you'll see an
   error message.

Later if you manually want to stop, start or restart it, you can
use::

   $ sudo supervisorctl stop anki-server

   $ sudo supervisorctl start anki-server

   $ sudo supervisorctl restart anki-server

See the `Supervisor documentation <http://supervisord.org>`_ for
more info!

Using with Apache
-----------------

If you're already serving your website via Apache (on port 80) and
want to also allow users to sync against a URL on port 80, you can
forward requests from Apache to the Anki server.

On Bibliobird.com, I have a special anki.bibliobird.com virtual host
which users can synch against. Here is an excerpt from my Apache
conf::

    <VirtualHost *:80>
        ServerAdmin support@lingwo.org
        ServerName anki.bibliobird.com

        # The Anki server handles gzip itself!
        SetEnv no-gzip 1

        <Location />
            ProxyPass http://localhost:27701/
            ProxyPassReverse http://localhost:27701/
        </Location>
    </VirtualHost>

It may also be possible to use `mod_wsgi
<http://code.google.com/p/modwsgi/>`_, however, I have no experience
with that.

Using with nginx
----------------

If you happen to use nginx, you can use the following configuration to
proxy requests from nginx to your Anki Server::

    server {
        # Allow access via HTTP
        listen 80;
        listen [::]:80;
        
        # Allow access via HTTPS
        listen 443 ssl spdy;
        listen [::]:443 ssl spdy;
        
        # Set server names for access
        server_name anki.server.name;
        
        # Set TLS certificates to use for HTTPS access
        ssl_certificate     /path/to/fullchain.pem;
        ssl_certificate_key /path/to/privkey.pem;
        
        location / {
            # Prevent nginx from rejecting larger media files
            client_max_body_size 0;
            
            proxy_pass http://anki:27701;
            include proxy_params;
        }
    }

AnkiDroid will not verify the TLS certificate, Anki Desktop will by
default reject all but AnkiWeb's certificate, see the
`Anki addon section <#point-the-anki-desktop-program-at-it>`_ for
how to change this.

How to get help
---------------

If you're having any problems installing or using Anki Server, please
create an issue on GitHub (or find an existing issue about your problem):

https://github.com/dsnopek/anki-sync-server/issues

Be sure to let us know which operating system and version you're using
and how you intend to use the Anki Server!

