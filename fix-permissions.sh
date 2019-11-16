#!/usr/bin/env sh

# Recursively set permissions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Recursively changes file and directory permissions, owner and group.
#
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#      the Free Software Foundation, either version 3 of the License, or
#                     (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful,
#        but WITHOUT ANY WARRANTY; without even the implied warranty of
#        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#                 GNU General Public License for more details.
#
#      You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#_______________________________________________________________________________

find -xdev \( -type f -exec chmod 664 {} \+ -o -type d -exec chmod 775 "{}" \+ \)\
	-exec chown jonas:jonas {} \+ -printf "FIXING: %p\n" 2>&-
