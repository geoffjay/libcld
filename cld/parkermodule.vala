/**
 * Copyright (C) 2010 Geoff Johnson
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 *
 * Author:
 *  Geoff Johnson <geoff.jay@gmail.com>
 *  Steve Roy <sroy1966@gmail.com>
 */
using Posix;

/**
 * This is very much intended to service an immediate specific need and will not
 * be suitable for a generic scenario.
 */
public class Cld.ParkerModule : AbstractModule {

    /* Parker Comapx3 I12 T11 Objects */
    public const string C3_AnalogInput0_Gain                                                = "170.2"     ;
    public const string C3_AnalogInput0_Offseti                                             = "170.4"     ;
    public const string C3_AnalogInput1_Gain                                                = "171.2"     ;
    public const string C3_AnalogInput1_Offset                                              = "171.4"     ;
    public const string C3_D_CurrentController_Ld_Lq_Ratio                                  = "2230.20"   ;
    public const string C3_ControllerTuning_ActuatingSpeedSignalFilt_us                     = "2100.20"   ;
    public const string C3_ControllerTuning_CurrentBandwidth                                = "2100.8"    ;
    public const string C3_ControllerTuning_CurrentDamping                                  = "2100.9"    ;
    public const string C3_ControllerTuning_FilterAccel_us                                  = "2100.21"   ;
    public const string C3_ControllerTuning_FilterAccel2                                    = "2100.11"   ;
    public const string C3_ControllerTuning_FilterSpeed2                                    = "2100.10"   ;
    public const string C3_D_CurrentController_VoltageDecouplingEnable                      = "2230.24"   ;
    public const string C3_Delay_MasterDelay                                                = "990.1"     ;
    public const string C3_DeviceSupervision_DeviceAdr                                      = "84.4"      ;
    public const string C3_DeviceSupervision_DeviceCounter                                  = "84.3"      ;
    public const string C3_DeviceSupervision_OperatingTime                                  = "84.5"      ;
    public const string C3_DeviceSupervision_ThisDevice                                     = "84.2"      ;
    public const string C3_Diagnostics_DeviceState                                          = "85.1"      ;
    public const string C3_DigitalInput_DebouncedValue                                      = "120.3"     ;
    public const string C3_DigitalInput_Value                                               = "120.2"     ;
    public const string C3_DigitalInputAddition_Value                                       = "121.2"     ;
    public const string C3_DigitalOutputAddition_Value                                      = "133.3"     ;
    public const string C3_ErrorHistory_1                                                   = "550.2"     ;
    public const string C3_ErrorHistoryNumber_1                                             = "87.1"      ;
    public const string C3_ErrorHistoryPointer_LastEntry                                    = "86.1"      ;
    public const string C3_ErrorHistoryTime_1                                               = "88.1"      ;
    public const string C3_ExternalSignal_Position                                          = "2020.1"    ;
    public const string C3_FeedForward_EMF                                                  = "2010.20"   ;
    public const string C3_FeedForwardExternal_FilterAccel                                  = "2011.2"    ;
    public const string C3_FeedForwardExternal_FilterAccel_us                               = "2011.5"    ;
    public const string C3_FeedForwardExternal_FilterSpeed                                  = "2011.1"    ;
    public const string C3_FeedForwardExternal_FilterSpeed_us                               = "2011.4"    ;
    public const string C3_Magnetization_current_controller_Bandwidth                       = "2240.7"    ;
    public const string C3_Magnetization_current_controller_Damping                         = "2240.4"    ;
    public const string C3_Magnetization_current_controller_Field                           = "2240.11"   ;
    public const string C3_Magnetization_current_controller_Imrn_DemandValueTuning          = "2240.2"    ;
    public const string C3_Magnetization_current_controller_RotorTimeConstant               = "2240.10"   ;
    public const string C3_Magnetization                                                    = "2240.9"    ;
    public const string C3_Q_CurrentController_BackEMF                                      = "2220.22"   ;
    public const string C3_Q_CurrentController_Inductance                                   = "2220.20"   ;
    public const string C3_Q_CurrentController_Resistance                                   = "2220.21"   ;
    public const string C3_Q_CurrentController_StructureSelection                           = "2220.27"   ;
    public const string C3_StatusCurrent_PhaseU                                             = "688.9"     ;
    public const string C3_StatusCurrent_PhaseV                                             = "688.10"    ;
    public const string C3_StatusCurrent_Reference                                          = "688.1"     ;
    public const string C3_StatusCurrent_ReferenceDINT                                      = "688.18"    ;
    public const string C3_StatusSpeed_Error                                                = "681.6"     ;
    public const string C3_StatusSpeed_FeedForwardSpeed                                     = "681.11"    ;
    public const string C3_StatusSpeed_LoadControlFiltered                                  = "681.21"    ;
    public const string C3_SpeedController_ActualBandwidth                                  = "2210.17"   ;
    public const string C3_SpeedController_I_Part_Gain                                      = "2210.5"    ;
    public const string C3_SpeedController_P_Part_Gain                                      = "2210.4"    ;
    public const string C3_SpeedObserver_DisturbanceAdditionEnable                          = "2120.7"    ;
    public const string C3_SpeedObserver_DisturbanceFilter                                  = "2120.5"    ;
    public const string C3_SpeedObserver_TimeConstant                                       = "2120.1"    ;
    public const string C3_StatusAccel_Actual                                               = "682.5"     ;
    public const string C3_StatusAccel_ActualFilter                                         = "682.6"     ;
    public const string C3_StatusAccel_DemandValue                                          = "682.4"     ;
    public const string C3_StatusAccel_FeedForwardAccel                                     = "682.7"     ;
    public const string C3_StatusAutocommutation_Itterations                                = "690.5"     ;
    public const string C3_StatusCurrent_Actual                                             = "688.2"     ;
    public const string C3_StatusCurrent_ActualDINT                                         = "688.19"    ;
    public const string C3_StatusCurrent_ControlDeviationIq                                 = "688.8"     ;
    public const string C3_StatusCurrent_DecouplingVoltageUd                                = "688.31"    ;
    public const string C3_StatusCurrent_FeedForwardbackEMF                                 = "688.32"    ;
    public const string C3_StatusCurrent_FeedForwordCurrentJerk                             = "688.14"    ;
    public const string C3_StatusCurrent_ReferenceJerk                                      = "688.13"    ;
    public const string C3_StatusCurrent_ReferenceVoltageUq                                 = "688.11"    ;
    public const string C3_StatusCurrent_ReferenceVoltageVector                             = "688.22"    ;
    public const string C3_StatusCurrent_VoltageUd                                          = "688.30"    ;
    public const string C3_StatusCurrent_VoltageUq                                          = "688.29"    ;
    public const string C3_StatusDevice_ActualDeviceLoad                                    = "683.2"     ;
    public const string C3_StatusDevice_ActualMotorLoad                                     = "683.3"     ;
    public const string C3_StatusDevice_ObservedDisturbance                                 = "683.5"     ;
    public const string C3_StatusFeedback_EncoderCosine                                     = "692.4"     ;
    public const string C3_StatusFeedback_EncoderSine                                       = "692.3"     ;
    public const string C3_StatusFeedback_FeedbackCosineDSP                                 = "692.2"     ;
    public const string C3_StatusFeedback_FeedbackSineDSP                                   = "692.1"     ;
    public const string C3_StatusFeedback_FeedbackVoltage_Vpp                               = "692.5"     ;
    public const string C3_StatusPosition_Actual                                            = "680.5"     ;
    public const string C3_StatusPosition_ActualController                                  = "680.13"    ;
    public const string C3_StatusPosition_DemandController                                  = "680.12"    ;
    public const string C3_StatusPosition_DemandValue                                       = "680.4"     ;
    public const string C3_StatusPosition_FollowingError                                    = "680.6"     ;
    public const string C3_StatusPosition_LoadControlActual                                 = "680.23"    ;
    public const string C3_StatusPosition_LoadControlDeviation                              = "680.20"    ;
    public const string C3_StatusPosition_LoadControlDeviationFiltered                      = "680.22"    ;
    public const string C3_StatusSpeed_Actual                                               = "681.5"     ;
    public const string C3_StatusSpeed_ActualFiltered                                       = "681.9"     ;
    public const string C3_StatusSpeed_ActualScaled                                         = "681.12"    ;
    public const string C3_StatusSpeed_DemandScaled                                         = "681.13"    ;
    public const string C3_StatusSpeed_DemandSpeedController                                = "681.10"    ;
    public const string C3_StatusSpeed_DemandValue                                          = "681.4"     ;
    public const string C3_StatusSpeed_NegativeLimit                                        = "681.25"    ;
    public const string C3_StatusSpeed_PositiveLimit                                        = "681.24"    ;
    public const string C3_StatusTemperature_Motor                                          = "684.2"     ;
    public const string C3_StatusTemperature_PowerStage                                     = "684.1"     ;
    public const string C3_StatusVoltage_AnalogInput0                                       = "685.3"     ;
    public const string C3_StatusVoltage_AnalogInput1                                       = "685.4"     ;
    public const string C3_StatusVoltage_AuxiliaryVoltage                                   = "685.1"     ;
    public const string C3_StatusVoltage_BusVoltage                                         = "685.2"     ;
    public const string C3Array_Col01_Row01                                                 = "1901.1"    ;
    public const string C3Array_Col02_Row01                                                 = "1902.1"    ;
    public const string C3Array_Col03_Row01                                                 = "1903.1"    ;
    public const string C3Array_Col04_Row01                                                 = "1904.1"    ;
    public const string C3Array_Col05_Row01                                                 = "1905.1"    ;
    public const string C3Array_Col06_Row01                                                 = "1906.1"    ;
    public const string C3Array_Col07_Row01                                                 = "1907.1"    ;
    public const string C3Array_Col08_Row01                                                 = "1908.1"    ;
    public const string C3Array_Col09_Row01                                                 = "1909.1"    ;
    public const string C3Array_Indirect_Col01                                              = "1910.1"    ;
    public const string C3Array_Pointer_Row                                                 = "1900.1"    ;
    public const string C3Plus_AnalogInput0_FilterCoefficient                               = "170.3"     ;
    public const string C3Plus_AnalogInput1_FilterCoefficient                               = "171.3"     ;
    public const string C3Plus_AutoCommutationControl_InitialCurrent                        = "2190.2"    ;
    public const string C3Plus_AutoCommutationControl_MotionReduction                       = "2190.4"    ;
    public const string C3Plus_AutoCommutationControl_PeakCurrent                           = "2190.8"    ;
    public const string C3Plus_AutoCommutationControl_PositionThreshold                     = "2190.3"    ;
    public const string C3Plus_AutoCommutationControl_Ramptime                              = "2190.1"    ;
    public const string C3Plus_AutoCommutationControl_Reset                                 = "2190.10"   ;
    public const string C3Plus_AutoCommutationControl_StandstillThreshold                   = "2190.7"    ;
    public const string C3Plus_DeviceControl_Controlword_1                                  = "1100.3"    ;
    public const string C3Plus_DeviceState_Statusword_1                                     = "1000.3"    ;
    public const string C3Plus_DeviceState_Statusword_2                                     = "1000.4"    ;
    public const string C3Plus_Diagnostics_ChopperOff_Voltage                               = "85.8"      ;
    public const string C3Plus_Diagnostics_ChopperOn_Voltage                                = "85.7"      ;
    public const string C3Plus_Diagnostics_DCbus_Current                                    = "85.3"      ;
    public const string C3Plus_Diagnostics_DCbus_Voltage                                    = "85.2"      ;
    public const string C3Plus_Diagnostics_DCbus_VoltageMax                                 = "85.9"      ;
    public const string C3Plus_Diagnostics_RectifierLoad                                    = "85.5"      ;
    public const string C3Plus_Diagnostics_TemperatureHeatSink                              = "85.4"      ;
    public const string C3Plus_ErrorHistory_LastError                                       = "550.1"     ;
    public const string C3Plus_ExternalSignal_Accel_Munits                                  = "2020.7"    ;
    public const string C3Plus_ExternalSignal_Speed_Munits                                  = "2020.6"    ;
    public const string C3Plus_HEDA_SignalProcessing_OutputGreat                            = "3920.7"    ;
    public const string C3Plus_HOMING_edge_position                                         = "1130.13"   ;
    public const string C3Plus_LoadControl_Command                                          = "2201.2"    ;
    public const string C3Plus_LoadControl_Enable                                           = "2201.1"    ;
    public const string C3Plus_LoadControl_FilterLaggingPart                                = "2201.11"   ;
    public const string C3Plus_LoadControl_Status                                           = "2201.3"    ;
    public const string C3Plus_LoadControl_VelocityFilter                                   = "2201.12"   ;
    public const string C3Plus_LoadControl_VelocityLimit                                    = "2201.13"   ;
    public const string C3Plus_NotchFilter_BandwidthFilter1                                 = "2150.2"    ;
    public const string C3Plus_NotchFilter_BandwidthFilter2                                 = "2150.5"    ;
    public const string C3Plus_NotchFilter_DepthFilter1                                     = "2150.3"    ;
    public const string C3Plus_NotchFilter_DepthFilter2                                     = "2150.6"    ;
    public const string C3Plus_NotchFilter_FrequencyFilter1                                 = "2150.1"    ;
    public const string C3Plus_NotchFilter_FrequencyFilter2                                 = "2150.4"    ;
    public const string C3Plus_PG2RegMove_ParametersModified                                = "1252.20"   ;
    public const string C3Plus_POSITION_accel                                               = "1111.3"    ;
    public const string C3Plus_POSITION_decel                                               = "1111.4"    ;
    public const string C3Plus_POSITION_jerk_accel                                          = "1111.5"    ;
    public const string C3Plus_POSITION_jerk_decel                                          = "1111.6"    ;
    public const string C3Plus_POSITION_position                                            = "1111.1"    ;
    public const string C3Plus_POSITION_speed                                               = "1111.2"    ;
    public const string C3Plus_PositionController_DeadBand                                  = "2200.20"   ;
    public const string C3Plus_PositionController_FrictionCompensation                      = "2200.21"   ;
    public const string C3Plus_PositionController_IntegralPart                              = "2200.25"   ;
    public const string C3Plus_PositionController_TrackingErrorFilter                       = "2200.11"   ;
    public const string C3Plus_PositionController_TrackingErrorFilter_us                    = "2200.24"   ;
    public const string C3Plus_TouchProbe_IgnoreZone_End                                    = "3300.9"    ;
    public const string C3Plus_TouchProbe_IgnoreZone_Start                                  = "3300.8"    ;
    public const string C3Plus_TrackingfilterHEDA_TRFSpeed                                  = "2109.1"    ;
    public const string C3Plus_RegMove_ParametersModified                                   = "1152.20"   ;
    public const string C3Plus_StatusCurrent_FieldWeakeningFactor                           = "688.17"    ;
    public const string C3Plus_StatusTorqueForce_ActualForce                                = "670.4"     ;
    public const string C3Plus_StatusTorqueForce_ActualTorque                               = "670.2"     ;
    public const string C3Plus_Switch_DeviceFunction                                        = "110.1"     ;
    public const string C3Plus_TrackingfilterPhysicalSource_TRFSpeed                        = "2107.1"    ;
    public const string C3Plus_TrackingfilterSG1_AccelFilter                                = "2110.4"    ;
    public const string C3Plus_TrackingfilterSG1_AccelFilter_us                             = "2110.7"    ;
    public const string C3Plus_TrackingfilterSG1_FilterSpeed                                = "2110.3"    ;
    public const string C3Plus_TrackingfilterSG1_FilterSpeed_us                             = "2110.6"    ;
    public const string C3Plus_TrackingfilterSG1_TRFSpeed                                   = "2110.1"    ;

