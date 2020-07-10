##########
Quickstart
##########

.. _section-overview:

Overview
========

Data Backbone (DBB) buffer managers consist of two separate managers:
**handoff** and **endpoint**.  The handoff manager is  responsible for
transferring files from a **handoff site** to an **endpoint site**.  The
endpoint buffer manager is responsible for ingesting the files into the DBB.

.. _section-handoff:

DBB handoff buffer manager
==========================

.. _section-handoff-download:

Download deployment scripts
---------------------------

Recommended way of deploying DBB handoff buffer manager is with a Docker
container.  You can download scripts which help you build and run such a
container from GitHub:

.. code-block:: bash

   git clone https://github.com/lsst-dm/dbb_buffmngrs_deploy .
   cd dbb_buffmngrs_deploy

.. _section-handoff-configuration:

Configure DBB handoff buffer manager
------------------------------------

You can find an example configuration file in ``handoff/etc/config.yaml``.
Only **handoff** and **endpoint** sections are required, others are optional
and hence are commented out.  Each of these sections describes handoff and
endpoint site respectively.

In **handoff** sections you need to specify two directories:

1. **buffer**: directory where files are being written to,
2. **holding** area: directory where files will be moved after being
   transferred successfully. 

.. warning::

   When deploying the mangeer in a Docker container, both directories specify
   locations *in* the container!  They will most likely be different from
   actual directories on the host system and will also depend on actual bind
   mounts (see :ref:`section-handoff-mounts`).

In **endpoint** section you need to specify two directories (in any order):

1. **staging** area: directory where the files are being transferred to,
2. **buffer** directory where the files will be moved after transfer is
   complete,

as well as

3. **host**: the name of the host acting as the endpoint site,
4. **user**: a user account to use for file transfer.

.. warning::

   The selected user needs to have passwordless login enabled on the endpoint
   site.  As the manger uses internally ``scp`` to transfer files between the
   sites, anonymous transfer is not supported.
   
.. note:: 

   By default, DBB handoff buffer manager outputs log messages on
   stdout/stderr.  However, enabling logging to a file is highly recommended.
   You can achieve it by specifying **file** option in **logging** section, for
   example:

   .. code-block::
   
      logging:
        file: /var/log/handoff.log

   Keep in mind though that in order to easily view the log file outside of the
   container, you need to bind mount a writable directory from the host machine
   to that location (see :ref:`section-handoff-mounts` for details).

By default, ``handoff/etc`` is bind mounted in the docker image to
``~/local/etc`` so each configuration file created in this directory will be
available in the resultant docker image.

To select which configuration should be used by the handoff manager when the
container is started, adjust the path in the **command** option in
``handoff/docker-compose.yaml``.

.. note::

   The included Compose file (see :ref:`section-handoff-manage`) allow one to
   start buffer managers for two separate instruments: AuxTel (section
   **at-dbbm**) and ComCam (section **cc-dbbbm**).  By default, their
   configurations are read from ``at_dbbbm_config.yaml`` and
   ``cc_dbbbm_config.yaml`` respectively.  Feel free to repurpose them
   according to your needs.

.. _section-handoff-manage:

Manage the manager
------------------

Actions such as:

* building Docker image with the handoff manager,
* starting/stopping the manager for a given instrument,

are managed centrally with help of ``docker-compose`` and service configuration
files: ``env.bash`` and ``handoff/docker-compose.yaml``.

However, the each handoff manager you start needs to have access to selected
directories on the host running the image to do its job.  That is achieved by
making these directories accessible in the Docker container with use of bind
mounts.

.. note::

   You can find more about Docker Compose file `here`_.

.. __: https://docs.docker.com/compose/compose-file/

.. _section-handoff-mounts:

Adjust bind mounts
------------------

There are four crucial bind mounts for each instrument:

* directory that holds the buffer and the holding area,
* directory where logs are kept (usually ``/var/log``),
* directory with the configuration files (be default, ``handoff/etc``).
* directory with SSH keys needed to access to the endpoint site (usually
  ``~/.ssh``).

These bind mounts are defined in **volumes** section for each buffer manager in
``handoff/docker-compose.yaml``.  For sake of simplicity, provided example
files assume that the host have identical directory structure as the container
with the buffer manager so the mapping is straightforward.  In reality, it's
hardly the case.  You need to make sure that the bind mounts accurately reflect
actual setup!

.. note::

   You can find out more about Docker volumes `here`_.

.. __: https://docs.docker.com/storage/volumes/

.. _section-handoff-building:

Build the image
---------------

Building manually the Docker image with handoff manager is not strictly
necessary.  For example, command ``docker-compose up cc-dbbbm`` will not only
start the handoff manager for a Comcam system, but also will build required
image if it is not ready available.

However, on certain occasions (e.g. uploading the image to DockerHub), you may
want to just build the image without starting the manager itself. You can do
it as follow:

#. Select desired version of LSST stack and DBB handoff buffer manager in
   ``env.bash`` by modifying respectively ``LSST_VER`` and ``MNGR_VER``. 

#. Select a user which will be used to run the manager within the Docker
   container by adjusting ``USER`` variable.  This user needs to have a
   read/write access to the buffer, holding area, and the directory where the
   log file will be written to on the *host* system.

#. Build the Docker image with

   .. code:: bash

      cd handoff
      source env.bash
      docker-compose build dbbbm

