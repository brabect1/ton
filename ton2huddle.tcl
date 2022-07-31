# Copyright 2022 Tomas Brabec
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
#     
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

lappend auto_path .
package require ton;

## set json {{"foo":"bar","lst": [1,2,"3"],"obj": {"a":1,"b":2}}};
## 
## set ton [ton::json2ton $json];
## set ton {o a [s b] c [s d]}
## puts "$ton";
## 
## ## puts "[lrange $ton 1 end]";
## ## set l [dict get [lrange $ton 1 end] "foo"];
## ## puts "$l";
## 
## #set d [ton::a2dict $ton];
## #puts "[ton::2list::get $ton "foo" "bar"]";
## 
## namespace eval ton::json2dict {
##     set d [eval $ton];
##     puts "$d";
## }

namespace eval ton::2huddle {
    proc s v {return [list s [subst -nocommands -novariables $v]]}
    proc d v {return [list num $v]}
    proc i v {return [list num $v]}
    proc l v {
	    switch $v {
		    null {}
		    true {set v {b true}}
		    false {set v {b false}}
		    default {
		        error "error: unknown literal '$v'"
	        }
        }
        return $v;
    }
    proc a args {
        return [list L $args];
    }
    proc o args {
        return [list D $args];
    }

    proc ton2huddle ton {
        return [list HUDDLE [eval $ton]];
    }
}

## set h [ton::2huddle::ton2huddle $ton];
## puts "$h";

