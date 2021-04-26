import os

IGNORE = [".github", "_build", "misc", "src/_build"]

import glob

top = os.getcwd()

def _get_pf_name(x):
	return x[29:]

def _check_is_exclude(x):
	for s in IGNORE:
		if x.startswith(s):
			return True
	return False

def _fetch_contents(fname):
	return open(fname, mode='r').read()

for filename in glob.iglob(os.path.join(top, '**/**'), recursive=True):
	if os.path.isfile(filename):
		printable_f_name = _get_pf_name(filename)
		if not _check_is_exclude(printable_f_name):
			print("-"*10)
			print("File: {}".format(printable_f_name))
			print(_fetch_contents(filename))
			print("-"*10)
