/**
 * libcld
 * Copyright (c) 2015, Geoff Johnson, All rights reserved.
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

using Posix;

/**
 * This is very much intended to service an immediate specific need and will not
 * be suitable for a generic scenario.
 */
public class Cld.ParkerModule : AbstractModule {

    /* Parker Comapx3 I12 T11 Objects */
    public const string C3_Flash_Write                                                      = "20.11"     ;
    public const string C3_Flash_ReadWrite                                                  = "20.1"      ;
    public const string C3_AnalogInput0_Gain                                                = "170.2"     ;
    public const string C3_AnalogInput0_Offset                                              = "170.4"     ;
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
    public const string C3Array_Col01_Row02                                                 = "1901.2"    ;
    public const string C3Array_Col02_Row02                                                 = "1902.2"    ;
    public const string C3Array_Col03_Row02                                                 = "1903.2"    ;
    public const string C3Array_Col04_Row02                                                 = "1904.2"    ;
    public const string C3Array_Col05_Row02                                                 = "1905.2"    ;
    public const string C3Array_Col06_Row02                                                 = "1906.2"    ;
    public const string C3Array_Col07_Row02                                                 = "1907.2"    ;
    public const string C3Array_Col08_Row02                                                 = "1908.2"    ;
    public const string C3Array_Col09_Row02                                                 = "1909.2"    ;
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

    /* Agreagated bit control words (CW)*/
    public int CW_HOME          = CWB_QUIT | CWB_NO_STOP1 | CWB_NO_STOP2;
    public int CW_ACK_ZERO      = 0x0;
    public int CW_ACK_EDGE      = CWB_QUIT | CWB_NO_STOP1 | CWB_NO_STOP2;
    public int CW_START         = CWB_QUIT | CWB_NO_STOP1 | CWB_START | CWB_NO_STOP2;
    public int CW_STOP1         = CWB_QUIT | CWB_NO_STOP2;

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
     * Used to link virtual channels to variale values.
     */
    public enum VariableName {
        NONE,
        POSITION,
        ACTUAL_POSITION,
        ACTUAL_TORQUE,
        REQUESTED_POSITION;

        public static VariableName parse (string value) {
            try {
                if (value == "position") {
                    return POSITION;
                } else if (value == "actual_position") {
                    return ACTUAL_POSITION;
                } else if (value == "actual_torque") {
                    return ACTUAL_TORQUE;
                } else if (value == "requested_position") {
                    return REQUESTED_POSITION;
                }
            } catch (RegexError e) {
                message ("Error %s", e.message);
            }

            /* XXX need to return something */
            return NONE;
        }

    }

