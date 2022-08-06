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

    # converts a TON structure to a HUDDLE structure
    proc ton2huddle ton {
        return [list HUDDLE [eval $ton]];
    }

    # converts a HUDDLE structure to a TON structure
    proc huddle2ton {huddle_object} {
        package require huddle;
        variable types
    
        set type [huddle type $huddle_object]
    
        switch -- $type {
            boolean {
                return [list l [huddle get_stripped $huddle_object]];
            }
            number {
                return [list d [huddle get_stripped $huddle_object]];
            }
            null {
                return {l null};
            }
            string {
                set data [huddle get_stripped $huddle_object]
    
                # JSON (and hence TON) permits only oneline string
                set data [string map {
                        \n \\n
                        \t \\t
                        \r \\r
                        \b \\b
                        \f \\f
                        \\ \\\\
                        \" \\\"
                        / \\/
                    } $data
                ]
                return [list s $data];
            }
            list {
                set inner {}
                set len [huddle llength $huddle_object]
                for {set i 0} {$i < $len} {incr i} {
                    set subobject [huddle get $huddle_object $i];
                    lappend inner "\[[huddle2ton $subobject]\]";
                }
                return [concat a [join $inner " "]];
            }
            dict {
                set inner {}
                foreach {key} [huddle keys $huddle_object] {
                    lappend inner $key "\[[huddle2ton [huddle get $huddle_object $key]]\]";
                }
                return [concat o [join $inner " "]];
            }
            default {
                set node [unwrap $huddle_object]
                foreach {tag src} $node break
                return [$types(callback:$tag) huddle2ton $huddle_object]
            }
        }
    }

}

## set h [ton::2huddle::ton2huddle $ton];
## puts "$h";

