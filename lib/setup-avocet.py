from distutils.core import setup
from Cython.Build import cythonize

import re
import pathlib
def find_packages(lib, pkgs, bin):
    dirs = {}
    exts = []
    bins = []
    for pkg in pkgs:
        src = re.sub("\.", "/", pkg)
        name = re.sub("\.", "-", pkg)
        path = lib.joinpath(src)

        if path.exists():

            # Add Package to Dirs
            dirs[pkg] = src

            for i in path.glob("*.pxd"):
                exts.append(str(i))
            for i in path.glob("*.pyx"):
                exts.append(str(i))
        script = bin.joinpath(name)

        if script.exists():
            bins.append(str(script))

    return (pkgs, dirs, exts, bins) 

lib = pathlib.Path("avocet")
bin = pathlib.Path("../scripts")
        
# Setup Packages
modules = [
    "avocet",
    "avocet.commands"
]
(pkgs, dirs, exts, bins) = find_packages(lib, modules, bin)
if exts == []:
    setup(name="avocet",
          version="2021.5",
          scripts=bins,
          package_dir=dirs)

#package_data={"avocet": ['avocet/data/*.sql']},
#ext_modules=cythonize(exts, language_level=3)