    /**
     * Parker Comapx3 I12 T11 Objects
     */
    public enum C3 {
        NONE,
        FLASH_WRITE,
        FLASH_READWRITE,
        ANALOGINPUT0_GAIN,
        ANALOGINPUT0_OFFSET,
        ANALOGINPUT1_GAIN,
        ANALOGINPUT1_OFFSET,
        D_CURRENTCONTROLLER_LD_LQ_RATIO,
        CONTROLLERTUNING_ACTUATINGSPEEDSIGNALFILT_US,
        CONTROLLERTUNING_CURRENTBANDWIDTH,
        CONTROLLERTUNING_CURRENTDAMPING,
        CONTROLLERTUNING_FILTERACCEL_US,
        CONTROLLERTUNING_FILTERACCEL2,
        CONTROLLERTUNING_FILTERSPEED2,
        D_CURRENTCONTROLLER_VOLTAGEDECOUPLINGENABLE,
        DELAY_MASTERDELAY,
        DEVICESUPERVISION_DEVICEADR,
        DEVICESUPERVISION_DEVICECOUNTER,
        DEVICESUPERVISION_OPERATINGTIME,
        DEVICESUPERVISION_THISDEVICE,
        DIAGNOSTICS_DEVICESTATE,
        DIGITALINPUT_DEBOUNCEDVALUE,
        DIGITALINPUT_VALUE,
        DIGITALINPUTADDITION_VALUE,
        DIGITALOUTPUTADDITION_VALUE,
        ERRORHISTORY_1,
        ERRORHISTORYNUMBER_1,
        ERRORHISTORYPOINTER_LASTENTRY,
        ERRORHISTORYTIME_1,
        EXTERNALSIGNAL_POSITION,
        FEEDFORWARD_EMF,
        FEEDFORWARDEXTERNAL_FILTERACCEL,
        FEEDFORWARDEXTERNAL_FILTERACCEL_US,
        FEEDFORWARDEXTERNAL_FILTERSPEED,
        FEEDFORWARDEXTERNAL_FILTERSPEED_US,
        MAGNETIZATION_CURRENT_CONTROLLER_BANDWIDTH,
        MAGNETIZATION_CURRENT_CONTROLLER_DAMPING,
        MAGNETIZATION_CURRENT_CONTROLLER_FIELD,
        MAGNETIZATION_CURRENT_CONTROLLER_IMRN_DEMANDVALUETUNING,
        MAGNETIZATION_CURRENT_CONTROLLER_ROTORTIMECONSTANT,
        MAGNETIZATION,
        Q_CURRENTCONTROLLER_BACKEMF,
        Q_CURRENTCONTROLLER_INDUCTANCE,
        Q_CURRENTCONTROLLER_RESISTANCE,
        Q_CURRENTCONTROLLER_STRUCTURESELECTION,
        STATUSCURRENT_PHASEU,
        STATUSCURRENT_PHASEV,
        STATUSCURRENT_REFERENCE,
        STATUSCURRENT_REFERENCEDINT,
        STATUSSPEED_ERROR,
        STATUSSPEED_FEEDFORWARDSPEED,
        STATUSSPEED_LOADCONTROLFILTERED,
        SPEEDCONTROLLER_ACTUALBANDWIDTH,
        SPEEDCONTROLLER_I_PART_GAIN,
        SPEEDCONTROLLER_P_PART_GAIN,
        SPEEDOBSERVER_DISTURBANCEADDITIONENABLE,
        SPEEDOBSERVER_DISTURBANCEFILTER,
        SPEEDOBSERVER_TIMECONSTANT,
        STATUSACCEL_ACTUAL,
        STATUSACCEL_ACTUALFILTER,
        STATUSACCEL_DEMANDVALUE,
        STATUSACCEL_FEEDFORWARDACCEL,
        STATUSAUTOCOMMUTATION_ITTERATIONS,
        STATUSCURRENT_ACTUAL,
        STATUSCURRENT_ACTUALDINT,
        STATUSCURRENT_CONTROLDEVIATIONIQ,
        STATUSCURRENT_DECOUPLINGVOLTAGEUD,
        STATUSCURRENT_FEEDFORWARDBACKEMF,
        STATUSCURRENT_FEEDFORWORDCURRENTJERK,
        STATUSCURRENT_REFERENCEJERK,
        STATUSCURRENT_REFERENCEVOLTAGEUQ,
        STATUSCURRENT_REFERENCEVOLTAGEVECTOR,
        STATUSCURRENT_VOLTAGEUD,
        STATUSCURRENT_VOLTAGEUQ,
        STATUSDEVICE_ACTUALDEVICELOAD,
        STATUSDEVICE_ACTUALMOTORLOAD,
        STATUSDEVICE_OBSERVEDDISTURBANCE,
        STATUSFEEDBACK_ENCODERCOSINE,
        STATUSFEEDBACK_ENCODERSINE,
        STATUSFEEDBACK_FEEDBACKCOSINEDSP,
        STATUSFEEDBACK_FEEDBACKSINEDSP,
        STATUSFEEDBACK_FEEDBACKVOLTAGE_VPP,
        STATUSPOSITION_ACTUAL,
        STATUSPOSITION_ACTUALCONTROLLER,
        STATUSPOSITION_DEMANDCONTROLLER,
        STATUSPOSITION_DEMANDVALUE,
        STATUSPOSITION_FOLLOWINGERROR,
        STATUSPOSITION_LOADCONTROLACTUAL,
        STATUSPOSITION_LOADCONTROLDEVIATION,
        STATUSPOSITION_LOADCONTROLDEVIATIONFILTERED,
        STATUSSPEED_ACTUAL,
        STATUSSPEED_ACTUALFILTERED,
        STATUSSPEED_ACTUALSCALED,
        STATUSSPEED_DEMANDSCALED,
        STATUSSPEED_DEMANDSPEEDCONTROLLER,
        STATUSSPEED_DEMANDVALUE,
        STATUSSPEED_NEGATIVELIMIT,
        STATUSSPEED_POSITIVELIMIT,
        STATUSTEMPERATURE_MOTOR,
        STATUSTEMPERATURE_POWERSTAGE,
        STATUSVOLTAGE_ANALOGINPUT0,
        STATUSVOLTAGE_ANALOGINPUT1,
        STATUSVOLTAGE_AUXILIARYVOLTAGE,
        STATUSVOLTAGE_BUSVOLTAGE;

        public string to_string () {
             switch (this) {
                case STATUSPOSITION_ACTUAL:  return "680.5";
                default: assert_not_reached ();
            }
        }

        public static C3 parse (string value) {
            try {
                var regex_status_position_actual  = new Regex ("C3_StatusPosition_Actual", RegexCompileFlags.CASELESS);
                if (regex_status_position_actual.match (value)) {
                    return STATUSPOSITION_ACTUAL; // etc..
                }            } catch (RegexError e) {
                message ("Error %s", e.message);
            }

            /* XXX need to return something */
            return NONE;
        }
    }

    /**
     * Parker Comapx3 I12 T11 Move Tables
     */
    public enum C3Array {
        COL01_ROW01,
        COL02_ROW01,
        COL03_ROW01,
        COL04_ROW01,
        COL05_ROW01,
        COL06_ROW01,
        COL07_ROW01,
        COL08_ROW01,
        COL09_ROW01,
        COL01_ROW02,
        COL02_ROW02,
        COL03_ROW02,
        COL04_ROW02,
        COL05_ROW02,
        COL06_ROW02,
        COL07_ROW02,
        COL08_ROW02,
        COL09_ROW02,
        INDIRECT_COL01,
        Pointer_Row
    }

