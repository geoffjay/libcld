=============
Configuration
=============

Acquisition Controller
^^^^^^^^^^^^^^^^^^^

This section shows how to add an abstract controller to a configuration file.

.. code-block:: xml
   :linenos:

   <cld:object id="acc0" type="acc">

**Table of Configurable Attribute**

+-----------+---------------+
| attribute | default value |
+-----------+---------------+
| id        | null          |
+-----------+---------------+
| name      | null          |
+-----------+---------------+
| type      | null          |
+-----------+---------------+
| driver    | null          |
+-----------+---------------+

**Table of Configurable Property**

+---------------+-----------+---------------+
| property      | data type | default value |
+---------------+-----------+---------------+
| fifo          | string    | null          |
+---------------+-----------+---------------+
| device        | string    | null          |
+---------------+-----------+---------------+
| multiplexer   | string    | null          |
+---------------+-----------+---------------+

Analog Input Channel
^^^^^^^^^^^^^^^^^^^^

This section shows how to add an analog input channel to a configuration file.

.. code-block:: xml
   :linenos:

   <cld:object id="aic0" type="aic">

**Table of Configurable Attribute**

+-----------+---------------+
| attribute | default value |
+-----------+---------------+
| id        | null          |
+-----------+---------------+
| ref       | null          |
+-----------+---------------+
| name      | null          |
+-----------+---------------+

**Table of Configurable Property**

+---------------+-----------+---------------+
| property      | data type | default value |
+---------------+-----------+---------------+
| tag           | string    | null          |
+---------------+-----------+---------------+
| desc          | string    | null          |
+---------------+-----------+---------------+
| num           | int       | null          |
+---------------+-----------+---------------+
| subdevnum     | int       | null          |
+---------------+-----------+---------------+
| naverage      | int       | null          |
+---------------+-----------+---------------+
| calref        | string    | null          |
+---------------+-----------+---------------+
| range         | int       | null          |
+---------------+-----------+---------------+
| alias         | string    | null          |
+---------------+-----------+---------------+

Analog Output Channel
^^^^^^^^^^^^^^^^^^^^^

This section shows how to add an analog output channel to a configuration file.

.. code-block:: xml
   :linenos:

   <cld:object id="aoc0" type="aoc">

**Table of Configurable Attribute**

+-----------+---------------+
| attribute | default value |
+-----------+---------------+
| id        | null          |
+-----------+---------------+
| ref       | null          |
+-----------+---------------+
| name      | null          |
+-----------+---------------+

**Table of Configurable Property**

+---------------+-----------+---------------+
| property      | data type | default value |
+---------------+-----------+---------------+
| tag           | string    | null          |
+---------------+-----------+---------------+
| desc          | string    | null          |
+---------------+-----------+---------------+
| num           | int       | null          |
+---------------+-----------+---------------+
| subdevnum     | int       | null          |
+---------------+-----------+---------------+
| calref        | string    | null          |
+---------------+-----------+---------------+
| range         | int       | null          |
+---------------+-----------+---------------+
| alias         | string    | null          |
+---------------+-----------+---------------+

Automation Controller
^^^^^^^^^^^^^^^^^^^^^

.. code-block:: xml
   :linenos:

   <cld:object id="ac0" type="ac">

**Table of Configurable Attribute**

+-----------+---------------+
| attribute | default value |
+-----------+---------------+
| id        | null          |
+-----------+---------------+
| ref       | null          |
+-----------+---------------+

**Table of Configurable Property**

+---------------+-----------+---------------+
| property      | data type | default value |
+---------------+-----------+---------------+
| pid           | string    | null          |
+---------------+-----------+---------------+
| pid-2         | string    | null          |
+---------------+-----------+---------------+

Calibration
^^^^^^^^^^^

.. code-block:: xml
   :linenos:

   <cld:object id="cali0" type="cali">

**Table of Configurable Attribute**

+-----------+---------------+
| attribute | default value |
+-----------+---------------+
| id        | null          |
+-----------+---------------+
| name      | null          |
+-----------+---------------+
| type      | null          |
+-----------+---------------+

**Table of Configurable Property**

