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
   cd dbb_buffmngrs_deploy/handoff

.. _section-handoff-configuration:

Configure DBB handoff buffer manager
------------------------------------

You can find an example configuration file in ``etc/config.yaml``.  Only
**database**, **handoff**, and **endpoint** sections are required, others are
optional and are only provided for sake of completeness.

In the **database** section you really only need to specify **engine**, so
called **connect string* which informs the manager where the database is
located and what protocl to use to establish a connection with it.

In the **handoff** section you need to specify two directories:

#. **buffer**: directory where files are being written to,
#. **holding** area: directory where files will be moved after being
   transferred successfully. 

.. warning::

   When deploying the mangeer in a Docker container, both directories specify
   locations *in* the container!  They will most likely be different from
   actual directories on the host system and will also depend on actual bind
   mounts (see :ref:`section-handoff-mounts`).

In **endpoint** section you need to specify two directories (in any order):

1. **staging** area: directory where the files are being transferred to,
2. **buffer** directory where the files will be moved after transfer is
   completed,

as well as

3. **host**: the name of the host acting as the endpoint site,
4. **user**: a user account to use on the endpoint site for authentication
   purposes.
5. **commands**: shell commands which the manager should use to execute
   commands remotely on the endpoint site and to transfer files.

.. warning::

   Getting commands described above right is *crucial* for proper functioning
   of the manager.  So either stick to the provided defaults or really do know
   what you're doing when altering them.

.. warning::

   The handoff manager uses SSH protocol to securly execute remote commands and
   deliver files to the endpoint site.  SSH protocol requires some for of
   authentication and the manager uses an SSH key for that purpose.  Make sure
   that the public part of that SSH key is present in `authorized_keys` file of
   the account you specified in the **endpoint** section.


By default, ``${HOME}/local/etc`` is bind mounted in the docker image to
``~/local/etc`` so each configuration file created in this directory will be
available in the resultant docker container.  To select which configuration
should be used by the handoff manager when the container is started, adjust the
path in the **command** option in ``docker-compose.yaml``.

.. note::

   The included Compose file (see :ref:`section-handoff-manage`) allow one to
   start buffer managers for two separate instruments: AuxTel (section
   **at-dbbm**) and ComCam (section **cc-dbbbm**).  By default, their
   configurations are read from ``at_dbbbm_config.yaml`` and
   ``cc_dbbbm_config.yaml`` respectively.  Feel free to repurpose them according
   to your needs.

Logging
^^^^^^^

By default, DBB handoff buffer manager outputs log messages on stdout/stderr.
However, enabling logging to a file is highly recommended.  You can achieve it
by specifying **file** option in **logging** section, for example:

.. code-block::
   
   logging:
     file: /var/log/handoff.log

Keep in mind though that in order to easily view the log file outside of the
container, you need to bind mount a writable directory from the host machine to
that location (see :ref:`section-handoff-mounts` for details).

.. _section-handoff-manage:

Manage the manager
------------------

Actions such as:

* building Docker image with the handoff manager,
* starting/stopping the manager for a given instrument,

are managed centrally with help of ``docker-compose`` and service configuration
files: ``env.bash`` and ``docker-compose.yaml``.

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

There are six crucial bind mounts for each instrument:

#. the buffer
#. the holding area,
#. directory with the configuration files,
#. directory with the SQLite database,
#. directory where logs are kept,
#. directory with SSH keys needed to access to the endpoint site (usually
  ``~/.ssh``).

These bind mounts are defined in **volumes** section for each buffer manager in
``docker-compose.yaml``.  You need to make sure that the bind mounts accurately
reflect actual setup!

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
      docker-compose build at-dbbbm

.. _section-handoff-starting:

Start the container
-------------------

Once you created a configuration files satisfying your needs, adjusted the bind
mounts you are ready to start the container with handoff buffer manager.

If you haven't done it already, initialize runtime environment with

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

The DBB endpoint manager is available on GitHub. Clone the repository with

.. code-block::

   git clone https://github.com/lsst-dm/dbb_buffmngrs_endpoint
   cd dbb_buffmngrs_endpoint

and follow the instructions in
``doc/lsst.dbb.buffmngrs.endpoint/get-started.rst``.

.. note::

   You can build and preview this document in your browser by following the
   instructions from the `LSST Developer Guide`_.

.. __: https://developer.lsst.io/stack/building-single-package-docs.html