    /* Control word bit constants (CWB) */
    public const int CWB_QUIT            = 0x0001;
    public const int CWB_NO_STOP1        = 0x0002;
    public const int CWB_JOG_PLUS        = 0x0004;
    public const int CWB_JOG_MINUS       = 0x0008;
    public const int CWB_O0_X12_2        = 0x0010;
    public const int CWB_O1_X12_3        = 0x0020;
    public const int CWB_O2_X12_4        = 0x0040;
    public const int CWB_03_X12_5        = 0x0080;
    public const int CWB_ADDRESS_0       = 0x0100;
    public const int CWB_ADDRESS_1       = 0x0200;
    public const int CWB_ADDRESS_2       = 0x0400;
    public const int CWB_ADDRESS_3       = 0x0800;
    public const int CWB_ADDRESS_4       = 0x1000;
    public const int CWB_START           = 0x2000;
    public const int CWB_NO_STOP2        = 0x4000;
    public const int CWB_OPEN_BRAKE      = 0x8000;

    /* Derivative control words (CW)*/
    public int CW_HOME          = CWB_QUIT | CWB_NO_STOP1 | CWB_NO_STOP2;
    public int CW_ACK_ZERO      = 0x0;
    public int CW_ACK_EDGE      = CWB_QUIT | CWB_NO_STOP1 | CWB_NO_STOP2;
    public int CW_JOG_PLUS      = CWB_QUIT | CWB_NO_STOP1 | CWB_JOG_PLUS | CWB_NO_STOP2;
    public int CW_JOG_MINUS     = CWB_QUIT | CWB_NO_STOP1 | CWB_JOG_MINUS | CWB_NO_STOP2;
    public int CW_START         = CWB_QUIT | CWB_NO_STOP1 | CWB_START | CWB_NO_STOP2;
    public int CW_STOP1         = CWB_QUIT | CWB_NO_STOP2;
    public int CW_JOG_STOP      = CWB_QUIT | CWB_NO_STOP1 | CWB_JOG_PLUS | CWB_JOG_MINUS;

