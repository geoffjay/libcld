import unittest, gi
gi.require_version('Cld', '1.0')
from gi.repository import GLib, Cld

class GiTest(unittest.TestCase):
    def test_handler(self):
        self.assertTrue(True)

if __name__ == '__main__':
    unittest.main()
