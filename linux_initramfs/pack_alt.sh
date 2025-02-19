#!/bin/sh
# 
# This file is part of Redqueen.
#
# Sergej Schumilo, 2019 <sergej@schumilo.de> 
# Cornelius Aschermann, 2019 <cornelius.aschermann@rub.de> 
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Redqueen.  If not, see <http://www.gnu.org/licenses/>.
#

if ! [ -x "$(command -v cpio)" ]; then
  echo 'Error: cpio is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v gzip)" ]; then
  echo 'Error: gzip is not installed.' >&2
  exit 1
fi

cd ../packer/linux_x86_64-userspace/
sh compile_loader.sh
cd -
cp ../packer/linux_x86_64-userspace/bin64/loader rootTemplate/loader
chmod +x rootTemplate/loader

mkdir rootTemplate/lib/
mkdir rootTemplate/lib64/

cp -L /lib/ld-linux.so.2 rootTemplate/lib/ld-linux.so.2
cp -L /lib/libdl.so.2 rootTemplate/lib/libdl.so.2
cp -L /lib/libc.so.6 rootTemplate/lib/libc.so.6


cp -L /lib64/ld-linux-x86-64.so.2 rootTemplate/lib64/ld-linux-x86-64.so.2
cp -L /lib64/libdl.so.2 rootTemplate/lib64/libdl.so.2
cp -L /lib64/libc.so.6 rootTemplate/lib64/libc.so.6

# fix nasty nss bugs (getpwnam_r, ...)
cp -L /lib/libnss_compat.so.2 rootTemplate/lib
cp -L /lib64/libnss_compat.so.2 rootTemplate/lib64


cp -r "rootTemplate" "init"
sed '/START/c\./loader' init/init_template > init/init
chmod 755 "init/init"
cd "init"

find . -print0 | cpio --null -ov --format=newc  2> /dev/null | gzip -9 > "../init.cpio.gz" 2> /dev/null
cd ../
rm -r ./init/


cp -r "rootTemplate" "init"
sed '/START/c\sh' init/init_template > init/init
chmod 755 "init/init"
cd "init"

find . -print0 | cpio --null -ov --format=newc  2> /dev/null | gzip -9 > "../init_debug_shell.cpio.gz"  2> /dev/null
cd ../
rm -r ./init/

rm -r rootTemplate/lib/
rm -r rootTemplate/lib64/
rm rootTemplate/loader
