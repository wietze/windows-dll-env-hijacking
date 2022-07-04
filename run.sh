x64=false
if [ "$x64" = true ] ; then
    echo "Building for 64-bit Windows"
    tools_prefix='x86_64-w64'
else
    echo "Building for 32-bit Windows"
    tools_prefix='i686-w64'
fi


if ! [ -x "$(command -v ${tools_prefix}-mingw32-objdump)" ]
then
    >&2 echo "${tools_prefix}-mingw32-objdump could not be found. Please ensure binutils-mingw-w64-x86-64 is installed."
    exit -1
fi

verlte() {
    [  "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]
}
version_insuccient=38
version="$(${tools_prefix}-mingw32-objdump -v | sed -n 's/^.*[^0-9]\([0-9]*\.[0-9]*\.[0-9]*\).*$/\1/p')"
if verlte $version $version_insuccient
then
    >&2 echo "An older version of mingw32-objdump ($version) was found. A minimum of $version_insuccient is expected. Please update to the latest version, or run build.sh to manually build the latest version."
    exit -1
fi


input_folder="$(dirname `realpath $0`)/input"
output_folder="$(dirname `realpath $0`)/output"

cd $input_folder
results=($(find . -iname '*.dll'))
if [ ${#results[@]} -eq 0 ]; then
    >&2 echo "No .dll files were found in the input folder ($input_folder)."
    exit -2
fi
i=0
for dll_path in "${results[@]}"; do
    # Create output folder structure if needed
    mkdir -p "$output_folder/${dll_path%/*}"
    # Display progress to stdout
    echo -en "\r$i/${#results[@]}"
    ( # Run bunch of commands, output to .def file
        # Create header of .def file
        echo -e "LIBRARY Wietze\nEXPORTS\n"
        # Get objdump data
        objdump_output=$(${tools_prefix}-mingw32-objdump -p "$dll_path")
        # Find ordinal offset in objdump data
        offset=`echo "$objdump_output" | sed -n -r "s/Export Address Table -- Ordinal Base ([0-9]+)/\1/gp"`
        # Use sed/perl magic to transform exports in objdump data to .def format
        (echo "$objdump_output" | perl -ne "print if s/^\s+\[\s{0,3}([0-9]{1,4})\]\s*([^ \s]+)\$/'\"'.\$2.'\"=\"$(echo $dll_path | sed 's/.\//c:\\\\/' | sed 's/\//\\\\/g').'.\$2.'\"@'.(\$1+${offset:=0})/ep")
    ) > "$output_folder/$dll_path.def"

    # Leverage windres to obtain a .res file containing embedded resources
    timeout 10s ${tools_prefix}-mingw32-windres -i "$dll_path" -O coff -o "$output_folder/$dll_path.res" 2> /dev/null
    if [ $? -eq 0 ]; then
        # Compile our output DLL, using (static) .C template and (generated) .def and .res files
        ${tools_prefix}-mingw32-gcc -shared -mwindows -o "$output_folder/$dll_path" "$output_folder/$dll_path.def" "$output_folder/$dll_path.res" ../template.c
        # Remove redundant .def/.rsrc files
        rm "$output_folder/$dll_path.def" "$output_folder/$dll_path.res";
    else
        # Compile our output DLL, using (static) .C template and (generated) .def file
        ${tools_prefix}-mingw32-gcc -shared -mwindows -o "$output_folder/$dll_path" "$output_folder/$dll_path.def" ../template.c
        # Remove redundant .def/.rsrc files
        rm "$output_folder/$dll_path.def";
    fi

    # Increment progress
    let "i++";
done
