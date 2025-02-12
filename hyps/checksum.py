#!/usr/bin/env python3

import argparse
import glob
import hashlib
import humanize
import os
import sys
import time

lock_file = '/tmp/checksum.lock'

#______________________________________________________________________________
def checksum(data_path, output, algorithm, recreate=False):
  data_path = os.path.realpath(data_path)
  os.chdir(data_path)
  data_list = sorted(glob.glob(data_path + '/*.dat*'))
  data_size = 0
  for d in data_list:
    data_size += file_size(d)
  done_list = []
  if recreate:
    with open(output, 'w') as f:
      pass
  else:
    if os.path.isfile(output):
      with open(output, 'r') as f:
        for line in f:
          done_list.append(line.split()[1])
  done_size = 0
  n_done = 0
  with open(output, 'a') as f:
    for i, d in enumerate(data_list):
      d = os.path.basename(d)
      if os.access(d, os.W_OK):
        continue
      done_size += file_size(d)
      n_done += 1
      if d in done_list:
        continue
      buf = ('{0}  {1}'.format(get_hash(d, algorithm), d))
      print('{:20} {:>10} {:4d}/{:4d} ... {}'
            .format(d, natural_size(file_size(d)),
                    n_done, len(data_list), buf[:30]))
      f.write(buf + '\n')
      f.flush()

#______________________________________________________________________________
def file_size(arg):
  if type(arg) is str:
    if os.path.isfile(arg):
      return os.path.getsize(arg)
  return 0

#______________________________________________________________________________
def get_hash(path, algorithm):
  if not os.path.isfile(path):
    return None
  hash = hashlib.new(algorithm)
  with open(path, 'rb') as f:
    for chunk in iter(lambda: f.read(2048 * hash.block_size), b''):
      hash.update(chunk)
  return hash.hexdigest()

#______________________________________________________________________________
def natural_size(arg):
  if type(arg) is str:
    if not os.path.isfile(arg):
      return ''
    size = os.path.getsize(arg)
    return humanize.naturalsize(size).replace('Bytes', ' B')
  if type(arg) is int:
    return humanize.naturalsize(arg).replace('Bytes', ' B')

#______________________________________________________________________________
if __name__ == '__main__':
  if os.path.exists(lock_file):
    sys.exit(0)
  argparse = argparse.ArgumentParser()
  argparse.add_argument('data_path', help='data storage path')
  argparse.add_argument('--output', '-o',
                        default='checksum.txt', help='output text file name')
  argparse.add_argument('--algorithm', '-a',
                        default='sha512', help='hash algorithm')
  argparse.add_argument('--follow', '-f',
                        action='store_true', help='output appended data as the file list grows')
  argparse.add_argument('--recreate', '-r',
                        action='store_true', help='hash algorithm')
  parsed, unparsed = argparse.parse_known_args()
  print(('=== checksum ' + '=' * 80)[:80])
  print('algorithm : {}'.format(parsed.algorithm))
  print('data_path : {}'.format(parsed.data_path))
  print('output_file : {}'.format(parsed.output))
  print('=' * 80)
  try:
    with open(lock_file, 'w') as f:
      pass
    checksum(parsed.data_path,
             parsed.output,
             parsed.algorithm,
             parsed.recreate)
    while parsed.follow:
      checksum(parsed.data_path,
               parsed.output,
               parsed.algorithm,
               False)
      time.sleep(10)
    os.remove(lock_file)
  except (IOError, KeyboardInterrupt) as err:
    print(err)
    os.remove(lock_file)
    sys.exit(1)
