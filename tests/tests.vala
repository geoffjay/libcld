/**
 * libcld
 * Copyright (c) 2015-2017, Geoff Johnson, All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3.0 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library.
 */

public int main (string[] args) {
	Test.init (ref args);
    Test.bug_base ("https://github.com/geoffjay/libcld/issues/%s");

    /* Non-instantiable interface dummy implementations */
    TestSuite.get_root ().add_suite (new DummyObjectTests ().get_suite ());
	TestSuite.get_root ().add_suite (new DummyContainerTests ().get_suite ());

	//TestSuite.get_root ().add_suite (new BuildableTests ().get_suite ());
	//TestSuite.get_root ().add_suite (new ChannelTests ().get_suite ());
	//TestSuite.get_root ().add_suite (new PortTests ().get_suite ());

	//TestSuite.get_root ().add_suite (new BuilderTests ().get_suite ());
	//TestSuite.get_root ().add_suite (new ContextTests ().get_suite ());

	//TestSuite.get_root ().add_suite (new DeviceTests ().get_suite ());
	//TestSuite.get_root ().add_suite (new ComediDeviceTests ().get_suite ());
	//TestSuite.get_root ().add_suite (new ModbusDeviceTests ().get_suite ());

	//TestSuite.get_root ().add_suite (new TaskTests ().get_suite ());
	//TestSuite.get_root ().add_suite (new ComediTaskTests ().get_suite ());

	//TestSuite.get_root ().add_suite (new FilterTests ().get_suite ());

	TestSuite.get_root ().add_suite (new FlowSensorTests ().get_suite ());
	//TestSuite.get_root ().add_suite (new TemperatureSensorTests ().get_suite ());
	//TestSuite.get_root ().add_suite (new PressureSensorTests ().get_suite ());

	TestSuite.get_root ().add_suite (new AIChannelTests ().get_suite ());
	//TestSuite.get_root ().add_suite (new AOChannelTests ().get_suite ());
	//TestSuite.get_root ().add_suite (new DIChannelTests ().get_suite ());
	//TestSuite.get_root ().add_suite (new DOChannelTests ().get_suite ());
	//TestSuite.get_root ().add_suite (new VChannelTests ().get_suite ());
	//TestSuite.get_root ().add_suite (new MathChannelTests ().get_suite ());

	//TestSuite.get_root ().add_suite (new ControllerTests ().get_suite ());
	//TestSuite.get_root ().add_suite (new AcquisitionControllerTests ().get_suite ());
	//TestSuite.get_root ().add_suite (new LogControllerTests ().get_suite ());
	//TestSuite.get_root ().add_suite (new AutomationControllerTests ().get_suite ());

	//TestSuite.get_root ().add_suite (new ControlTests ().get_suite ());
	//TestSuite.get_root ().add_suite (new PidTests ().get_suite ());

	TestSuite.get_root ().add_suite (new CalibrationTests ().get_suite ());
	//TestSuite.get_root ().add_suite (new CoefficientTests ().get_suite ());

	//TestSuite.get_root ().add_suite (new LogTests ().get_suite ());
	//TestSuite.get_root ().add_suite (new CsvLogTests ().get_suite ());
	//TestSuite.get_root ().add_suite (new SQLiteLogTests ().get_suite ());

	//TestSuite.get_root ().add_suite (new SerialPortTests ().get_suite ());
	//TestSuite.get_root ().add_suite (new SocketPortTests ().get_suite ());
	//TestSuite.get_root ().add_suite (new ModbusPortTests ().get_suite ());

	return Test.run ();
}
