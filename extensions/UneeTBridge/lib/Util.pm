# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This Source Code Form is "Incompatible With Secondary Licenses", as
# defined by the Mozilla Public License, v. 2.0.

package Bugzilla::Extension::UneeTBridge::Util;

use 5.10.1;
use strict;
use warnings;

use Bugzilla::Config::Common;

use parent qw(Exporter);

use constant get_param_list => (
  {
   name => 'cases_server_url',
   type => 't',
   default => 'http://localhost:3000'
  },
);

our @EXPORT = qw(
    
);

# This file can be loaded by your extension via 
# "use Bugzilla::Extension::UneeTBridge::Util". You can put functions
# used by your extension in here. (Make sure you also list them in
# @EXPORT.)

1;