    /* Status word 1 bit (SWB1) constants */
    public const int SWB1_I0             = 0x0001;
    public const int SWB1_I1             = 0x0002;
    public const int SWB1_I2             = 0x0004;
    public const int SWB1_I3             = 0x0008;
    public const int SWB1_I4             = 0x0010;
    public const int SWB1_I5             = 0x0020;
    public const int SWB1_I6             = 0x0040;
    public const int SWB1_I7             = 0x0080;
    public const int SWB1_NO_ERROR       = 0x0100;
    public const int SWB1_POS_REACHED    = 0x0200;
    public const int SWB1_NO_EXCITATION  = 0x0400;
    public const int SWB1_CURRENT_ZERO   = 0x0800;
    public const int SWB1_HOME_IS_KNOWN  = 0x1000;
    public const int SWB1_PSB0           = 0x2000;
    public const int SWB1_PSB1           = 0x4000;
    public const int SWB1_PSB2           = 0x8000;

    /* Movement modes */
    public const int MOVE_ABS = 1;
    public const int MOVE_REL = 2;

    /**
     * Property backing fields.
     */
    private Gee.Map<string, Object> _objects;

    private string received = "";
    private uint status1 = 0x0000;
    private uint flags = 0x0000;
    private bool data_received = false;
    private string active_command = null;
    private uint timeout_ms;
    private uint serial_timeout_ms = 2000;
    private uint home_timeout_ms = 10000;
    private uint move_timeout_ms = 5000;
    private int count = 0;
    private signal void serial_timeout ();
    private signal void home_found ();
    private double zero_position;
    private ulong zero_move_id;
    private double default_velocity = 0.0;
    private double default_acceleration = 0.0;
    private double default_deceleration = 0.0;
    private double default_jerk = 0.0;
    private bool write_success = false;

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; }

    /**
     * {@inheritDoc}
     */
    public override bool loaded { get; set; default = false; }

    /**
     * {@inheritdoc}
     */
    public override string devref { get; set; }

    /**
     * {@inheritDoc}
     */
    public override string portref { get; set; }

    /**
     * {@inheritDoc}
     */
    public override weak Port port { get; set; }

    /**
     * {@inheritDoc}
     */
    public override Gee.Map<string, Object> objects {
        get { return (_objects); }
        set { update_objects (value); }
    }

    /* A signal that is emitted when the position value changes.*/
    public signal void new_position (double position);

    /* The position that is tracked locally by the software */
    private double _position = 0.0;
    public double position {
        get { return _position; }
        private set {
            _position = value;
            new_position (value);
        }
    }

     /* A signal that is emitted when the position value changes.*/
    public signal void new_remote_position (double remote_position);

    /* The position that is read directly from the Compax3 */
    private double _remote_position = 0.0;
    public double remote_position {
        get { return _remote_position; }
        private set {
            _remote_position = value;
            new_remote_position (value);
        }
    }

    construct {
        home_found.connect (() => {
            position = 0.0;
        });
    }

    /**
     * Full construction using available settings.
     */
    public ParkerModule.full (string id, Port port) {
        this.id = id;
        this.port = port;
    }

    /**
     * Alternate construction that uses an XML node to populate the settings.
     */
    public ParkerModule.from_xml_node (Xml.Node *node) {
        string val;

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            /* iterate through node children */
            for (Xml.Node *iter = node->children;
                 iter != null;
                 iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "port":
                            portref = iter->get_content ();
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public override bool load () {
        loaded = true;

        if (!port.open ()) {
            Cld.debug ("Could not open port, id: %s\n", port.id);
            loaded = false;
        } else {
            (port as SerialPort).new_data.connect (new_data_cb);
            Cld.debug ("ParkerModule loaded\n");
        }
        loaded = (port.open ()) ? true : false;

        return loaded;
    }

    /**
     * {@inheritDoc}
     */
    public override void unload () {
        Cld.debug ("ParkerModule :: unload ()\n");
        port.close ();
        loaded = false;
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Object> val) {
        _objects = val;
    }

    /**
     * {@inheritDoc}
     */
    public override string to_string () {
        string r;
        r  = "ParkerModule [%s]\n".printf (id);
        return r;
    }

    public void jog_plus () {
        Cld.debug ("jog_plus ()\n");
        Cld.debug ("active_command: %s\n", active_command);
        if (active_command == null) {
            position += 1.0;
            /* Write out the control word and begin checking the status word */
            write_object (C3Plus_DeviceControl_Controlword_1, CW_JOG_PLUS);
            write_object (C3Plus_DeviceControl_Controlword_1, CW_JOG_PLUS | CWB_START);
            //status1 &= ~(SWB1_NO_ERROR); //Clear bit.
            Cld.debug ("jog_plus: position: %.3f status1: %u\n", _position, status1);
            //flags = SWB1_NO_ERROR;
            timeout_ms = move_timeout_ms;
            this.serial_timeout.connect (check_status_cb);
            check_status_cb ();
        }
    }

    public void jog_minus () {
        Cld.debug ("jog_minus ()\n");
        if (active_command == null) {
            position -= 1.0;
            /* Write out the control word and begin checking the status word */
            write_object (C3Plus_DeviceControl_Controlword_1, CW_JOG_MINUS);
            write_object (C3Plus_DeviceControl_Controlword_1, CW_JOG_MINUS | CWB_START);
            //status1 &= ~(SWB1_NO_ERROR); //Clear bit.
            Cld.debug ("jog_minus: position: %.3f status1: %u\n", _position, status1);
            //flags = SWB1_NO_ERROR;
            timeout_ms = move_timeout_ms;
            this.serial_timeout.connect (check_status_cb);
            check_status_cb ();
        }
    }

    public void jog_stop () {
        Cld.debug ("jog_stop\n");
        write_object (C3Plus_DeviceControl_Controlword_1, CW_JOG_STOP);
    }

    public void step (double step_size, int direction) {
        if (active_command == null) {
            position += (step_size * direction);
            Cld.debug ("step_size: %.3f direction: %d position %.3f\n", step_size, direction, position);
            /* Write movement to the set table */
            write_object (C3Array_Col01_Row01, step_size * direction);
            write_object (C3Array_Col02_Row01, default_velocity);
            write_object (C3Array_Col05_Row01, MOVE_REL);
            write_object (C3Array_Col06_Row01, default_acceleration);
            write_object (C3Array_Col07_Row01, default_deceleration);
            write_object (C3Array_Col08_Row01, default_jerk);
            /* Arm for Adress = 1 */
            write_object (C3Plus_DeviceControl_Controlword_1, CWB_QUIT | CWB_NO_STOP1 | CWB_NO_STOP2 | CWB_ADDRESS_0);
            /* Toggle the start bit */
            write_object (C3Plus_DeviceControl_Controlword_1, CWB_QUIT | CWB_NO_STOP1 | CWB_NO_STOP2 | CWB_ADDRESS_0 | CWB_START);
            /* Enable status word checking for position reached */
            status1 &= ~(SWB1_POS_REACHED); //Clear bit.
            flags = SWB1_POS_REACHED;
            active_command = C3Plus_DeviceState_Statusword_1;
            timeout_ms = move_timeout_ms;
            this.serial_timeout.connect (check_status_cb);
            check_status_cb ();
        }
    }

    private void new_data_cb (SerialPort port, uchar[] data, int size) {
//        Cld.debug ("new_data_cb (): (%s) %d\n", data, size);
//        if (active_command == "write_object") {
//            port.flush ();
//            return;
//        } else {
            for (int i = 0; i < size; i++) {
                unichar c = "%c".printf (data[i]).get_char ();
                Cld.debug ("c: %d\n", (int)c);
                string s = "%c".printf (data[i]);

                /* Ignore LF if last char was CR (CRLF terminator) */
                if (!(port.last_rx_was_cr && (c == '\n'))) {
                    received += "%s".printf (s);
                }

                port.last_rx_was_cr = (c == '\r');

                if (c == '\r') {
                    string r = "";
                    received = received.chug ();
                    received = received.chomp ();
                    string[] tokens = received.split ("\t");
                    foreach (string token in tokens[0:tokens.length]) {
                        r += "%s\t".printf (token);
                    }
                    r = r.substring (0, r.length - 1);
                    Cld.debug ("%s   \n", r);
                    parse_response (r);
                }
            }
//        }
    }

    public void home () {
        if (active_command == null) {
            status1 &= ~(SWB1_HOME_IS_KNOWN); //Clear bit.
            Cld.debug ("home () CW_HOME: %d status1: %u\n", CW_HOME, status1);
            /* Write out the control word and begin checking the status word */
            write_object.begin (C3Plus_DeviceControl_Controlword_1, CW_HOME, (obj, res) => {
                // wait for response
                try {
                    bool result = write_object.end (res);
                    Cld.debug ("write result: %s\n", result.to_string ());
                } catch (ThreadError e) {
                    GLib.stderr.printf ("Thread error: %s\n", e.message);
                }
            });

//            write_object.begin (C3Plus_DeviceControl_Controlword_1, CW_HOME | CWB_START, (obj, res) => {
//                // wait for response
//                try {
//                    bool result = write_object.end (res);
//                    Cld.debug ("write result: %s\n", result.to_string ());
//                } catch (ThreadError e) {
//                    GLib.stderr.printf ("Thread error: %s\n", e.message);
//                }
//            });
            Cld.debug (".. continue\n");
            timeout_ms = home_timeout_ms;
            flags = SWB1_HOME_IS_KNOWN;
            this.serial_timeout.connect (check_status_cb);
            check_status_cb ();
        }
    }

    public void zero_record () {
        Cld.debug ("zero_record ()\n");
        if ((status1 & SWB1_HOME_IS_KNOWN) == SWB1_HOME_IS_KNOWN) {
            zero_position = _position;
            Cld.debug ("zero_position: %.3f", zero_position);
            position = 0.000;
        } else {
            Cld.debug ("Home is not known. Zero command ignored.\n");
        }
    }

    public void home_and_zero () {
        zero_move_id = home_found.connect (zero_move_cb);
        home ();
    }


    public void zero_move_cb () {
        Cld.debug ("Disconnecting home_found signal from zero_move callback\n");
        this.home_found.disconnect (zero_move_cb);
        if (active_command == null) {
            Cld.debug ("zero_move_cb () distance: %.3f\n", zero_position);
            /* Write movement to the set table */
            write_object (C3Array_Col01_Row01, zero_position);
            write_object (C3Array_Col02_Row01, default_velocity);
            write_object (C3Array_Col05_Row01, MOVE_ABS);
            write_object (C3Array_Col06_Row01, default_acceleration);
            write_object (C3Array_Col07_Row01, default_deceleration);
            write_object (C3Array_Col08_Row01, default_jerk);
            /* Arm for Adress = 1 */
            write_object (C3Plus_DeviceControl_Controlword_1, CWB_QUIT | CWB_NO_STOP1 | CWB_NO_STOP2 | CWB_ADDRESS_0);
            /* Toggle the start bit */
            write_object (C3Plus_DeviceControl_Controlword_1, CWB_QUIT | CWB_NO_STOP1 | CWB_NO_STOP2 | CWB_ADDRESS_0 | CWB_START);
            /* Enable status word checking for position reached */
            status1 &= ~(SWB1_POS_REACHED); //Clear bit.
            flags = SWB1_POS_REACHED;
            active_command = C3Plus_DeviceState_Statusword_1;
            timeout_ms = move_timeout_ms;
            this.serial_timeout.connect (check_status_cb);
            check_status_cb ();
        }
    }


    public void withdraw (double length_mm, double speed_mmps) {
        if (active_command == null) {
            position = length_mm;
            Cld.debug ("withdraw (): length: %.3f speed: %.3f\n", length_mm);
            /* Write movement to the set table */
            write_object (C3Array_Col01_Row01, zero_position - length_mm);
            write_object (C3Array_Col02_Row01, speed_mmps);
            write_object (C3Array_Col05_Row01, MOVE_ABS);
            write_object (C3Array_Col06_Row01, default_acceleration);
            write_object (C3Array_Col07_Row01, default_deceleration);
            write_object (C3Array_Col08_Row01, default_jerk);
            /* Arm for Adress = 1 */
            write_object (C3Plus_DeviceControl_Controlword_1, CWB_QUIT | CWB_NO_STOP1 | CWB_NO_STOP2 | CWB_ADDRESS_0);
            /* Toggle the start bit */
            write_object (C3Plus_DeviceControl_Controlword_1, CWB_QUIT | CWB_NO_STOP1 | CWB_NO_STOP2 | CWB_ADDRESS_0 | CWB_START);
            /* Enable status word checking for position reached */
            status1 &= ~(SWB1_POS_REACHED); //Clear bit.
            flags = SWB1_POS_REACHED;
            timeout_ms = move_timeout_ms;
            this.serial_timeout.connect (check_status_cb);
            check_status_cb ();
        }
    }

    public void inject (double speed_mmps) {
        if (active_command == null) {
            position = 0.0;
            Cld.debug ("inject (): speed: %.3f\n", speed_mmps);
            /* Write movement to the set table */
            write_object (C3Array_Col01_Row01, zero_position);
            write_object (C3Array_Col02_Row01, default_velocity);
            write_object (C3Array_Col05_Row01, MOVE_ABS);
            write_object (C3Array_Col06_Row01, default_acceleration);
            write_object (C3Array_Col07_Row01, default_deceleration);
            write_object (C3Array_Col08_Row01, default_jerk);
            /* Arm for Adress = 1 */
            write_object (C3Plus_DeviceControl_Controlword_1, CWB_QUIT | CWB_NO_STOP1 | CWB_NO_STOP2 | CWB_ADDRESS_0);
            /* Toggle the start bit */
            write_object (C3Plus_DeviceControl_Controlword_1, CWB_QUIT | CWB_NO_STOP1 | CWB_NO_STOP2 | CWB_ADDRESS_0 | CWB_START);
            /* Enable status word checking for position reached */
            status1 &= ~(SWB1_POS_REACHED); //Clear bit.
            flags = SWB1_POS_REACHED;
            timeout_ms = move_timeout_ms;
            this.serial_timeout.connect (check_status_cb);
            check_status_cb ();
        }
    }

    public void fetch_remote_position () {
        if (active_command == null) {
            active_command = C3_StatusPosition_Actual;
            read_object (active_command);
        }
    }

    public void parse_response (string response) {
        Cld.debug ("parse_response ():: response: %s active_command: %s\n", response, active_command);
        switch (active_command) {
            case "write_object":
                if (response == ">") {
                    active_command = null;
                    write_success = true;
                }
                break;
            case C3Plus_DeviceState_Statusword_1:
                status1 = int.parse (response);
                Cld.debug ("%s %s response: string value = %s numerical value = %d\n",
                            "C3Plus_DeviceState_Statusword_1",
                            active_command, response, status1);

                if ((status1 & SWB1_HOME_IS_KNOWN) == SWB1_HOME_IS_KNOWN) {
                    Cld.debug ("home found\n");
                    home_found ();
                } else if ((status1 & SWB1_HOME_IS_KNOWN) == 0) {
                    Cld.debug ("home not found\n");
                }
                if ((status1 & SWB1_POS_REACHED) == SWB1_POS_REACHED) {
                    Cld.debug ("position reached\n");
                } else {
                    Cld.debug ("position not reached\n");
                }
//                if (!((status1 & SWB1_NO_ERROR) == SWB1_NO_ERROR)) {
//                    Cld.debug ("No Error\n");
//                }
                break;
            case C3_StatusPosition_Actual:
                remote_position = double.parse (response);
                Cld.debug ("remote_position: %.3f\n", _remote_position);
                break;
//            case C3Plus_ErrorHistory_LastError:
//                Cld.debug ("Error: %s\n", response);
//                write_object (C3Plus_DeviceControl_Controlword_1, CW_ACK_ZERO);
//                write_object (C3Plus_DeviceControl_Controlword_1, CW_ACK_EDGE);
//                break;
            default:
                Cld.debug ("Unable to parse response: %s\n", response);
                break;
        }

        data_received = true;
        received = "";
    }
    /**
     * Build a command from argument list and write it to the serial port.
     * XXX This could be made to take an index, sublindex and a variable list of values
     * using a valriable argument list method but it is here in a simpler form for now.
     */
    private async bool write_object (string index, double val) throws ThreadError {
        Cld.debug ("...inside write: %s\n", index);
        SourceFunc callback = write_object.callback;
        bool ret = false;
        write_success = false;
        active_command = "write_object";
        string msg1 = "o" + index + "=" + val.to_string () +"\r\n";
        port.send_bytes (msg1.to_utf8 (), msg1.length);

        ThreadFunc<void *> run = () => {
            Cld.debug ("...inside write thread run\n");
            /* Run timer */
            for (var i = 0; i < 5; i++) {
                Thread.usleep (1000000*i);
                Cld.debug ("...write %ds delay\n", i);
                if (i == 4) {
                    Cld.debug ("write thread timed out.\n");
                }
                if (write_success)
                    break;
            }
            ret = true;
            Idle.add ((owned) callback);
            return null;
        };
        Thread.create<void *>(run, false);

        Cld.debug ("...yielding to write thread\n");
        yield;
        Cld.debug ("...done write\n");
        return ret;

    }

    public void read_object (string index) {
        data_received = false;
        string msg1 = "o" + index + "\r\n";
        port.send_bytes (msg1.to_utf8 (), msg1.length);
        uint source_id_serial = Timeout.add (serial_timeout_ms, serial_timeout_cb);
    }

    private bool serial_timeout_cb () {
        if (!data_received) {
            Cld.debug ("Serial port %s timeout\n", port.id);
        }
        serial_timeout ();

        return false;
    }

    private void check_status_cb () {
        if (active_command == null) {
            active_command = C3Plus_DeviceState_Statusword_1;
            if (!((status1 & flags) == flags)
                        && (count < timeout_ms / serial_timeout_ms)) {
                read_object (active_command);
                count++;
                Cld.debug ("count: %d active command: %s\n", count, active_command);

            } else if ((status1 & flags) == flags) {
                Cld.debug ("Check status: STATUS FLAG EVENT  status1: %u flags: %u\n", status1, flags);
                active_command = null;
                this.serial_timeout.disconnect (check_status_cb);
                count = 0;
            } else {
                count = 0;
                Cld.debug ("Check status callback timed out\n");
                active_command = null;
                this.serial_timeout.disconnect (check_status_cb);
            }
    //        if (!((status1 & SWB1_NO_ERROR) == SWB1_NO_ERROR)) {
    //            Cld.debug ("Error!\n");
    //            count = 0;
    //            this.serial_timeout.disconnect (check_status_cb);
    //            active_command = C3Plus_ErrorHistory_LastError;
    //            read_object (active_command);
    //        }
        }
    }
}
