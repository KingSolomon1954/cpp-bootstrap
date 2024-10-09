*******************
Design of |AppName|
*******************

This document describes the design of |AppName| version |version|.

.. include:: /include/introduction.rst

This document is primarily for developers maintaining the
application itself, however, other interested developers and
engineers may find it useful.

.. contents:: Table of Contents
   :depth: 1
   :local:

User Story
==========

As a user of |AppName|, I want to:

* TBS
* TBS
* TBS

Design Goals
============

Important application design goals and constraints:

* Goal 1
* Goal 2

System Context
==============

.. admonition:: Instructions
   
   In this section describe the application's position in the context of
   a larger system of applications, if such is the case. Then eliminate
   this admonition from the design-doc.rst file. If your application is
   more of a standalone application then just delete this section, as
   the next section covers application context.

|AppName| is a high performance C++ application that is
part of a larger system.

.. figure:: /images/pub/ContextSystem.png
   :alt: System Context View

   **Figure:** System Context View

Be aware that the above figure is a simplified approximation of
the actual system.

Application Context
===================

.. admonition:: Instructions

   In this section describe the application's view of its processing
   context. Create or modify the following diagram to agree with your
   app. Then eliminate this admonition from the design-doc.rst file.

The following figure shows |AppName|'s view of its processing
environment.

.. figure:: /images/pub/ContextApplication.png
    :alt: Application Context Diagram

    **Figure:** Application Context Diagram

<Add text describing context. Should mention all items shown
on context diagram.>
    
Interfaces
----------

|AppName| communicates with several external components over several
interfaces. This section briefly identifies those interfaces and the
type of messages associated with each.

As seen in the application context diagram above, |AppName|
interfaces with the following external components:

**Interface 1**

* Protocol
* Messages

**Interface 2**

* Protocol
* Messages

Design
======

The design is a C++ single process application with multiple
threads. C++ is used due to its performance characteristics.
This section presents the major design elements.

<Add more description>

Processing Flow
---------------

<Describe processing flow to agree with diagram>

.. figure:: /images/pub/ProcessingFlow.png
    :alt: Processing Flow

    **Figure:** Processing Flow

.. admonition:: Instructions

   A sampling of important design elements are given below and should be
   discussed in most any design. Eliminate those that are not appropriate
   for your application. Add elements that might be missing. Note that
   you must add your own elements that focus on the significant
   processing which is the purpose of your application.  For example a
   satellite processing application might have a design element called
   SatelliteManager.

Command Line
------------

TBS

Startup/Shutdown
----------------

TBS

Logging Design
--------------

TBS

Memory Management
-----------------

TBS

Global Data
-----------

TBS

Threads
-------

TBS

Security
--------

TBS

Timers
------

TBS

Properties
----------

TBS

Configuration
-------------

TBS

Error Handling
--------------

TBS

.. figure:: /images/pub/ErrorSeq.png
   :alt: Error Sequence Diagram

   **Figure:** Error Sequence Diagram

State Management
----------------

TBS

.. figure:: /images/pub/StateDiagram.png
   :alt: State Diagram

   **Figure:** State Diagram

Statistics
----------

TBS

Persistence
-----------

TBS

Library General
===============

TBS

Library CODEC
=============

TBS

CRC Cards
=========

This section presents the high level identification of the major classes
in |AppName|. First a static UML class diagram is presented. Then
each major class, in its own paragraph is presented using the CRC cards
design methodology.

CRC cards is succinct methodology for object oriented designs where CRC
stands for classes, responsibilities, and collaborations. CRC cards are
used to discover, collect and document class information. Using CRC
cards, each card represents a class and its properties, and is shown in
its own paragraph. See `Extreme Programming CRC Cards
<http://www.extremeprogramming.org/rules/crccards.html>`_ or `wikipedia
<https://en.wikipedia.org/wiki/Class-responsibility-collaboration_card>`_.

.. figure:: /images/pub/StaticClassDiagram.png
   :alt: Static Class Diagram

   **Figure:** Static Class Diagram

LogManager CRC Card
-------------------

TBS

ErrorManager CRC Card
---------------------

TBS
   
Quality Attributes
==================

This section identifies the quality attributes that are most important
in this design. The first group of elements are considered the higher
priority concerns for the design of this application.

.. admonition:: Instructions

   Modify this section appropriate for your application.

| *Correctness*
| *Usability*
| *Readability*
| *Maintainability*
| *Completeness*
| *Performance*

The following quality attributes are less of a concern in this design:

| *Timeliness*
| *Reliability*
| *Robustness*
| *Efficiency*
| *Capacity*
| *Scalability*
| *Compatibility*
| *Interoperability*
| *Integrity/Security*
| *Adaptability*
| *Configurability*
| *Accuracy*
| *Repeatability*
| *Buildability*
| *Flexibility*
| *Portability*
| *Reusability*
| *Testability*
| *Understandability*

Collateral Design
=================

Language
--------

Implementation language is C++.

Building
--------

Uses the standard project build architecture.

COTS
----

Links with COTS gRPC community library.

Packaging
---------

Packaged as an RPM.

Automated Unit Testing
----------------------

Classes are unit tested using the COTS doctest framework.

Automated Component Testing
---------------------------

TBS

Automated Integration Testing
-----------------------------

TBS
