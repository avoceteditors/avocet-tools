
from avocet.config cimport Config

cdef class Environment(object):

    def __init__(self, path):
        self.path = path

    def configure(self, int force):

        config_path = self.path.joinpath("avocet.conf")

        self.init_config()
        if config_path.exists() and force: 
            self.config.initialize(config_path)

    def init_config(self):
        self.config = Config()

