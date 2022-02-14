#!/bin/bash -ue

tools=https://sm.alliedmods.net/smdrop/1.10/sourcemod-1.10.0-git6502-linux.tar.gz

tmp_dir=$(mktemp -d)
echo using temporary folder: $tmp_dir >&2
clean () {
    rm -rf $tmp_dir
    echo deleted temporary folder >&2
}
trap clean EXIT

curl $tools -o $tmp_dir/tools.tar.gz
tar -xf $tmp_dir/tools.tar.gz -C $tmp_dir
$tmp_dir/addons/sourcemod/scripting/spcomp lan_of_doom_paintball.sp

mkdir -p build/addons/sourcemod/plugins
mv lan_of_doom_paintball.smx build/addons/sourcemod/plugins/lan_of_doom_paintball.smx
mkdir -p build/materials/paintball
cp materials/paintball/* build/materials/paintball/
cd build
tar -czvf lan_of_doom_paintball.tar.gz materials addons
rm -rf addons
rm -rf materials
cd ..
tar -czvf build/lan_of_doom_paintball_source.tar.gz materials build.sh lan_of_doom_paintball.sp LICENSE README.md

echo created build/lan_of_doom_paintball.smx