    /**
     * Parker Comapx3 I12 T11 Objects
     */
    public enum C3Plus {
        NONE,
        ANALOGINPUT0_FILTERCOEFFICIENT,
        ANALOGINPUT1_FILTERCOEFFICIENT,
        AUTOCOMMUTATIONCONTROL_INITIALCURRENT,
        AUTOCOMMUTATIONCONTROL_MOTIONREDUCTION,
        AUTOCOMMUTATIONCONTROL_PEAKCURRENT,
        AUTOCOMMUTATIONCONTROL_POSITIONTHRESHOLD,
        AUTOCOMMUTATIONCONTROL_RAMPTIME,
        AUTOCOMMUTATIONCONTROL_RESET,
        AUTOCOMMUTATIONCONTROL_STANDSTILLTHRESHOLD,
        DEVICECONTROL_CONTROLWORD_1,
        DEVICESTATE_STATUSWORD_1,
        DEVICESTATE_STATUSWORD_2,
        DIAGNOSTICS_CHOPPEROFF_VOLTAGE,
        DIAGNOSTICS_CHOPPERON_VOLTAGE,
        DIAGNOSTICS_DCBUS_CURRENT,
        DIAGNOSTICS_DCBUS_VOLTAGE,
        DIAGNOSTICS_DCBUS_VOLTAGEMAX,
        DIAGNOSTICS_RECTIFIERLOAD,
        DIAGNOSTICS_TEMPERATUREHEATSINK,
        ERRORHISTORY_LASTERROR,
        EXTERNALSIGNAL_ACCEL_MUNITS,
        EXTERNALSIGNAL_SPEED_MUNITS,
        HEDA_SIGNALPROCESSING_OUTPUTGREAT,
        HOMING_EDGE_POSITION,
        LOADCONTROL_COMMAND,
        LOADCONTROL_ENABLE,
        LOADCONTROL_FILTERLAGGINGPART,
        LOADCONTROL_STATUS,
        LOADCONTROL_VELOCITYFILTER,
        LOADCONTROL_VELOCITYLIMIT,
        NOTCHFILTER_BANDWIDTHFILTER1,
        NOTCHFILTER_BANDWIDTHFILTER2,
        NOTCHFILTER_DEPTHFILTER1,
        NOTCHFILTER_DEPTHFILTER2,
        NOTCHFILTER_FREQUENCYFILTER1,
        NOTCHFILTER_FREQUENCYFILTER2,
        PG2REGMOVE_PARAMETERSMODIFIED,
        POSITION_ACCEL,
        POSITION_DECEL,
        POSITION_JERK_ACCEL,
        POSITION_JERK_DECEL,
        POSITION_POSITION,
        POSITION_SPEED,
        POSITIONCONTROLLER_DEADBAND,
        POSITIONCONTROLLER_FRICTIONCOMPENSATION,
        POSITIONCONTROLLER_INTEGRALPART,
        POSITIONCONTROLLER_TRACKINGERRORFILTER,
        POSITIONCONTROLLER_TRACKINGERRORFILTER_US,
        TOUCHPROBE_IGNOREZONE_END,
        TOUCHPROBE_IGNOREZONE_START,
        TRACKINGFILTERHEDA_TRFSPEED,
        REGMOVE_PARAMETERSMODIFIED,
        STATUSCURRENT_FIELDWEAKENINGFACTOR,
        STATUSTORQUEFORCE_ACTUALFORCE,
        STATUSTORQUEFORCE_ACTUALTORQUE,
        SWITCH_DEVICEFUNCTION,
        TRACKINGFILTERPHYSICALSOURCE_TRFSPEED,
        TRACKINGFILTERSG1_ACCELFILTER,
        TRACKINGFILTERSG1_ACCELFILTER_US,
        TRACKINGFILTERSG1_FILTERSPEED,
        TRACKINGFILTERSG1_FILTERSPEED_US,
        TRACKINGFILTERSG1_TRFSPEED;

        public static C3Plus parse (string value) {
            try {
                var regex_status_torque_force_actual_torque  = new Regex
                    (
                    "C3Plus_StatusTorqueForce_ActualTorque",
                    RegexCompileFlags.CASELESS
                    );
                if (regex_status_torque_force_actual_torque.match (value)) {
                    return STATUSTORQUEFORCE_ACTUALTORQUE; // etc..
                }            } catch (RegexError e) {
                message ("Error %s", e.message);
            }

            /* XXX need to return something */
            return NONE;
        }
    }

    private string received = "";
    private uint status1 = 0x0000;
    private uint flags = 0x0000;
    private bool data_received = false;
    private string active_command = null;
    private uint timeout_ms;
    private uint serial_timeout_ms = 10;
    private uint home_timeout_ms = 80000;
    private uint jog_timeout_ms = 1000;
    private uint move_timeout_ms = 80000;
    private signal void serial_timeout ();
    private double zero_position = 0.0;
    private double default_velocity = 10.0;
    private double default_acceleration = 30000.0;
    private double default_deceleration = 30000.0;
    private double default_jerk = 200000.0;
    private bool write_success = false;
    private int count = 0;
    private bool use_brake = true; //True if brake is enabled after each move

    public signal void error (int n, string message);

    /* A signal that is emitted when the position value changes.*/
    public signal void new_position (double position);

