Proposed Changes:

- get_descendant_ref_list --> get_ref_list
    DONE: Can't do this because it conflicts with the getter for ref_list

- get_descendant_from_uri --> get_object_from_uri
    DONE

- throw error from container add if uri already exists
    DONE

- context adds reference for ProcessValue but not ProcessValue2
    DONE

- for all methods include a header in valadoc format, or {@inheritDoc}
- group all property backing fields in one location at the top
    DONE

- all containers should not override objects unless there's a change in functionality
    DONE

- remove the xml node content print statement
    DONE

- format the printed ref table using string width and justifcation
    DONE

- make an example that uses a polling task at 10Hz and logs the data for 60s
    DONE
- for all existing weak references, add a property backing field and a getter
  that retrieves the object from the objects map. eg,
    DONE

protected weak Cld.Calibration _calibration = null;

public Cld.Calibration calibration {
    get {
        if (_calibration == null) {
            var calibrations = get_children (typeof (Cld.Calibration));
            foreach (var cal in calibrations.values) {
                /* this will only happen once */
                _calibration = cal;
                return _calibration;
            }
        } else {
            return _calibration;
        }
    }
    set {
        var calibrations = get_children (typeof (Cld.Calibration));
        /* remove all first */
        objects.unset_all (calibrations);
        objects.set (cal.id, cal);
    }
}
>>>>>>>>>>>>>>
    /* For the setter this should work.. */
    set {
        _calibration = value;
    }
    /* .. and the getter will return _calibration != null. */

>>>>>>>>>>>>>

- with the above, may have to figure out the weak location
- as has been done with the objects and id properties, move some other
  properties that are currently overridden but don't need to be. eg. AIChannel.
    DONE

- write a generic to_string that iterates properties using ObjectClass and
  ParamSpec and put it in AbstractObject                                        :
    DONE: I have made both a to_string () and a to_string_recursive () method because
    the latter can produce a large output.

- test currently library state with dactl, will need to change instances of
  builder.get_object to context.get_object, and otherwise make it work
    SO FAR SO GOOD: Charting a single analog input channel

- clean up builder
- move back to async acquisition using fifos, if necessary it was discussed that
  a Cld.Fifo class could be created and referenced using the URI
- in tests/ there is one executable "tests" that will run all unit tests
- add unit tests for all classes (eg. tests/testaichannel.vala)
- add test suite call to tests/testmain.vala