+---------------+-----------+---------------+
| property      | data type | default value |
+---------------+-----------+---------------+
| unit          | string    | null          |
+---------------+-----------+---------------+

Coefficient
^^^^^^^^^^^

.. code-block:: xml
   :linenos:

   <cld:object id="coe0" type="coe">

**Table of Configurable Attribute**

+-----------+---------------+
| attribute | default value |
+-----------+---------------+
| id        | null          |
+-----------+---------------+
| name      | null          |
+-----------+---------------+

**Table of Configurable Property**

+----------+-----------+---------------+
| property | data type | default value |
+----------+-----------+---------------+
| n        | int       | null          |
+----------+-----------+---------------+
| value    | double    | null          |
+----------+-----------+---------------+

Comedy Device
^^^^^^^^^^^^^

.. code-block:: xml
   :linenos:

   <cld:object id="cd0" type="cd">

**Table of Configuration Attribute**

+-----------+---------------+
| attribute | default value |
+-----------+---------------+
| name      | null          |
+-----------+---------------+
| type      | null          |
+-----------+---------------+

**Table of Configuration Property**

+----------+-----------+---------------+
| property | data type | default value |
+----------+-----------+---------------+
| filename | string    | null          |
+----------+-----------+---------------+
| type     | string    | null          |
+----------+-----------+---------------+
| task     | string    | null          |
+----------+-----------+---------------+
| channel  | string    | null          |
+----------+-----------+---------------+

Comedy Task
^^^^^^^^^^^

.. code-block:: xml
   :linenos:

   <cld:object id="ct0" type="ct">

**Table of Configuration Attribute**

+-----------+---------------+
| attribute | default value |
+-----------+---------------+
| id        | null          |
+-----------+---------------+
| name      | null          |
+-----------+---------------+

**Table of Configuration Property**

+---------------+-----------+---------------+
| property      | data type | default value |
+---------------+-----------+---------------+
| devref        | string    | null          |
+---------------+-----------+---------------+
| subdevice     | int       | null          |
+---------------+-----------+---------------+
| exec-type     | string    | null          |
+---------------+-----------+---------------+
| direction     | string    | null          |
+---------------+-----------+---------------+
| interval-ms   | int       | null          |
+---------------+-----------+---------------+
| interval-ns   | int64     | null          |
+---------------+-----------+---------------+
| resolution-ns | int       | null          |
+---------------+-----------+---------------+
| chref         | string    | null          |
+---------------+-----------+---------------+
| fifo          | string    | null          |
+---------------+-----------+---------------+

Control
^^^^^^^

.. code-block:: xml
   :linenos:

   <cld:object id="con0" type="con">

**Table of Configuration Attribute**

+-----------+---------------+
| attribute | default value |
+-----------+---------------+
| id        | null          |
+-----------+---------------+
| dsref     | null          |
+-----------+---------------+
| direction | null          |
+-----------+---------------+

**Table of Configuration Property**

+----------+-----------+---------------+
| property | data type | default value |
+----------+-----------+---------------+
| pid      | string    | null          |
+----------+-----------+---------------+
| pid-2    | string    | null          |
+----------+-----------+---------------+

Csv Log
^^^^^^^

.. code-block:: xml
   :linenos:

   <cld:object id="csv0" type="csv">

**Table of Configuration Attribute**

+-----------+---------------+
| attribute | default value |
+-----------+---------------+
| id        | null          |
+-----------+---------------+
| name      | null          |
+-----------+---------------+
| type      | null          |
+-----------+---------------+

**Table of Configuration Property**

+------------+---------------+---------------+
| property   | data type     | default value |
+------------+---------------+---------------+
| title      | string        | null          |
+------------+---------------+---------------+
| path       | string        | null          |
+------------+---------------+---------------+
| file       | string        | null          |
+------------+---------------+---------------+
| rate       | double        | null          |
+------------+---------------+---------------+
| format     | string        | null          |
+------------+---------------+---------------+
| time-stamp | TimeStampFlag | null          |
+------------+---------------+---------------+

Data Series
^^^^^^^^^^^

.. code-block:: xml
   :linenos:

   <cld:object id="ds0" type="ds">

**Table of Configuration Attribute**