    /* The position relative to the recorded zero postion */
    private double _position = 0.0;
    public double position {
        get { return _position; }
        private set {
            _position = value;
            new_position (value);
        }
    }

     /* A signal that is emitted when the position value is updated.*/
    public signal void new_actual_position (double actual_position);

    /* The position that is read directly from the Compax3 */
    private double _actual_position;
    public double actual_position {
        get { return _actual_position; }
        private set {
            _actual_position = value;
            new_actual_position (value);
        }
    }

    /* A signal that is emitted when a new relative position is requested */
    public signal void new_requested_position (double requested_position);

    /* The requested position of a relative move. */
    private double _requested_position;
    public double requested_position {
        get { return _requested_position; }
        private set {
            _requested_position = value;
            new_requested_position (value);
        }
    }

    /* A signal that is emitted whe the torque value changes. */
    public signal void new_actual_torque (double actual_torque);

    /* The torque that is read directly from the Compax3 */
    private double _actual_torque = 0.0;
    public double actual_torque {
        get { return _actual_torque; }
        private set {
            _actual_torque = value;
            new_actual_torque (value);
        }
    }

    /**
     * Map of virtual channels.
     */
    public Gee.Map<string, Cld.Object> channels { get; set; }

    /**
     * True if the drive has a brake.
     */
    public bool has_brake { get; set; }

    /**
     * A flag to indicate that the drive should stop.
     */
    public bool quit { get; set; default = false; }

