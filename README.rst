####################
dbb_buffmngrs_deploy
####################

.. _section-quickstart:

Quickstart
==========

.. _section-download:

Download deployment scripts
---------------------------

Recommended way of deploying DBB buffer manger is with Docker container You can
download scripts which help you build and run sucha a container from GitHub:

.. code-block:: bash

   git clone https://github.com/lsst-dm/dbb_buffmngrs_deploy .
   cd dbb_buffmngrs_deploy

.. _section-configuration:

Configure DBB buffer manager
----------------------------

In ``docker/dbb_buffmngrs_handoff/buffmngr.yml``, in **endpoint** section you
need to specify three directories:  

1. **staging area**: directory where the files are being transferred to,
2. **storage area**: directory where the files will be moved after transfer is
   complete,
3. **buffer**: directory used by DBB ingestion service,

as well as

4. **host**: the name of the host acting as the endpoint site,
5. **user**: a user account to use for file transfer (DBB buffer manger uses
   internally ``scp`` to transfer files between the sites, so anonymous
   transfer is not supported).

.. warning::

   The selected user needs to have passwordless login enabled on the endpoint
   site.  
   
.. note:: 

   Only *handoff* and *endpoint* sections are strictly required to be present
   in the configuration file.  However, enabling logging to a file (by default
   DBB buffer manager outputs log messages on stdout/stderr) is highly
   recommended. You can achieve it by specifying **file** option in **logging**
   section, for example:

   .. code-block::
   
      logging:
        file: /var/log/lsst/handoff.log

.. _section-building:

Build the image
---------------

#. Select desired version of LSST stack and DBB buffer manager in
   ``etc/env.conf`` by modifying respectively ``STACK_VER`` and
   ``MANAGER_VER``. 

#. Select a user which will be used to run DBB buffer manager within the Docker
   container by adjusting ``USER`` variable.  This user needs to have a
   read/write access to the buffer, holding area, and the directory where the
   log file will be written to.

#. Build the Docker image with

   .. code:: bash

      ./bin/build_buffmngr.sh

.. _section-mounts:

Adjust bind mounts
------------------

There is a helping script, ``bin/start_buffmngr.sh``, available in the
repository you cloned allowing you to start the container with minimum effort.
However, before you can use it, you need to adjust bind mounts which enables
the buffer manager running inside of the containter to interact with
filesystems neccessary to do its job. These are:

* directory with the buffer and the holding area,
* log directory (usually ``/var/log``),
* directory with SSH keys (usually ``~/.ssh``).

Make sure these bind mounts reflect your setup.

.. _section-starting:

Start the container
-------------------

Once you correct the bind mount, you can start the container with

.. code-block:: bash

   ./bin/start_buffmngr.sh