+-----------+---------------+
| attribute | default value |
+-----------+---------------+
| id        | null          |
+-----------+---------------+
| name      | null          |
+-----------+---------------+

**Table of Configuration Property**

+------------+---------------+---------------+
| property   | data type     | default value |
+------------+---------------+---------------+
| length     | int           | null          |
+------------+---------------+---------------+
| chref      | string        | null          |
+------------+---------------+---------------+
| taps       | int           | null          |
+------------+---------------+---------------+
| alias      | string        | null          |
+------------+---------------+---------------+

Digital Input Channel
^^^^^^^^^^^^^^^^^^^^^

.. code-block:: xml
   :linenos:

   <cld:object id="dic0" type="dic">

**Table of Configuration Attribute**

+-----------+---------------+
| attribute | default value |
+-----------+---------------+
| id        | null          |
+-----------+---------------+
| ref       | null          |
+-----------+---------------+
| name      | null          |
+-----------+---------------+

**Table of Configurable Property**

+-----------+------------+---------------+
| property  | data type  | default value |
+-----------+------------+---------------+
| tag       | string     | null          |
+-----------+------------+---------------+
| desc      | string     | null          |
+-----------+------------+---------------+
| num       | int        | null          |
+-----------+------------+---------------+
| subdevnum | int        | null          |
+-----------+------------+---------------+

Digital Output Channel
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: xml
   :linenos:

   <cld:object id="doc0" type="doc">

**Table of Configuration Attribute**

+-----------+---------------+
| attribute | default value |
+-----------+---------------+
| id        | null          |
+-----------+---------------+
| ref       | null          |
+-----------+---------------+
| name      | null          |
+-----------+---------------+

**Table of Configurable Property**

+-----------+------------+---------------+
| property  | data type  | default value |
+-----------+------------+---------------+
| tag       | string     | null          |
+-----------+------------+---------------+
| desc      | string     | null          |
+-----------+------------+---------------+
| num       | int        | null          |
+-----------+------------+---------------+
| subdevnum | int        | null          |
+-----------+------------+---------------+

Log Column
^^^^^^^^^^

.. code-block:: xml
   :linenos:

   <cld:object id="lc0" type="lc">

**Table of Configuration Attribute**

+-----------+---------------+
| attribute | default value |
+-----------+---------------+
| id        | null          |
+-----------+---------------+
| chref     | null          |
+-----------+---------------+

This class contains no configurable properties.

Log Controller
^^^^^^^^^^^^^^

.. code-block:: xml
   :linenos:

   <cld:object id="loc0" type="loc">

**Table of Configuration Attribute**

+-----------+---------------+
| attribute | default value |
+-----------+---------------+
| id        | null          |
+-----------+---------------+
| type      | null          |
+-----------+---------------+

**Table of Configuration Property**

+-----------+------------+---------------+
| property  | data type  | default value |
+-----------+------------+---------------+
| log       | string     | null          |
+-----------+------------+---------------+

Math Channel
^^^^^^^^^^^^

.. code-block:: xml
   :linenos:

   <cld:object id="mc0" type="mc">

**Table of Configuration Attribute**

+-----------+---------------+
| attribute | default value |
+-----------+---------------+
| id        | null          |
+-----------+---------------+
| ref       | null          |
+-----------+---------------+
| name      | null          |
+-----------+---------------+

**Table of Configuration Property**

+------------+------------+---------------+
| property   | data type  | default value |
+------------+------------+---------------+
| tag        | string     | null          |
+------------+------------+---------------+
| desc       | string     | null          |
+------------+------------+---------------+
| expression | string     | null          |
+------------+------------+---------------+
| num        | string     | null          |
+------------+------------+---------------+
| calref     | string     | null          |
+------------+------------+---------------+
| dref       | string     | null          |
+------------+------------+---------------+
| alias      | string     | null          |
+------------+------------+---------------+

Multiplexer
^^^^^^^^^^^

.. code-block:: xml
   :linenos:

   <cld:object id="mult0" type="mult">

**Table of Configuration Attribute**

+-----------+---------------+
| attribute | default value |
+-----------+---------------+
| id        | null          |
+-----------+---------------+
| name      | null          |
+-----------+---------------+