    public ParkerModule.full (string id, Port port) {
       this.id = id;
       this.port = port;
       this.channels = channels;
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
                        case "devref":
                            devref = iter->get_content ();
                            break;
                        case "has-brake":
                            has_brake = bool.parse (iter->get_content ());
                            break;
                        default:
                            break;
                    }
                }
            }
        }
        channels = new Gee.TreeMap<string, Cld.Object> ();
    }

    /**
     * Add virtual channels an connect to signalled values.
     */
    public void add_channel (Cld.Object channel) {
        channels.set (channel.id, channel);
        VariableName vn = VariableName.parse ((channel as Channel).desc);
        switch (vn) {
            case VariableName.POSITION:
                new_position.connect ((position) => {
                    (channel as VChannel).raw_value = position;
                });
                break;
            case VariableName.ACTUAL_POSITION:
                new_actual_position.connect ((actual_position) => {
                    (channel as VChannel).raw_value = actual_position;
                });
                break;
            case VariableName.ACTUAL_TORQUE:
                new_actual_torque.connect ((actual_torque) => {
                    (channel as VChannel).raw_value = actual_torque;
                });
                break;
            case VariableName.REQUESTED_POSITION:
                new_requested_position.connect ((position_requsted) => {
                    (channel as VChannel).raw_value = requested_position;
                });
                break;
            default:
                break;
        }
    }

    /**
     * {@inheritDoc}
     */
    public override bool load () {
        loaded = true;

        if (!port.open ()) {
            message ("Could not open port, id: %s", port.id);
            loaded = false;
        } else {
            (port as SerialPort).new_data.connect (new_data_cb);
            message ("ParkerModule loaded");
        }
        restore_flash.begin ();
        loaded = (port.open ()) ? true : false;

        return loaded;
    }

    /* This method restores the settings that were saved in the flash memory */
    private async void restore_flash () {
        yield write_object (C3_Flash_ReadWrite, 1);
        active_command = C3Array_Col01_Row01; //ie. the zero_position
        yield read_object (C3Array_Col01_Row01);
        yield fetch_actual_position ();
    }

    /**
     * {@inheritDoc}
     */
    public override void unload () {
        message ("ParkerModule :: unload ()");
        port.close ();
        loaded = false;
    }

    /*
     * Deactivate the drive.
     */
    public async void deactivate () {
        yield write_object (C3Plus_DeviceControl_Controlword_1, 0);
    }

    public async void jog_plus () {
        message ("jog_plus ()");
        if (active_command == null) {
            yield write_object (
                               C3Plus_DeviceControl_Controlword_1,
                               CWB_QUIT
                               );
            yield write_object (
                               C3Plus_DeviceControl_Controlword_1,
                               CWB_NO_STOP1 |
                               CWB_JOG_PLUS |
                               CWB_NO_STOP2 |
                               CWB_QUIT |
                               CWB_OPEN_BRAKE
                               );
        }
    }

    public async void jog_minus () {
        message ("jog_minus");
        if (active_command == null) {
            yield write_object (
                               C3Plus_DeviceControl_Controlword_1,
                               CWB_QUIT
                               );
            yield write_object (
                               C3Plus_DeviceControl_Controlword_1,
                               CWB_NO_STOP1 |
                               CWB_JOG_MINUS |
                               CWB_NO_STOP2 |
                               CWB_QUIT |
                               CWB_OPEN_BRAKE
                               );
            message ("jog_minus: position: %.3f status1: %u", _position, status1);
        }
    }

    public async void jog_stop () {
        message ("jog_stop");
        yield write_object (
                           C3Plus_DeviceControl_Controlword_1,
                           CWB_QUIT |
                           CWB_NO_STOP1 |
                           CWB_NO_STOP2
                           );
        if (has_brake && use_brake) {
            /* Close the brake */
            yield write_object (C3Plus_DeviceControl_Controlword_1, 0);
        }
        yield fetch_actual_position ();
        yield last_error ();
    }

    /**
     * This method is application specific.
     */
    [Deprecated (replacement="move_relative", since="0.2.7")]
    public async void step (double step_size, int direction) {
        if (active_command == null) {
            message ("step_size: %.3f direction: %d position %.3f", step_size, direction, position);
            /* Write movement to the set table */
            yield write_object (C3Array_Col01_Row02, step_size * direction);
            yield write_object (C3Array_Col02_Row02, default_velocity);
            yield write_object (C3Array_Col05_Row02, MOVE_REL);
            yield write_object (C3Array_Col06_Row02, default_acceleration);
            yield write_object (C3Array_Col07_Row02, default_deceleration);
            yield write_object (C3Array_Col08_Row02, default_jerk);
            /* Arm for Adress = 1 */
            yield write_object (C3Plus_DeviceControl_Controlword_1, CWB_QUIT |
                                CWB_NO_STOP1 | CWB_NO_STOP2 | CWB_ADDRESS_1);
            /* Toggle the start bit */
            yield write_object (
                               C3Plus_DeviceControl_Controlword_1,
                               CWB_QUIT |
                               CWB_NO_STOP1 |
                               CWB_NO_STOP2 |
                               CWB_ADDRESS_1 |
                               CWB_START
                               );
            yield write_object (
                               C3Plus_DeviceControl_Controlword_1,
                               CWB_QUIT |
                               CWB_NO_STOP1 |
                               CWB_NO_STOP2 |
                               CWB_ADDRESS_1
                               );
            /* Wait for timeout or position reached */
            yield check_status (move_timeout_ms, SWB1_POS_REACHED |
                                SWB1_NO_ERROR);
            if (has_brake && use_brake) {
                /* Close the brake */
                yield write_object (C3Plus_DeviceControl_Controlword_1, 0);
            }
            yield fetch_actual_position ();
            yield last_error ();
        }
    }

    /**
     * Make a relative move (MoveRel).
     */
    public async void move_relative (double distance,
                                     double speed,
                                     double acceleration,
                                     double deceleration,
                                     double jerk) {
        requested_position = position + distance;
        if (active_command == null) {
            message ("""
                MoveRel: distance: %.3f, speed: %.3f, accel.: %.3f decel.: %.3f jerk: %.3f
                """, distance, speed, acceleration, deceleration, jerk);
            /* Write movement to the set table */
            yield write_object (C3Array_Col01_Row02, distance);
            yield write_object (C3Array_Col02_Row02, speed);
            yield write_object (C3Array_Col05_Row02, MOVE_REL);
            yield write_object (C3Array_Col06_Row02, acceleration);
            yield write_object (C3Array_Col07_Row02, deceleration);
            yield write_object (C3Array_Col08_Row02, jerk);
            /* Arm for Adress = 1 */
            yield write_object (
                               C3Plus_DeviceControl_Controlword_1,
                               CWB_QUIT |
                               CWB_NO_STOP1 |
                               CWB_NO_STOP2 |
                               CWB_ADDRESS_1
                               );
            /* Toggle the start bit */
            yield write_object (
                               C3Plus_DeviceControl_Controlword_1,
                               CWB_QUIT |
                               CWB_NO_STOP1 |
                               CWB_NO_STOP2 |
                               CWB_ADDRESS_1 |
                               CWB_START |
                               CWB_OPEN_BRAKE
                               );
            yield write_object (
                               C3Plus_DeviceControl_Controlword_1,
                               CWB_QUIT |
                               CWB_NO_STOP1 |
                               CWB_NO_STOP2 |
                               CWB_ADDRESS_1 |
                               CWB_OPEN_BRAKE
                               );
            /* Wait for timeout or position reached */
            yield check_status (
                               move_timeout_ms,
                               SWB1_POS_REACHED |
                               SWB1_NO_ERROR
                               );
            if (has_brake && use_brake) {
                /* Close the brake */
                yield write_object (C3Plus_DeviceControl_Controlword_1, 0);
            }
            yield fetch_actual_position ();
            yield last_error ();
        }
    }

    /**
     * Make an absolute move (MoveAbs).
     */
    public async void move_absolute (double pos,
                                     double speed,
                                     double acceleration,
                                     double deceleration,
                                     double jerk) {
        requested_position = pos;
        if (active_command == null) {
            message ("""
                MoveAbs: position: %.3f, speed: %.3f, accel.: %.3f decel.: %.3f jerk: %.3f
                """, pos, speed, acceleration, deceleration, jerk);
            /* Write movement to the set table */
            yield write_object (C3Array_Col01_Row02, pos);
            yield write_object (C3Array_Col02_Row02, speed);
            yield write_object (C3Array_Col05_Row02, MOVE_ABS);
            yield write_object (C3Array_Col06_Row02, acceleration);
            yield write_object (C3Array_Col07_Row02, deceleration);
            yield write_object (C3Array_Col08_Row02, jerk);
            /* Arm for Adress = 1 */
            yield write_object (
                               C3Plus_DeviceControl_Controlword_1,
                               CWB_QUIT |
                               CWB_NO_STOP1 |
                               CWB_NO_STOP2 |
                               CWB_ADDRESS_1
                               );
            /* Toggle the start bit */
            yield write_object (
                               C3Plus_DeviceControl_Controlword_1,
                               CWB_QUIT |
                               CWB_NO_STOP1 |
                               CWB_NO_STOP2 |
                               CWB_ADDRESS_1 |
                               CWB_START |
                               CWB_OPEN_BRAKE
                               );
            yield write_object (
                               C3Plus_DeviceControl_Controlword_1,
                               CWB_QUIT |
                               CWB_NO_STOP1 |
                               CWB_NO_STOP2 |
                               CWB_ADDRESS_1 |
                               CWB_OPEN_BRAKE
                               );
            /* Wait for timeout or position reached */
            yield check_status (
                               move_timeout_ms,
                               SWB1_POS_REACHED |
                               SWB1_NO_ERROR
                               );
            if (has_brake && use_brake) {
                /* Close the brake */
                yield write_object (C3Plus_DeviceControl_Controlword_1, 0);
            }
            yield fetch_actual_position ();
            yield last_error ();
        }
    }

    private void new_data_cb (SerialPort port, uchar[] data, int size) {
        for (int i = 0; i < size; i++) {
            unichar c = "%c".printf (data[i]).get_char ();
//            message ("c: %d", (int)c);
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
                //message ("response: %s   ", r);
                parse_response (r);
            }
        }
    }

    public async void home () {
        if (active_command == null) {
            yield clear_error_log ();
            status1 &= ~(SWB1_HOME_IS_KNOWN); //Clear bit.
            message ("home () CW_HOME: %.4x status1: %.4x", CW_HOME, status1);
            /* Arm for adress = 0 (home), activate and toggle start bit */
            yield write_object (
                               C3Plus_DeviceControl_Controlword_1,
                               CWB_QUIT |
                               CWB_NO_STOP1 |
                               CWB_NO_STOP2
                               );
            yield write_object (
                               C3Plus_DeviceControl_Controlword_1,
                               CWB_QUIT |
                               CWB_NO_STOP1 |
                               CWB_NO_STOP2 |
                               CWB_START |
                               CWB_OPEN_BRAKE
                               );

            yield write_object (
                               C3Plus_DeviceControl_Controlword_1,
                               CWB_QUIT |
                               CWB_NO_STOP1 |
                               CWB_NO_STOP2 |
                               CWB_OPEN_BRAKE
                               );

            yield check_status (
                               home_timeout_ms,
                               SWB1_POS_REACHED |
                               SWB1_HOME_IS_KNOWN |
                               SWB1_NO_ERROR
                               );
            yield write_object (C3Plus_DeviceControl_Controlword_1, 0);
            yield fetch_actual_position ();
            yield last_error ();
        }
    }

    public async void zero_record () {
        message ("zero_record ()");
        if ((status1 & SWB1_HOME_IS_KNOWN) == SWB1_HOME_IS_KNOWN) {
            yield fetch_actual_position ();
            zero_position = _actual_position;
            message ("zero_position: %.3f", zero_position);
            position = 0.000;
            /* Write movement to the set table row 1*/
            yield write_object (C3Array_Col01_Row01, zero_position);
            yield write_object (C3Array_Col02_Row01, default_velocity);
            yield write_object (C3Array_Col05_Row01, MOVE_ABS);
            yield write_object (C3Array_Col06_Row01, default_acceleration);
            yield write_object (C3Array_Col07_Row01, default_deceleration);
            yield write_object (C3Array_Col08_Row01, default_jerk);
          /* Save move 1 to flash */
            yield write_object (C3_Flash_Write, 1);
        } else {
            message ("Home is not known. Zero command ignored.");
        }
    }

    public async void home_and_zero () {
        yield home ();
        yield zero_move ();
    }


    public async void zero_move () {
        if (active_command == null) {
            //yield clear_error_log ();
            //message ("zero_move () distance: %.3f", zero_position);
            /* Arm for Adress = 1 */
            yield write_object (
                               C3Plus_DeviceControl_Controlword_1,
                               CWB_QUIT |
                               CWB_NO_STOP1 |
                               CWB_NO_STOP2 |
                               CWB_ADDRESS_0
                               );
            /* Toggle the start bit */
            yield write_object (
                               C3Plus_DeviceControl_Controlword_1,
                               CWB_QUIT |
                               CWB_NO_STOP1 |
                               CWB_NO_STOP2 |
                               CWB_ADDRESS_0 |
                               CWB_START |
                               CWB_OPEN_BRAKE
                               );
            yield write_object (
                               C3Plus_DeviceControl_Controlword_1,
                               CWB_QUIT |
                               CWB_NO_STOP1 |
                               CWB_NO_STOP2 |
                               CWB_ADDRESS_1 |
                               CWB_OPEN_BRAKE
                               );
            /* Wait for timeout or position reached */
            yield check_status (
                               move_timeout_ms,
                               SWB1_POS_REACHED |
                               SWB1_NO_ERROR
                               );
            yield fetch_actual_position ();
            yield write_object (C3Plus_DeviceControl_Controlword_1, 0);
            //message ("zero_move (): power off");
            yield check_status (
                               move_timeout_ms,
                               SWB1_HOME_IS_KNOWN |
                               SWB1_NO_ERROR
                               );
            yield write_object (C3Plus_DeviceControl_Controlword_1, 0);
            yield fetch_actual_position ();
            yield last_error ();
            yield previous_error ();
        }
    }


    public async void withdraw (double length_mm, double speed_mmps) {
        if (active_command == null) {
            //yield clear_error_log ();
            //message ("withdraw (): length: %.3f speed: %.3f", length_mm);
            /* Write movement to the set table row 2*/
            yield write_object (C3Array_Col01_Row02, zero_position - length_mm);
            yield write_object (C3Array_Col02_Row02, speed_mmps);
            yield write_object (C3Array_Col05_Row02, MOVE_ABS);
            yield write_object (C3Array_Col06_Row02, default_acceleration);
            yield write_object (C3Array_Col07_Row02, default_deceleration);
            yield write_object (C3Array_Col08_Row02, default_jerk);
            /* Arm for Adress = 1 */
            yield write_object (C3Plus_DeviceControl_Controlword_1, CWB_QUIT |
                                    CWB_NO_STOP1 | CWB_NO_STOP2 | CWB_ADDRESS_1);
            /* Toggle the start bit */
            yield write_object (
                               C3Plus_DeviceControl_Controlword_1,
                               CWB_QUIT |
                               CWB_NO_STOP1 |
                               CWB_NO_STOP2 |
                               CWB_ADDRESS_1 |
                               CWB_START
                               );
            yield write_object (
                               C3Plus_DeviceControl_Controlword_1,
                               CWB_QUIT |
                               CWB_NO_STOP1 |
                               CWB_NO_STOP2 |
                               CWB_ADDRESS_1
                               );
            /* Wait for timeout or position reached */
            yield check_status (move_timeout_ms, SWB1_POS_REACHED |
                                    SWB1_NO_ERROR);
            yield fetch_actual_position ();
            yield last_error ();
            yield previous_error ();
        }
    }

    public async void inject (double speed_mmps, out double time_result) {
        GLib.TimeVal tv = GLib.TimeVal ();
        time_result = -1;

        if (active_command == null) {
            //yield clear_error_log ();
            //message ("inject () distance: %.3f", zero_position);
            /* Write movement to the set table row 2*/
            yield write_object (C3Array_Col01_Row02, zero_position);
            yield write_object (C3Array_Col02_Row02, speed_mmps);
            yield write_object (C3Array_Col05_Row02, MOVE_ABS);
            yield write_object (C3Array_Col06_Row02, default_acceleration);
            yield write_object (C3Array_Col07_Row02, default_deceleration);
            yield write_object (C3Array_Col08_Row02, default_jerk);
            /* Arm for Adress = 1 */
            yield write_object (C3Plus_DeviceControl_Controlword_1, CWB_QUIT |
                                CWB_NO_STOP1 | CWB_NO_STOP2 | CWB_ADDRESS_1);
            /* Start an injection timer */
            tv.get_current_time ();
            time_result = tv.tv_sec + (tv.tv_usec / 1e6);

            /* Toggle the start bit */
            yield write_object (
                               C3Plus_DeviceControl_Controlword_1,
                               CWB_QUIT |
                               CWB_NO_STOP1 |
                               CWB_NO_STOP2 |
                               CWB_ADDRESS_1 |
                               CWB_START
                               );
            yield write_object (
                               C3Plus_DeviceControl_Controlword_1,
                               CWB_QUIT |
                               CWB_NO_STOP1 |
                               CWB_NO_STOP2 |
                               CWB_ADDRESS_1
                               );
            /* Wait for timeout or position reached */
            yield check_status (move_timeout_ms, SWB1_POS_REACHED |
                                    SWB1_NO_ERROR);
            /* (finished) Stop the timer. */
            tv.get_current_time ();
            time_result = (tv.tv_sec + (tv.tv_usec / 1e6)) - time_result;
            message ("time_result: %.3f", time_result);

            yield fetch_actual_position ();
            yield last_error ();
            yield previous_error ();
            yield write_object (C3Plus_DeviceControl_Controlword_1, 0);
        }
    }

    public async void fetch_actual_position () {
        if (active_command == null) {
            active_command = C3_StatusPosition_Actual;
            yield read_object (active_command);
        }
    }

    public async void fetch_actual_torque () {
        if (active_command == null) {
            active_command = C3Plus_StatusTorqueForce_ActualTorque;
            yield read_object (active_command);
        }
    }

    public void parse_response (string response) {
        //message ("parse_response ():: response: %s active_command: %s", response, active_command);
        switch (active_command) {
            case "write_object":
                if (response == ">") {
                    write_success = true;
                } else if (response.has_prefix ("!")) {
                    write_success = false;
                    message ("write_object error: %s", response.substring (1));
                }
                break;
            case C3Plus_DeviceState_Statusword_1:
                status1 = int.parse (response);
                if ((status1 & SWB1_HOME_IS_KNOWN) == SWB1_HOME_IS_KNOWN) {
                    message ("home found");
                    active_command = null;
                } else if ((status1 & SWB1_HOME_IS_KNOWN) == 0) {
                    //message ("home not found");
                }
                if ((status1 & SWB1_POS_REACHED) == SWB1_POS_REACHED) {
                    message ("position reached");
                }
                if ((status1 & SWB1_NO_ERROR) == SWB1_NO_ERROR) {
                    //message ("No Error");
                    error (0, "No Error");
                } else {
                    message ("Status Word 1 Error");
                }
                if ((status1 & SWB1_CURRENT_ZERO) == SWB1_CURRENT_ZERO) {
                    //message ("Axis stationary with current at setpoint value");
                }
                break;
            case C3_StatusPosition_Actual:
                actual_position = double.parse (response);
                position = _actual_position - zero_position;
                //message ("actual_position: %.3f position (local): %.3f"
                //            , _actual_position, position);
                break;
            case C3Array_Col01_Row01:
                /* the zero position is stored here */
                zero_position = double.parse (response);
                //message ("zero_positon: %.3f", zero_position);
                break;
            case C3Plus_StatusTorqueForce_ActualTorque:
                actual_torque = double.parse (response);
                //message ("actual_torque: %.3f", _actual_torque);
                break;
            case C3Plus_ErrorHistory_LastError:
                message ("Error: %s", response);
                parse_error (0, response);
                break;
            case C3_ErrorHistory_1:
                message ("(n-1) Error: %s", response);
                parse_error (1, response);
                break;
            default:
                message ("Unable to parse response: %s", response);
                break;
        }
        active_command = null;
        data_received = true;
        received = "";
    }
    /**
     * Build a command from argument list and write it to the serial port.
     * XXX This could be made to take an index, sublindex and a variable list of values
     * using a valriable argument list method but it is here in a simpler form for now.
     */
    public async bool write_object (string index, double val) {
        bool ret = false;
        write_success = false;
        active_command = "write_object";
        count = 0;
        string msg1 = "o" + index + "=" + "%.3f".printf (val) +"\r\n";
        port.send_bytes (msg1.to_utf8 (), msg1.length);

        GLib.Timeout.add (100, () => {
            if (write_success == true) {
                //message ("write success");
                write_object.callback ();

                return false;
            } else if (count < 100) {
                //message (".");
                count++;

                return true;
            } else {
                message ("\nwrite failed");

                return false;
            }
        }, GLib.Priority.DEFAULT);

        yield;
        ret = true;

        return ret;
    }

    public async bool read_object (string index) {
        active_command = index;
        bool ret = false;
        data_received = false;
        count = 0;
        string msg1 = "o" + index + "\r\n";
        port.send_bytes (msg1.to_utf8 (), msg1.length);

        GLib. Timeout.add (serial_timeout_ms, () => {
            if (data_received) {
                //message ("read success");
                read_object.callback ();

                return false;
            } else {
                //message ("read timeout");

                return true;
            }
        }, GLib.Priority.DEFAULT);

        yield;
        ret = true;

        return ret;
    }

    private async void check_status (uint timeout_ms, uint flags) {
        if (active_command == null) {
            for (int i = 0; i < timeout_ms / serial_timeout_ms; i++) {
                //active_command = C3Plus_DeviceState_Statusword_1;
                yield read_object (C3Plus_DeviceState_Statusword_1);
                if ((status1 & flags) == flags) {
                    message ("check_status: passed status1: %.4x flags: %.4x", status1, flags);
                    active_command = null;
                    break;
                } else {
                    message ("check_status: failed status1: %.4x flags: %.4x", status1, flags);
                    if ((status1 & SWB1_NO_ERROR) == 0) {
                        message ("status word 1 NO_ERROR = 0");
                        break;
                    }
                }
            }
            if (!((status1 & flags) == flags)) {
                 message ("check_status: timed out or error");
            }

            message ("status1: 0x%.4x flags: 0x%.4x", status1, flags);
            active_command = null;
        }
    }

    /*
     * Retrieve the current error (ie. n = 1)
     */
    public async void last_error () {
        //message ("last_error ()");
        yield read_object (C3Plus_ErrorHistory_LastError);
        active_command = null;
    }

    /*
     * Retrieve the previous to last error (ie. n = 2)
     */
    public async void previous_error () {
        //message ("previous_error ()");
        yield read_object (C3_ErrorHistory_1);
        active_command = null;
    }

    /*
     * Clear the error log. This can be used to detect that an error occurred
     * since it was cleared.
     */
    private async void clear_error_log () {
        yield write_object ("551.1", -1); // This came from the Parker FAQ site.
        yield last_error ();
        yield previous_error ();
        active_command = null;
    }

    /*
     * Parse the error or simply return its number
     * n = 0 is the last error
     * n = 1 is the error before the last error
     */
    private void parse_error (int n, string response) {
        switch (response) {
            case "1":
                error (n, "No error");
                break;
            case "29472":
                error (n, "29472: Tracking Error");
                break;
            case "33153":
                error (n, "33153: Invalid Velocity");
                break;
            default:
                error (n, response);
                break;
        }
    }

    /*
     * Acknowledge an error
     */
    public async void ack_error () {
        yield write_object (C3Plus_DeviceControl_Controlword_1, CW_ACK_ZERO);
        yield write_object (C3Plus_DeviceControl_Controlword_1, CW_ACK_EDGE);
        yield last_error ();
    }
}
