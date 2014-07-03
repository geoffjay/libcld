#!/usr/bin/env python
#! -*- coding: utf-8 -*-

from gi.repository import Cld
import libxml2, sys

xml = """
<cld xmlns:cld="urn:libcld">
    <cld:objects>
        <cld:object id="daqctl0" type="controller" ctype="acquisition">
            <cld:object id="dev0" type="device" driver="comedi">
                <cld:property name="hardware">PCI-1713</cld:property>
                <cld:property name="type">input</cld:property>
                <cld:property name="file">/dev/comedi0</cld:property>
                <cld:object id="tk0" type="task" ttype="comedi">
                    <cld:property name="exec-type">polling</cld:property>
                    <cld:property name="subdevice">0</cld:property>
                    <cld:property name="direction">read</cld:property>
                    <cld:property name="interval-ms">100</cld:property>
                    <cld:object id="tkch0" type="channel" chref="ai0"/>
                </cld:object>
            </cld:object>
        </cld:object>

        <cld:object id="logctl0" type="controller" ctype="log">
            <cld:object id="log0" type="log" ltype="csv">
                <cld:property name="title">Data Log</cld:property>
                <cld:property name="path">./</cld:property>
                <cld:property name="file">log.dat</cld:property>
                <cld:property name="format">%F-%T</cld:property>
                <cld:property name="rate">10.000</cld:property>
                <cld:object id="col0" type="column" chref="ai0"/>
            </cld:object>
        </cld:object>

        <cld:object id="cal0" type="calibration">
            <cld:property name="units">Volts</cld:property>
            <cld:object id="cft0" type="coefficient">
                <cld:property name="n">0</cld:property>
                <cld:property name="value">0.000</cld:property>
            </cld:object>
            <cld:object id="cft1" type="coefficient">
                <cld:property name="n">1</cld:property>
                <cld:property name="value">1.000</cld:property>
            </cld:object>
        </cld:object>

        <cld:object id="ai0" type="channel" ref="/daqctl0/dev0" ctype="analog" direction="input">
            <cld:property name="tag">IN0</cld:property>
            <cld:property name="desc">Sample Input</cld:property>
            <cld:property name="num">0</cld:property>
            <cld:property name="calref">/cal0</cld:property>
            <cld:property name="taskref">/daqctl0/dev0/tk0</cld:property>
        </cld:object>
        <cld:object id="ao0" type="channel" ref="/daqctl0/dev0" ctype="analog" direction="output">
            <cld:property name="tag">OUT0</cld:property>
            <cld:property name="desc">Output1</cld:property>
            <cld:property name="num">0</cld:property>
            <cld:property name="calref">/cal0</cld:property>
            <cld:property name="taskref">/daqctl0/dev0/tk1</cld:property>
        </cld:object>

        <cld:object id="autoctrl0" type="controller" ctype="automation">
            <cld:object id="ctl0" type="control">
                <cld:object id="pid0" type="pid-2">
                    <cld:property name="desc">PID0</cld:property>
                    <cld:property name="dt">10</cld:property>
                    <cld:property name="sp">0.000000</cld:property>
                    <cld:property name="kp">0.000000</cld:property>
                    <cld:property name="ki">0.020000</cld:property>
                    <cld:property name="kd">0.000000</cld:property>
                    <cld:object id="pv0" type="process_value" chref="ai0"/>
                    <cld:object id="pv1" type="process_value" chref="ao0"/>
                </cld:object>
            </cld:object>
        </cld:object>
    </cld:objects>
</cld>
"""

if __name__ == '__main__':
    # Create context from XML
    doc = libxml2.parseMemory(xml, len(xml))
    ctxt = doc.xpathNewContext()
    ctxt.xpathRegisterNs("cld", "urn:libcld")
    res = ctxt.xpathEval("//cld/cld:objects")
    print "1"
    config = Cld.XmlConfig.from_node(res[0])
    builder = Cld.Builder.from_xml_config(config)
    context = Cld.Context()
    print "2"
    context.objects = builder.objects
    print "3"
    chan = context.get_object("ai0")
    print chan.id
