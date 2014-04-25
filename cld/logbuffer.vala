/**
 * A log file buffer class to use to be able to write data to a log
 * file without using a rate timer.
 *
 * Code stolen almost entirely from Gee.ArrayQueue implementation.
 * XXX Not implemented yet.
 */
public class Cld.LogBuffer<G> : Cld.AbstractObject, Gee.Traversable, Gee.Iterable, Gee.Deque<G> {

//    /**
//     * {@inheritDoc}
//     */
//    public override int size { get { return _length; } }
//
//    public override bool is_empty { get { return _length == 0; } }
//
//    /**
//     * {@inheritDoc}
//     */
//    public override bool read_only { get { return false; } }
//
//    /**
//     * {@inheritDoc}
//     */
//    public override int capacity { get {return Gee.Queue.UNBOUNDED_CAPACITY;} }
//
//    /**
//     * {@inheritDoc}
//     */
//    public override int remaining_capacity { get {return Gee.Queue.UNBOUNDED_CAPACITY;} }
//
//    /**
//     * {@inheritDoc}
//     */
//    public override bool is_full { get { return false; } }
//
//    /**
//     * {@inheritDoc}
//     */
//    public override Gee.Iterator<G> iterator() {
//        return new Iterator<G> (this);
//    }
//
//    /**
//     * {@inheritDoc}
//     */
//    public override bool contains (G item) {
//        return find_index(item) != -1;
//    }
//
//    /**
//     * {@inheritDoc}
//     */
//    public override bool remove (G item) {
//        _stamp++;
//        int index = find_index (item);
//        if (index == -1) {
//            return false;
//        } else {
//            remove_at (index);
//            return true;
//        }
//    }
//
//    /**
//     * {@inheritDoc}
//     */
//    public override void clear() {
//        _stamp++;
//        for (int i = 0; i < _length; i++) {
//            _items[(_start + i) % _items.length] = null;
//        }
//        _start = _length = 0;
//    }
//
//    /**
//     * {@inheritDoc}
//     */
//    public override bool offer (G element) {
//        return offer_tail (element);
//    }
//
//    /**
//     * {@inheritDoc}
//     */
//    public override G? peek () {
//        return peek_head ();
//    }
//
//    /**
//     * {@inheritDoc}
//     */
//    public override G? poll () {
//        return poll_head ();
//    }
//
//    /**
//     * {@inheritDoc}
//     */
//    public bool offer_head (G element) {
//        grow_if_needed ();
//        _start = (_items.length + _start - 1) % _items.length;
//        _length++;
//        _items[_start] = element;
//        _stamp++;
//        return true;
//    }
//
//    /**
//     * {@inheritDoc}
//     */
//    public G? peek_head () {
//        return _items[_start];
//    }
//
//    /**
//     * {@inheritDoc}
//     */
//    public G? poll_head () {
//        _stamp++;
//        if (_length == 0) {
//            _start = 0;
//            return null;
//        } else {
//            _length--;
//            G result = (owned)_items[_start];
//            _start = (_start + 1) % _items.length;
//            return (owned)result;
//        }
//    }
//
//    /**
//     * {@inheritDoc}
//     */
//    public int drain_head (Collection<G> recipient, int amount = -1) {
//        return drain (recipient, amount);
//    }
//
//    /**
//     * {@inheritDoc}
//     */
//    public bool offer_tail (G element) {
//        grow_if_needed();
//        _items[(_start + _length++) % _items.length] = element;
//        _stamp++;
//        return true;
//    }
//
//    /**
//     * {@inheritDoc}
//     */
//    public G? peek_tail () {
//        return _items[(_items.length + _start + _length - 1) % _items.length];
//    }
//
//    /**
//     * {@inheritDoc}
//     */
//    public G? poll_tail () {
//        _stamp++;
//        if (_length == 0) {
//            _start = 0;
//            return null;
//        } else {
//            return (owned)_items[(_items.length + _start + --_length) % _items.length];
//        }
//    }
//
//    /**
//     * {@inheritDoc}
//     */
//    public int drain_tail (Collection<G> recipient, int amount = -1) {
//        G? item = null;
//        int drained = 0;
//        while((amount == -1 || --amount >= 0) && (item = poll_tail ()) != null) {
//            recipient.add(item);
//            drained++;
//        }
//        return drained;
//    }
//
//    /**
//     * {@inheritDoc}
//     */
//    private void grow_if_needed () {
//        if (_items.length < _length +1 ) {
//            _items.resize (2 * _items.length);
//#if 0
//            _items.move (0, _length, _start);
//#else
//            // See bug #667452
//            for(int i = 0; i < _start; i++)
//                _items[_length + i] = (owned)_items[i];
//#endif
//        }
//    }
//
//    private int find_index (G item) {
//        for (int i = _start; i < int.min(_items.length, _start + _length); i++) {
//            if (equal_func(item, _items[i])) {
//                return i;
//            }
//        }
//        for (int i = 0; i < _start + _length - _items.length; i++) {
//            if (equal_func(item, _items[i])) {
//                return i;
//            }
//        }
//        return -1;
//    }
//
//    private void remove_at (int index) {
//        int end = (_items.length + _start + _length - 1) % _items.length + 1;
//        if (index == _start) {
//            _items[_start++] = null;
//            _length--;
//            return;
//        } else if (index > _start && end <= _start) {
//            _items[index] = null;
//            _items.move (index + 1, index, _items.length - 1);
//            _items[_items.length - 1] = (owned)_items[0];
//            _items.move (1, 0, end - 1);
//            _length--;
//        } else {
//            _items[index] = null;
//            _items.move (index + 1, index, end - (index + 1));
//            _length--;
//        }
//    }
//
//    private class Iterator<G> : GLib.Object, Traversable<G>, Gee.Iterator<G> {
//        public Iterator (Cld.LogBuffer<G> buffer) {
//            _buffer = buffer;
//            _stamp = _buffer._stamp;
//        }
//
//        public bool next () {
//            assert (_buffer._stamp == _stamp);
//            if (has_next ()) {
//                _offset++;
//                _removed = false;
//                return true;
//            } else {
//                return false;
//            }
//        }
//
//        public bool has_next () {
//            assert (_buffer._stamp == _stamp);
//            return _offset + 1 < _buffer._length;
//        }
//
//        public new G get () {
//            assert (_buffer._stamp == _stamp);
//            assert (_offset != -1);
//            assert (!_removed);
//            return _buffer._items[(_buffer._start + _offset) % _buffer._items.length];
//        }
//
//        public void remove () {
//            assert (_buffer._stamp++ == _stamp++);
//            _buffer.remove_at((_buffer._start + _offset) % _buffer._items.length);
//            _offset--;
//            _removed = true;
//        }
//
//        public bool valid { get {return _offset != -1 && !_removed;} }
//
//        public bool read_only { get {return false;} }
//
//        public void foreach (ForallFunc<G> f) {
//            assert (_buffer._stamp == _stamp);
//            if(!valid) {
//                _offset++;
//                _removed = false;
//            }
//            for(int i = _offset; i < _buffer._length; i++) {
//                f (_buffer._items[(_buffer._start + i) % _buffer._items.length]);
//            }
//        }
//
//        public Gee.Iterator<A> stream<A> (owned StreamFunc<G, A> f) {
//            return Gee.Iterator.stream_impl<G, A> (this, (owned)f);
//        }
//
//        private Cld.LogBuffer _buffer;
//        private int _stamp;
//        private int _offset = -1;
//        private bool _removed = false;
//    }
//
//    private G[] _items;
//    private int _start = 0;
//    private int _length = 0;
//    private int _stamp = 0;
}