.. _section-handoff-starting:

Start the container
-------------------

Once you created a configuration files satisfying your needs, adjusted the bind
mounts you are ready to start the container with handoff buffer manager.

If you haven't done it already, intialize runtime environment with

.. code-block:: bash

   source env.sh

To start handoff managers for all known instruments, run

.. code-block:: bash

   docker-compose up -d

To start the handoff manager for a selected instrument, say Comcam, run

.. code-block:: bash

   docker-compose up -d cc-dbbbm

.. _section-endpoint:

DBB endpoint buffer manager
===========================

Currently package `ctrl_oods`_ implementing Observatory Operation Data Service
(OODS) is used to emulate functionality of DBB endpoint buffer manager.

.. _ctrl_oods: https://github.com/lsst-dm/ctrl_oods

.. _section-endpoint-download:

Download and install DBB endpoint buffer manager
------------------------------------------------

Create a directory where you want to install DBB endpoint buffer manager. For
example:

.. code-block:: bash

   mkdir -p lsstsw/addons
   cd lsstsw/addons

Download ``ctrl_oods`` by cloning its repository from GitHub:

.. code-block:: bash

   git clone https://github.com/lsst-dm/ctrl_oods .
   cd ctrl_oods

Make sure you selected the required version of ``ctrl_oods``:

.. code-block:: bash

   git checkout 1.0.0-rc1

.. warning::

   Newer implementations of OODS use messaging system which is not supported by
   DBB buffer manager and won't work with it!

Set it up and build with

.. code-block:: bash

   setup -r .
   scons

.. _section-endpoint-testing:

Test DBB endpoint buffer manager
--------------------------------

After you’ve installed DBB endpoint buffer manager, you can run ``oods.py
--help`` to check if the installation was successful and see its usage.

.. _section-endpoint-configuration:

Configure DBB endpoint buffer manager
-------------------------------------

DBB endpoint buffer manager comes with an example configuration file,
``etc/oods.yaml``.  However, you can't use it without making few adjustments.

Firstly, you need to provide the location of the buffer and Gen2 repo in the
*ingester* section (here ``/data/buffer`` and ``/data/gen2repo`` respectively).

.. code-block::

   ingester:
     directories:
       - /data/buffer
     butler:
       class:
         import : lsst.ctrl.oods.gen2ButlerIngester
         name : Gen2ButlerIngester
         repoDirectory: /data/gen2repo
       batchSize: 20
       scanInterval:
         <<: *interval
         seconds: 10

.. note::

   ``scanInterval`` indicates how often the manager will scan the buffer for
   new files.  While it's not required, you may set it to value you consider
   reasonable in your case.  You should left other options unchanged, unless
   you know what you're doing.

Finally, you need to disable file cleaner. You can achieve this by creating an
empty directory

.. code-block::

   mkdir /tmp/empty

and updating *cacheCleaner* section accordingly

.. code-block::

   cacheCleaner:
     directories:
       - /tmp/empty
     scanInterval:
       <<: *interval
       seconds: 30
     filesOlderThan:
       <<: *interval
       days: 30 
     directoriesEmptyForMoreThan:
       <<: *interval
       days: 1

.. note::

   For initial version of the manager, the intent is to use OODS "as is".
   However, OODSs' goal is slightly different comparing to DBB ingest service.
   As a result, it removes periodically files it considers obsolete from the
   Gen2 repo.  This "workaround" will not be necessary in the future.

.. _section-dbbis-setup:

Set up DBB endpoint buffer manager
----------------------------------

Before you can start DBB endpoint buffer manager, you need to set up LSST stack
and ``ctrl_oods``.  

Let the locations where the stack and ``ctrl_oods`` are installed be defined by
environmental variables ``LSSTSW`` and ``ADDONSW`` respectively, e.g.,

.. code-block::

   export LSSTSW="/software/lsstsw/stack"
   export ADDONSW="/software/lsstsw/addons"

Then you can set LSST stack up with

.. code-block::

   source ${LSSTSW}/loadLSST.bash
   setup lsst_distrib
   # or setup lsst_distrib -t <tag, e.g., w_2020_09>

If needed, setup other special versions of packages, e.g., 

.. code-block::

   setup -j obs_lsst -t <tag>
   # or cd /to/my/build/of/package; setup -j -r .

Finally, set up ``ctrl_oods`` itself

.. code-block::

   setup -j -r ${ADDONSW}/ctrl_oods

.. note::

   For conveniece, you may want to set ``LSSTSW`` and ``ADDONSW`` variables in
   your ``.bashrc`` and then run ``source ~/.bashrc`` or open a new terminal
   for changes to take effect.

.. _section-endpoint-running:

Start DBB endpoint buffer manager
---------------------------------

The repository you cloned contains a helping script, ``bin/start_oods.sh``
which simplifies starting DBB endpoint buffer manager.  Copy it to a location
searched by shell for executables (e.g. ``$HOME/bin`` on Centos)

.. code-block::

   cp bin/start_oods.sh $HOME/bin

Then you can start DBB ingest service with

.. code-block::

   start_oods.sh oods.yaml
   
where ``oods.yaml`` is the configuration file you prepared in :ref:`previous
step <section-dbbis-configuration>`.

.. note::

   By default, the all messages are logged to ``/var/log/oods.log``. You can
   changed the defult location using ``-l`` option. Run ``start_oods.sh -h``
   for help.