**Table of Configuration Property**

+--------------+------------+---------------+
| property     | data type  | default value |
+--------------+------------+---------------+
| updat-stride | string     | null          |
+--------------+------------+---------------+
| taskref      | string     | null          |
+--------------+------------+---------------+

Pid
^^^

.. code-block:: xml
   :linenos:

   <cld:object id="pid0" type="pid">

**Table of Configuration Attribute**

+-----------+---------------+
| attribute | default value |
+-----------+---------------+
| id        | null          |
+-----------+---------------+
| name      | null          |
+-----------+---------------+
| type      | null          |
+-----------+---------------+


**Table of Configuration Property**

+-----------+------------+---------------+
| property  | data type  | default value |
+-----------+------------+---------------+
| sp        | double     | null          |
+-----------+------------+---------------+
| dt        | int        | null          |
+-----------+------------+---------------+
| kp        | double     | null          |
+-----------+------------+---------------+
| ki        | double     | null          |
+-----------+------------+---------------+
| kd        | double     | null          |
+-----------+------------+---------------+
| desc      | string     | null          |
+-----------+------------+---------------+

SerialPort
^^^^^^^^^^

.. code-block:: xml
   :linenos:

   <cld:object id="sp0" type="sp">

**Table of Configuration Attribute**

+-----------+---------------+
| attribute | default value |
+-----------+---------------+
| id        | null          |
+-----------+---------------+
| name      | null          |
+-----------+---------------+

**Table of Configuration Property**

+------------+------------+---------------+
| property   | data type  | default value |
+------------+------------+---------------+
| device     | string     | null          |
+------------+------------+---------------+
| baudrate   | int        | null          |
+------------+------------+---------------+
| databits   | int        | null          |
+------------+------------+---------------+
| stopbits   | int        | null          |
+------------+------------+---------------+
| parity     | parity     | null          |
+------------+------------+---------------+
| handshake  | handshake  | null          |
+------------+------------+---------------+
| accessmode | accessmode | null          |
+------------+------------+---------------+
| handshake  | echo       | null          |
+------------+------------+---------------+

Sqlite Log
^^^^^^^^^^

.. code-block:: xml
   :linenos:

   <cld:object id="sl0" type="sl">

**Table of Configuration Attribute**

+-----------+---------------+
| attribute | default value |
+-----------+---------------+
| id        | null          |
+-----------+---------------+
| name      | null          |
+-----------+---------------+
| type      | null          |
+-----------+---------------+

**Table of Configuration Property**

+---------------------+---------------+---------------+
| property            | data type     | default value |
+---------------------+---------------+---------------+
| title               | string        | null          |
+---------------------+---------------+---------------+
| path                | string        | null          |
+---------------------+---------------+---------------+
| file                | string        | null          |
+---------------------+---------------+---------------+
| rate                | double        | null          |
+---------------------+---------------+---------------+
| format              | string        | null          |
+---------------------+---------------+---------------+
| time-stamp          | TimeStampFlag | null          |
+---------------------+---------------+---------------+
| backup-path         | string        | null          |
+---------------------+---------------+---------------+
| backup-file         | string        | null          |
+---------------------+---------------+---------------+
| backup-interval-hrs | int           | null          |
+---------------------+---------------+---------------+
| data-source         | string        | null          |
+---------------------+---------------+---------------+

V Channel
^^^^^^^^^

.. code-block:: xml
   :linenos:

   <cld:object id="vc0" type="vc">

**Table of Configuration Attribute**

+-----------+---------------+
| attribute | default value |
+-----------+---------------+
| id        | null          |
+-----------+---------------+
| ref       | null          |
+-----------+---------------+
| name      | null          |
+-----------+---------------+

**Table of Configuration Property**

+------------+-----------+---------------+
| property   | data type | default value |
+------------+-----------+---------------+
| tag        | string    | null          |
+------------+-----------+---------------+
| desc       | string    | null          |
+------------+-----------+---------------+
| expression | string    | null          |
+------------+-----------+---------------+
| num        | int       | null          |
+------------+-----------+---------------+
| calref     | string    | null          |
+------------+-----------+---------------+
| devref     | string    | null          |
+------------+-----------+---------------+
