import sys
import os
import json

default_file_name = "version.h"
default_file_path = None
default_template = "#ifndef VERSION_CPP_H\n"+ \
                   "#define VERSION_CPP_H\n"+ \
                   "\n"                   + \
                   "#define VERSION_MAJOR {major}\n"+ \
                   "#define VERSION_MINOR {minor}\n"  + \
                   "#define VERSION_BUILD {build}\n"  + \
                   "\n"+ \
                   "#endif"

def make_version_h(major,minor,build,file_name=default_file_name,file_path=default_file_path, template = default_template):
	full_file_path = file_name if file_path == None else os.path.join(file_path,file_name) 
	vf = open(full_file_path,"w")
	print(template.format(major = major, minor = minor, build = build), file = vf)
	vf.close()
	
if __name__ == "__main__":
	'''print(len(sys.argv),sys.argv)'''
	parameters = {"version_major" :None,
	              "version_minor" :None,
	              "build" :None,
	              "file_name" :None,
	              "file_path" :None,
	              "template" :None,
	              "src": None,
	              "abi": 1
	              } 
	          
	op = {"version_major" :None,
	      "version_minor" :None,
	      "build" :None,
	      "file_name" :default_file_name,
	      "file_path" :default_file_path,
	      "template" :default_template
	     } 

	pp =  {1:"version_major",
	       2:"version_minor",
	       3:"build",
	       4:"file_name",
	       5:"file_path",
	       6:"template"
		  }
		  
	ps =  {"-j":"version_major",
	       "-i":"version_minor",
	       "-b":"build",
	       "-abi":"abi",
	       "-s":"src",
	       "-f":"file_name",
	       "-p":"file_path",
	       "-t":"template"
		  }	  
		
	argit = iter( range(1,len(sys.argv)) ) 		
	for argi in argit:
		arg = sys.argv[argi]
		if arg in ps:
			pname = ps[arg]
			parameters[pname] = sys.argv[argi+1]
			next(argit)
		else:
			pname = pp[argi]
			parameters[pname] = arg
	
	if parameters["src"] != None:
		f = open(parameters["src"], "r")
		source = json.load(f);
		f.close();
		if parameters["abi"] > 0:
			source["build"] = str( int(source["build"])+1 )
			f = open(parameters["src"], "w")
			json.dump(source,f)
			f.close()
		f.close();
			
		for key in source:
			if key in op:
				op[key] = source[key]		
	
	for key in parameters:
		value = parameters[key]
		if (key in op) and (value != None):
			op[key] = value
			  	
	make_version_h(op["version_major"],op["version_minor"],op["build"],op["file_name"],op["file_path"],op["template"])
